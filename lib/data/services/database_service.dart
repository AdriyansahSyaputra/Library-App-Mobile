import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final Logger _logger = Logger();

  // Menyimpan data pengguna baru setelah registrasi
  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _db.child('users').child(uid).set(data);
      _logger.i("Data user $uid berhasil disimpan ke RTDB");
    } catch (e) {
      _logger.e("Gagal menyimpan data user: $e");
      throw Exception('Gagal menghubungi database');
    }
  }

  // Mengambil koleksi seluruh buku untuk algoritma KMP nantinya
  Future<Map<String, dynamic>?> getAllBuku() async {
    try {
      final snapshot = await _db.child('buku').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      _logger.e("Gagal menarik data buku: $e");
      throw Exception('Gagal menarik katalog buku');
    }
  }

  // Menarik data detail pengguna berdasarkan UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _db.child('users').child(uid).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      _logger.e("Gagal menarik data user: $e");
      throw Exception('Gagal memuat profil pengguna');
    }
  }
}
