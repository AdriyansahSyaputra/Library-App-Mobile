import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // Wajib ada untuk algoritma SHA-1
import '../../../core/constants/cloudinary_api.dart';

class CloudinaryService {
  /// Mengunggah gambar ke Cloudinary dan mengembalikan URL-nya
  static Future<String?> uploadImage(
    File imageFile, {
    required String uploadPreset,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.cloudinaryUploadUrl);

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final jsonMap = jsonDecode(String.fromCharCodes(responseData));
        return jsonMap['secure_url']; // URL HTTPS aman yang baru
      } else {
        throw Exception(
          'Gagal mengunggah gambar. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan unggah Cloudinary: $e');
    }
  }

  /// Menghapus gambar lama dari Cloudinary secara permanen (Destroy)
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // 1. Ekstrak public_id dari URL lama
      final publicId = _extractPublicId(imageUrl);
      if (publicId.isEmpty) return false;

      // 2. Siapkan parameter untuk tanda tangan keamanan (Signature)
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();
      final apiSecret = ApiConstants.cloudinaryApiSecret;
      final apiKey = ApiConstants.cloudinaryApiKey;

      // 3. Buat Signature SHA-1 (Aturan Cloudinary: public_id=<id>&timestamp=<waktu><api_secret>)
      final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final bytes = utf8.encode(stringToSign);
      final signature = sha1.convert(bytes).toString();

      // 4. Tembak request POST ke endpoint destroy
      final response = await http.post(
        Uri.parse(ApiConstants.cloudinaryDestroyUrl),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      final responseData = jsonDecode(response.body);

      // Jika hasil kembaliannya 'ok', berarti file sukses terhapus dari server
      return responseData['result'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  /// Helper Internal: Mengekstrak public_id (nama folder + file) dari URL Cloudinary
  static String _extractPublicId(String url) {
    try {
      // Pecah URL berdasarkan kata '/upload/'
      final parts = url.split('/upload/');
      if (parts.length < 2) return '';

      final pathWithVersion = parts[1];
      final pathParts = pathWithVersion.split('/');

      // Deteksi dan buang string versi (contoh: v1612345678/) jika Cloudinary menambahkannya
      if (pathParts[0].startsWith('v') && pathParts[0].length > 5) {
        pathParts.removeAt(0);
      }

      final fullPath = pathParts.join('/');

      // Buang ekstensi (.jpg, .png, .webp) di akhir kalimat
      final lastDot = fullPath.lastIndexOf('.');
      return lastDot != -1 ? fullPath.substring(0, lastDot) : fullPath;
    } catch (e) {
      return '';
    }
  }
}
