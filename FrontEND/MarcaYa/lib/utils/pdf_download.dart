import 'dart:typed_data';

import 'pdf_download_stub.dart'
    if (dart.library.html) 'pdf_download_web.dart' as platform;

Future<bool> downloadPdfBytes({
  required String filename,
  required Uint8List bytes,
}) {
  return platform.downloadPdfBytes(filename: filename, bytes: bytes);
}
