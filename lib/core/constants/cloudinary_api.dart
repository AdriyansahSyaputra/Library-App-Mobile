import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Fungsi utilitas untuk memaksa validasi keberadaan kunci .env
  static String _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw Exception('GAGAL KRITIS: Kunci $key tidak ditemukan di file .env');
    }
    return value.trim(); // Gunakan trim() untuk membersihkan spasi tak terlihat
  }

  static String get cloudinaryCloudName => _getEnv('CLOUDINARY_CLOUD_NAME');
  static String get cloudinaryProfilePreset =>
      _getEnv('CLOUDINARY_PROFILE_PRESET');
  static String get cloudinaryApiKey => _getEnv('CLOUDINARY_API_KEY');
  static String get cloudinaryApiSecret => _getEnv('CLOUDINARY_API_SECRET');
  static String get cloudinaryBookPreset => _getEnv('CLOUDINARY_BOOK_PRESET');

  static String get cloudinaryUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/upload';

  static String get cloudinaryDestroyUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/destroy';
}
