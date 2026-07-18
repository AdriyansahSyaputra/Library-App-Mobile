import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';

// StateNotifier untuk mengontrol status UI (Loading, Data, atau Error)
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final DatabaseService _dbService;

  AuthController(this._authService, this._dbService)
    : super(const AsyncValue.data(null));

  // Fungsi Eksekusi Login
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading(); // UI otomatis berputar (loading)
    try {
      await _authService.signIn(email, password);
      state = const AsyncValue.data(null); // UI sukses
    } catch (e, st) {
      state = AsyncValue.error(e, st); // UI memunculkan pesan error
    }
  }

  // Fungsi Eksekusi Registrasi Siswa Baru
  Future<void> registerSiswa({
    required String email,
    required String password,
    required String nis,
    required String namaLengkap,
    required String kelas,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Daftarkan kredensial ke Firebase Auth (Fungsi ini harus ditambahkan di AuthService nanti)
      final userCredential = await _authService.register(email, password);

      if (userCredential?.user != null) {
        // 2. Jika sukses, simpan biodata lengkap ke Realtime Database
        final userData = {
          'nis': nis,
          'email': email,
          'nama_lengkap': namaLengkap,
          'kelas': kelas,
          'role': 'siswa', // Default role untuk pendaftaran publik
          'foto_profil': '',
        };

        await _dbService.saveUserData(userCredential!.user!.uid, userData);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Fungsi Eksekusi Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Fungsi memicu layanan reset
  Future<bool> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordReset(email);
      state = const AsyncValue.data(null);
      return true; // Mengembalikan true jika sukses agar UI bisa memunculkan dialog sukses
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
