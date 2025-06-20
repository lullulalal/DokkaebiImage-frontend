// common_widgets.dart
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web/web.dart' as web;
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommonWidgets {
  static Future<(Uint8List, Map<String, Uint8List>)> sendMultipartRequest({
    required Uri url,
    required Map<String, Uint8List> targets,
    Uint8List? referenceImage,
  }) async {
    final request = http.MultipartRequest('POST', url);

    if (referenceImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'reference',
          referenceImage,
          filename: 'reference.img',
        ),
      );
    }
    for (final entry in targets.entries) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'targets',
          entry.value,
          filename: entry.key,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final zip = base64Decode(data['zip']);
    final resultImages = {
      for (var item in data['images'])
        item['filename'].toString(): base64Decode(item['data']),
    };

    return (zip, resultImages);
  }

  static Future<Map<String, Uint8List>> pickImages({int max = 6}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    Map<String, Uint8List> images = {};
    if (result != null) {
      for (final file in result.files) {
        if (file.bytes != null) {
          if (images.length >= max) break;
          images[file.name] = file.bytes!;
        }
      }
    }
    return images;
  }

  static void downloadImage(String filename, Uint8List bytes) {
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

  static void downloadZipWithInterop(Uint8List bytes, String zipFilename) {
    final blobPart = bytes.toJS;
    final jsArray = <web.BlobPart>[blobPart as web.BlobPart].toJS;

    final blob = web.Blob(
      jsArray,
      web.BlobPropertyBag(type: 'application/zip'),
    );
    final url = web.URL.createObjectURL(blob);

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = zipFilename;
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  static Widget exampleImageWithLabel(
    String label,
    String assetPath,
    Color borderColor,
    double width,
    double height
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
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

  static Widget imageUploadBox(
    Map<String, Uint8List> images,
    void Function(String) onRemove,
  ) {
    return DottedBorder(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: images.isEmpty
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
                  children: images.entries.map((entry) {
                    final fname = entry.key;
                    final imageData = entry.value;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[200],
                            child: Image.memory(imageData, fit: BoxFit.contain),
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
                              onPressed: () => onRemove(fname),
                              splashRadius: 20,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  static Widget resultImageBox(
    Map<String, Uint8List> images,
    void Function(String, Uint8List) onDownload,
  ) {
    return DottedBorder(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: images.isEmpty
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
                  children: images.entries.map((entry) {
                    final fname = entry.key;
                    final imageData = entry.value;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[200],
                            child: Image.memory(imageData, fit: BoxFit.contain),
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
                              onPressed: () => onDownload(fname, imageData),
                              splashRadius: 20,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  static Widget copyrightFooter() {
    return Container(
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
              textStyle: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
