import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:DokkaebieImage/constants/api_constants.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

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

  void _downloadZipWithInterop(Uint8List bytes) {
    final blobPart = bytes.toJS;
    final jsArray = <web.BlobPart>[blobPart as web.BlobPart].toJS;

    final blob = web.Blob(
      jsArray,
      web.BlobPropertyBag(type: 'application/zip'),
    );
    final url = web.URL.createObjectURL(blob);

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = 'result_color_transfer.zip';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  void _downloadImage(String filename, Uint8List bytes) {
    final blobPart = bytes.toJS;
    final jsArray = <web.BlobPart>[blobPart as web.BlobPart].toJS;

    final blob = web.Blob(
      jsArray,
      web.BlobPropertyBag(type: 'application/octet-stream'),
    );
    final url = web.URL.createObjectURL(blob);

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  Future<void> _pickReferenceImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _referenceImage = result.files.single.bytes!;
      });
    }
  }

  Future<void> _pickImages() async {
    if (_images.length >= 6) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      Map<String, Uint8List> newImages = {};

      for (final file in result.files) {
        if (file.bytes != null) {
          if (_images.length + newImages.length >= 6) break;
          newImages[file.name] = file.bytes!;
        }
      }

      setState(() {
        _images.addAll(newImages);
      });
    }
  }

  void _removeImage(String name) {
    setState(() {
      _images.remove(name);
    });
  }

  Future<void> _sendImagesAsMultipart() async {
    if (_images.isEmpty || _referenceImage == null) return;

    setState(() {
      _isProcessing = true;
      _downloadableZip = null;
      _apiResponseError = "";
      _resultImages = {};
    });

    final url = Uri.parse(ApiConstants.colorTransfer);
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      http.MultipartFile.fromBytes(
        'reference',
        _referenceImage!,
        filename: "reference.img",
      ),
    );

    for (final entry in _images.entries) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'targets',
          entry.value,
          filename: entry.key,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // decode zip
        final zipBase64 = jsonResponse['zip'] as String;
        final zipBytes = base64Decode(zipBase64);

        // decode images
        final List<dynamic> imageList = jsonResponse['images'];
        final Map<String, Uint8List> resultImages = {};

        for (final item in imageList) {
          final filename = item['filename'] as String;
          final imageBytes = base64Decode(item['data']);
          resultImages[filename] = imageBytes;
        }

        setState(() {
          _downloadableZip = zipBytes;
          _resultImages = resultImages;
        });
      } else {
        setState(() {
          _apiResponseError = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _apiResponseError = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _exampleImageWithLabel(
    String label,
    String assetPath,
    Color borderColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 188,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: borderColor),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              // Section 1
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'tool1_header'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool1_contents'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'tool_ref_paper'.tr(),
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://doi.org/10.1109/38.946629',
                                      ),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Reference Image
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
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Target Images
                    DottedBorder(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: _images.isEmpty
                              ? Text(
                                  'tool_input_box_contents'.tr(),
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: _images.entries.map((entry) {
                                    final fname = entry.key;
                                    final imageData = entry.value;

                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            width: 150,
                                            height: 150,
                                            color: Colors.grey[200],
                                            child: Image.memory(
                                              imageData,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  _removeImage(fname),
                                              splashRadius: 20,
                                              padding: const EdgeInsets.all(4),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Button to add target images
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
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _sendImagesAsMultipart,
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

                    DottedBorder(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: _resultImages.isEmpty
                              ? Text(
                                  'tool_results_box_contents'.tr(),
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: _resultImages.entries.map((entry) {
                                    final fname = entry.key;
                                    final imageData = entry.value;

                                    return Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            width: 150,
                                            height: 150,
                                            color: Colors.grey[200],
                                            child: Image.memory(
                                              imageData,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.download,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                              onPressed: () => _downloadImage(
                                                fname,
                                                imageData,
                                              ),
                                              splashRadius: 20,
                                              padding: const EdgeInsets.all(4),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      onPressed: (_downloadableZip != null && !_isProcessing)
                          ? () => _downloadZipWithInterop(_downloadableZip!)
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
                  ],
                ),
              ),

              const SizedBox(height: 25),

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

              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'tool1_header2'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'tool1_contents2'.tr(),
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _exampleImageWithLabel(
                          'tool_reference_img'.tr(),
                          "assets/images/tool1/ref.jpg",
                          Colors.black54,
                        ),
                        _exampleImageWithLabel(
                          'tool_target_img'.tr(),
                          "assets/images/tool1/target.jpg",
                          Colors.black54,
                        ),
                        _exampleImageWithLabel(
                          'tool_result_img'.tr(),
                          "assets/images/tool1/result.jpg",
                          Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '© 2025 Dokkaebi Image. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
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
