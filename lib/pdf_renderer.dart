import 'dart:developer';

import 'package:flutter/services.dart';

class PdfRenderer {
  static const MethodChannel _channel = MethodChannel('pdf_renderer');

  static Future<int> getPageCount(String filePath) async {
    final int pageCount = await _channel.invokeMethod('getPageCount', filePath);
    return pageCount;
  }

  static Future<List<Object?>> renderPage(
      String filePath, int pageNumber) async {
    try {
      var result = await _channel.invokeMethod('renderPage', {
        'filePath': filePath,
        'pageNumber': pageNumber,
      });
      log(result.toString());
      return result;
    } catch (e) {
      throw Exception();
    }
  }
}
