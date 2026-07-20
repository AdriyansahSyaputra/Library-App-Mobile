import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_mobile/features/catalog/presentation/pages/catalog_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/dashboard/presentation/pages/main_dashboard_page.dart';
import '../../features/catalog/presentation/pages/category_detail_page.dart';
import '../../features/catalog/presentation/pages/book_detail_page.dart';
import '../../features/catalog/providers/book_provider.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/personal_info_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';

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
              : AppRoutes.siswaDashboard;
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
        path: AppRoutes.siswaDashboard,
        builder: (context, state) => const MainDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.catalogSiswa,
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/kategori/:kategori',
        name: AppRoutes.kategoriDetail,
        builder: (context, state) {
          // Menangkap parameter kategori dari URL
          final namaKategori = state.pathParameters['kategori']!;
          return CategoryDetailPage(categoryName: namaKategori);
        },
      ),
      GoRoute(
        path: '/buku/detail',
        name: AppRoutes.bookDetail,
        builder: (context, state) {
          // Menangkap objek buku yang dikirim via parameter extra
          final book = state.extra as BookModel;
          return BookDetailPage(book: book);
        },
      ),
      GoRoute(
        path: AppRoutes.profileSiswa,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (context, state) => const PersonalInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Ini Dashboard Admin (Hanya untuk Admin)')),
        ),
      ),
    ],
  );
});
