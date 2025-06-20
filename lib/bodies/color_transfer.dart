// color_transfer_body.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import 'package:DokkaebieImage/constants/api_constants.dart';
import 'package:DokkaebieImage/bodies/common/common_widgets.dart';
import 'package:DokkaebieImage/bodies/common/common_functions.dart';

class ColorTransferBody extends StatefulWidget {
  const ColorTransferBody({super.key});
  @override
  State<ColorTransferBody> createState() => _ColorTransferBodyState();
}

class _ColorTransferBodyState extends State<ColorTransferBody> {
  Map<String, Uint8List> _images = {};
  Uint8List? _referenceImage;
  String _apiResponseError = "";
  bool _isProcessing = false;
  Uint8List? _downloadableZip;
  Map<String, Uint8List> _resultImages = {};

  Future<void> _pickReferenceImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() => _referenceImage = result.files.single.bytes!);
    }
  }

  Future<void> _pickImages() async {
    final newImages = await CommonFunctions.pickImages(max: 6 - _images.length);
    setState(() => _images.addAll(newImages));
  }

  void _removeImage(String name) => setState(() => _images.remove(name));

  void _downloadImage(String name, Uint8List data) =>
      CommonFunctions.downloadImage(name, data);

  void _downloadZip() => CommonFunctions.downloadZipWithInterop(
    _downloadableZip!,
    'result_color_transfer.zip',
  );

  Future<void> _sendRequest() async {
    setState(() {
      _isProcessing = true;
      _apiResponseError = "";
      _resultImages = {};
      _downloadableZip = null;
    });

    try {
      final (zip, images) = await CommonFunctions.sendMultipartRequest(
        url: Uri.parse(ApiConstants.colorTransfer),
        targets: _images,
        referenceImage: _referenceImage,
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
                      'tool1_header'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool1_contents'.tr(),
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
                                text: 'Color Transfer between Images',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => launchUrl(
                                    Uri.parse(
                                      'https://doi.org/10.1109/38.946629',
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_referenceImage != null)
                          Container(
                            width: 340,
                            height: 340,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _referenceImage!,
                                width: 320,
                                height: 320,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _pickReferenceImage,
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
                            'tool_upload_reference_image_btn'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
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
                      'tool1_header2'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool1_contents2'.tr(),
                      style: GoogleFonts.inter(fontSize: 20, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        CommonWidgets.exampleImageWithLabel(
                          'tool_reference_img'.tr(),
                          "assets/images/tool1/ref.jpg",
                          Colors.black54, 188, 250
                        ),
                        CommonWidgets.exampleImageWithLabel(
                          'tool_target_img'.tr(),
                          "assets/images/tool1/target.jpg",
                          Colors.black54, 188, 250
                        ),
                        CommonWidgets.exampleImageWithLabel(
                          'tool_result_img'.tr(),
                          "assets/images/tool1/result.jpg",
                          Colors.black, 188, 250
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
