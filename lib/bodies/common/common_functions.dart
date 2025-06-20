import 'dart:typed_data';
import 'dart:js_interop';
import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommonFunctions {
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
}