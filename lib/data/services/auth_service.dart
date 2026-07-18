import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i("Login sukses: ${credential.user?.email}");
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e("Login gagal (Firebase): ${e.code}");

      // Menerjemahkan kode error Firebase ke bahasa awam
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage = 'Email atau kata sandi yang Anda masukkan salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Akun ini telah dinonaktifkan oleh Admin.';
          break;
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak percobaan gagal. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      _logger.e("Login gagal (Umum): $e");
      throw Exception("Terjadi kesalahan yang tidak diketahui.");
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i("Registrasi sukses: ${credential.user?.email}");
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e("Registrasi gagal: ${e.message}");
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _logger.i("User berhasil logout");
  }

  // Fungsi mengirim email tautan reset sandi
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i("Tautan reset sandi berhasil dikirim ke $email");
    } on FirebaseAuthException catch (e) {
      _logger.e("Gagal kirim reset sandi: ${e.message}");
      throw Exception(e.message); // Lempar pesan error mentah ke UI
    }
  }
}
