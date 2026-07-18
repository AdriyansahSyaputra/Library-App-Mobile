import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';

// JEMBATAN PENGHUBUNG: Memaksa GoRouter merender ulang saat status otentikasi berubah
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Dengarkan perubahan status login dari Firebase Auth
    _ref.listen(authStateChangesProvider, (_, _) => notifyListeners());
    // Dengarkan perubahan data biodata/role dari Realtime Database
    _ref.listen(currentUserProvider, (_, _) => notifyListeners());
  }
}

// PROVIDER GOROUTER UTAMA
final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    refreshListenable: routerNotifier,
    initialLocation: AppRoutes.login,

    // LOGIKA PENGALIHAN CERDAS (REDIRECTION)
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userState = ref.read(currentUserProvider);

      // 1. Jika masih loading data autentikasi, biarkan di halaman saat ini
      if (authState.isLoading) return null;

      final isAuth = authState.valueOrNull != null;
      final isGoingToAuthPage =
          state.uri.toString() == AppRoutes.login ||
          state.uri.toString() == AppRoutes.register ||
          state.uri.toString() == AppRoutes.resetPassword;

      // 2. Jika BELUM login dan mencoba akses halaman dalam, lempar ke Login
      if (!isAuth) {
        return isGoingToAuthPage ? null : AppRoutes.login;
      }

      // 3. Jika Firebase Auth sudah login, tapi biodata (RTDB) masih diunduh
      if (userState.isLoading) return null;

      final user = userState.valueOrNull;

      // 4. Jika SUDAH login penuh dan sedang berada di halaman Login/Register
      if (isAuth && user != null) {
        if (isGoingToAuthPage || state.uri.toString() == '/') {
          return user.role == 'admin'
              ? AppRoutes.adminDashboard
              : AppRoutes.siswaKatalog;
        }
      }

      return null; // Tidak perlu dialihkan (aman)
    },

    // DAFTAR HALAMAN (ROUTES)
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Ini Dashboard Admin (Hanya untuk Admin)')),
        ),
      ),
      GoRoute(
        path: AppRoutes.siswaKatalog,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Ini Halaman Katalog Buku Siswa')),
        ),
      ),
    ],
  );
});
