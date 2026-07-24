import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../catalog/providers/book_provider.dart'; // Untuk membersihkan cache buku
import '../../../dashboard/presentation/pages/main_dashboard_page.dart'; // Untuk mereset tab

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi perpustakaan?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerBg,
              foregroundColor: AppColors.dangerText,
              elevation: 0,
            ),
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;

      try {
        // 1. Pindah Halaman
        context.go(AppRoutes.login);
        await Future.delayed(const Duration(milliseconds: 300));

        // 2. Pembersihan Cache Ekstensif
        ref.read(dashboardTabIndexProvider.notifier).state =
            0; // Reset tab bawah
        ref.invalidate(booksStreamProvider); // Hapus cache buku siswa
        ref.invalidate(currentUserProvider); // Hapus profil

        // 3. Eksekusi Logout
        await ref.read(authControllerProvider.notifier).logout();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: AppColors.dangerBg,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tarik data user secara real-time
    final userState = ref.watch(currentUserProvider);
    final user = userState.valueOrNull;
    final String? fotoUrl = user?.fotoProfil;
    final bool hasProfilePicture = fotoUrl != null && fotoUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.95), // Latar sedikit abu
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // --- HEADER: FOTO PROFIL & IDENTITAS SIngkat ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: hasProfilePicture
                        ? NetworkImage(fotoUrl)
                        : null,
                    onBackgroundImageError: hasProfilePicture
                        ? (exception, stackTrace) {
                            debugPrint('Gagal memuat foto: $exception');
                          }
                        : null,
                    child: hasProfilePicture
                        ? null
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.namaLengkap ?? 'Nama Siswa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NIS: ${user?.nis ?? '999999'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- MENU GROUP 1: Pengaturan Akun ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Informasi Pribadi',
                      onTap: () {
                        context.push(AppRoutes.personalInfo);
                      },
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.1),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _ProfileMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Ganti Password',
                      onTap: () {
                        context.push(AppRoutes.changePassword);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- MENU GROUP 2: Sistem ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _ProfileMenuItem(
                  icon: Icons.info_outline,
                  title: 'Informasi Aplikasi',
                  onTap: () {
                    // Tampilkan dialog informasi aplikasi (contoh)
                    showAboutDialog(
                      context: context,
                      applicationName: 'Perpustakaan SMA 6',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 Iqbal & Tim',
                      applicationIcon: const Icon(
                        Icons.local_library,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- MENU GROUP 3: Aksi Destruktif (Logout) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.dangerBg.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: AppColors.dangerText,
                  iconColor: AppColors.dangerText,
                  hideArrow:
                      true, // Panah disembunyikan karena ini bukan navigasi halaman
                  onTap: () => _handleLogout(context, ref),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET BANTUAN: Item Menu Profil
// Diletakkan di file yang sama (atau bisa dipindah ke core/widgets)
// ==========================================
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool hideArrow;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.hideArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: hideArrow
          ? null
          : Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }
}
