// common_widgets.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';

class CommonWidgets {
  static Widget exampleImageWithLabel(
    String label,
    String assetPath,
    Color borderColor,
    double width,
    double height,
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
