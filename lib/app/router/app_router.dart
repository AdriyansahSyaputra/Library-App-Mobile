import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_mobile/features/catalog/presentation/pages/catalog_page.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/main_dashboard_page.dart';
import '../../features/catalog/presentation/pages/category_detail_page.dart';
import '../../features/catalog/presentation/pages/book_detail_page.dart';
import '../../features/catalog/providers/book_provider.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/personal_info_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/admin/dashboard/presentation/pages/admin_main_page.dart';
import '../../features/admin/settings/presentation/pages/admin_settings_page.dart';
import '../../features/admin/catalog/presentation/pages/admin_catalog_page.dart';
import '../../features/admin/catalog/presentation/pages/admin_book_detail_page.dart';
import '../../features/admin/catalog/presentation/pages/admin_category_detail_page.dart';
import '../../features/admin/catalog/presentation/pages/admin_add_book_page.dart';

// PROVIDER GOROUTER UTAMA (Sangat Clean & Ringan)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',

    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // 3. AREA SISWA
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
          final namaKategori = state.pathParameters['kategori']!;
          return CategoryDetailPage(categoryName: namaKategori);
        },
      ),
      GoRoute(
        path: '/buku/detail',
        name: AppRoutes.bookDetail,
        builder: (context, state) {
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

      // 4. AREA ADMIN
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminMainPage(),
      ),
      GoRoute(
        path: AppRoutes.adminCatalog,
        builder: (context, state) => const AdminCatalogPage(),
      ),
      GoRoute(
        path: AppRoutes.adminCategoryDetail,
        builder: (context, state) {
          final String categoryName = state.extra as String;
          return AdminCategoryDetailPage(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: AppRoutes.adminBookDetail,
        builder: (context, state) {
          final BookModel bookData = state.extra as BookModel;
          return AdminBookDetailPage(book: bookData);
        },
      ),
      GoRoute(
        path: AppRoutes.adminAddBook,
        builder: (context, state) => const AdminAddBookPage(),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, state) => const AdminSettingsPage(),
      ),
    ],
  );
});
