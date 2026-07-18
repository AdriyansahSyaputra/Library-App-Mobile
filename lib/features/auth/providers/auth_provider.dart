import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/user_model.dart';
import 'auth_controller.dart';

// 1. Injeksi Dependensi Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

// 2. Injeksi Controller agar bisa dipanggil dari tombol UI
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final authService = ref.watch(authServiceProvider);
      final dbService = ref.watch(databaseServiceProvider);
      return AuthController(authService, dbService);
    });

// 3. StreamProvider: Sensor otomatis yang mendeteksi apakah ada user yang sedang login
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// 4. FutureProvider: Menarik biodata lengkap (termasuk Role) dari RTDB berdasarkan UID yang login
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // Pantau sensor authStateChangesProvider
  final firebaseUser = ref.watch(authStateChangesProvider).value;

  // Jika tidak ada yang login, kembalikan null
  if (firebaseUser == null) return null;

  // Jika ada yang login, tarik datanya dari Realtime Database
  final dbService = ref.watch(databaseServiceProvider);
  final userDataMap = await dbService.getUserData(firebaseUser.uid);

  if (userDataMap != null) {
    return UserModel.fromMap(userDataMap, firebaseUser.uid);
  }
  return null;
});
