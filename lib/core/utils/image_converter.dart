import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageConverter {
  /// Mengubah file gambar fisik menjadi String Base64 yang sudah dikompresi
  static Future<String> fileToBase64(File file) async {
    // 1. Kompresi gambar terlebih dahulu agar ukuran teks di database tidak membengkak
    final Uint8List? compressedBytes =
        await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: 200,
          minHeight: 200,
          quality: 70, // Menjaga ukuran tetap di bawah 100KB
        );

    if (compressedBytes == null) throw Exception("Gagal memproses gambar");

    // 2. Ubah byte array menjadi String Base64 siap simpan
    return base64Encode(compressedBytes);
  }

  /// Mengubah String Base64 dari database kembali menjadi objek Image UI
  static Uint8List base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }
}
