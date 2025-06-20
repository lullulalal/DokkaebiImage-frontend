// noise_remover_body.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:DokkaebieImage/constants/api_constants.dart';
import 'package:DokkaebieImage/bodies/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class NoiseRemoverBody extends StatefulWidget {
  const NoiseRemoverBody({super.key});
  @override
  State<NoiseRemoverBody> createState() => _NoiseRemoverBodyState();
}

class _NoiseRemoverBodyState extends State<NoiseRemoverBody> {
  Map<String, Uint8List> _images = {};
  String _apiResponseError = "";
  bool _isProcessing = false;
  Uint8List? _downloadableZip;
  Map<String, Uint8List> _resultImages = {};

  Future<void> _pickImages() async {
    final newImages = await CommonWidgets.pickImages(max: 6 - _images.length);
    setState(() => _images.addAll(newImages));
  }

  void _removeImage(String name) => setState(() => _images.remove(name));

  void _downloadImage(String name, Uint8List data) =>
      CommonWidgets.downloadImage(name, data);

  void _downloadZip() => CommonWidgets.downloadZipWithInterop(
    _downloadableZip!,
    'result_noise_remover.zip',
  );

  Future<void> _sendRequest() async {
    setState(() {
      _isProcessing = true;
      _apiResponseError = "";
      _resultImages = {};
      _downloadableZip = null;
    });

    try {
      final (zip, images) = await CommonWidgets.sendMultipartRequest(
        url: Uri.parse(ApiConstants.noiseRemover),
        targets: _images,
      );

      setState(() {
        _downloadableZip = zip;
        _resultImages = images;
      });
    } catch (e) {
      setState(() => _apiResponseError = e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'tool2_header'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool2_contents'.tr(),
                      style: GoogleFonts.inter(fontSize: 20, height: 1.6),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'tool_ref_paper'.tr(),
                          style: GoogleFonts.inter(fontSize: 15, height: 1.6),
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: 'BM3D Image Denoising',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchUrl(
                                    Uri.parse(
                                      'https://doi.org/10.1109/TIP.2007.901238',
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    CommonWidgets.imageUploadBox(_images, _removeImage),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'tool_add_target_images_btn'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _sendRequest,
                      icon: const Icon(Icons.upload),
                      label: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'tool_process_btn'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent[200],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    CommonWidgets.resultImageBox(_resultImages, _downloadImage),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: (_downloadableZip != null && !_isProcessing)
                          ? _downloadZip
                          : null,
                      icon: const Icon(Icons.download),
                      label: Text(
                        'tool_download_btn'.tr(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent[200],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (_apiResponseError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _apiResponseError,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 35),
                    Text(
                      'tool2_header2'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool2_contents2'.tr(),
                      style: GoogleFonts.inter(fontSize: 20, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        CommonWidgets.exampleImageWithLabel(
                          'tool_target_img'.tr(),
                          "assets/images/tool2/target.jpg",
                          Colors.black54, 250, 250
                        ),
                        CommonWidgets.exampleImageWithLabel(
                          'tool_result_img'.tr(),
                          "assets/images/tool2/result.jpg",
                          Colors.black, 250, 250
                        ),
                      ],
                    ),
                    CommonWidgets.copyrightFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
