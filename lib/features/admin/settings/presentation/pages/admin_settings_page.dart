import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../../../app/router/app_routes.dart';

class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({super.key});

  Future<void> _prosesLogout(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Keluar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari sesi admin?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!context.mounted) return;

      try {
        // 1. Pindah UI terlebih dahulu (Mematikan listener stream aktif di halaman ini)
        context.go(AppRoutes.login);

        // 2. Jeda waktu untuk animasi transisi selesai
        await Future.delayed(const Duration(milliseconds: 300));

        // 3. Bersihkan memori aplikasi dari data admin yang tersisa
        ref.invalidate(currentUserProvider);

        // 4. Eksekusi Logout Firebase resmi via Controller
        await ref.read(authControllerProvider.notifier).logout();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau status data admin secara real-time
    final userState = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.95),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Terjadi kesalahan: $error')),
        data: (user) {
          // Evaluasi ketersediaan foto dan hak akses
          final String? fotoUrl = user?.fotoProfil;
          final bool hasProfilePicture = fotoUrl != null && fotoUrl.isNotEmpty;
          final bool isHeadAdmin = user?.role == 'head_admin';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- HEADER (Identitas) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 48,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: hasProfilePicture
                            ? NetworkImage(fotoUrl)
                            : null,
                        onBackgroundImageError: hasProfilePicture
                            ? (exception, stackTrace) =>
                                  debugPrint('Gambar gagal dimuat: $exception')
                            : null,
                        child: hasProfilePicture
                            ? null
                            : Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.namaLengkap ?? 'Memuat Nama...',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Memuat Email...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Badge Role Dinamis
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isHeadAdmin
                              ? Colors.purple.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHeadAdmin
                              ? 'Kepala Perpustakaan'
                              : 'Petugas Perpustakaan',
                          style: TextStyle(
                            color: isHeadAdmin
                                ? Colors.purple.shade700
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- KELOMPOK MENU PENGATURAN ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Kategori: Akun & Keamanan
                    _buildSectionTitle(context, 'Akun & Keamanan'),
                    _buildMenuGroup(
                      context,
                      children: [
                        _buildMenuTile(
                          context,
                          title: 'Informasi Akun',
                          subtitle: 'Perbarui profil dan kata sandi',
                          icon: Icons.person_outline,
                          onTap: () {
                            // TODO: Navigasi ke halaman form edit admin & password
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 2. Kategori: Manajemen Operasional
                    _buildSectionTitle(context, 'Manajemen Operasional'),
                    _buildMenuGroup(
                      context,
                      children: [
                        // LOGIKA RBAC: Menu ini HANYA digambar jika role == head_admin
                        if (isHeadAdmin) ...[
                          _buildMenuTile(
                            context,
                            title: 'Kelola Petugas',
                            subtitle: 'Tambah atau hapus hak akses admin',
                            icon: Icons.manage_accounts_outlined,
                            onTap: () {
                              // TODO: Navigasi ke halaman kelola petugas
                            },
                          ),
                          _buildDivider(), // Garis pemisah antar menu
                        ],

                        _buildMenuTile(
                          context,
                          title: 'Log Sistem',
                          subtitle: 'Riwayat aktivitas perpustakaan',
                          icon: Icons.history_rounded,
                          onTap: () {
                            // TODO: Navigasi ke halaman log
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. Kategori: Sistem & Aplikasi
                    _buildSectionTitle(context, 'Sistem'),
                    _buildMenuGroup(
                      context,
                      children: [
                        _buildMenuTile(
                          context,
                          title: 'Informasi Aplikasi',
                          subtitle: 'Sistem Perpustakaan SMA 6 v1.0.0',
                          icon: Icons.info_outline_rounded,
                          onTap: () {
                            // TODO: Tampilkan modal atau halaman about
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 4. Tombol Logout (Berdiri sendiri dengan warna merah)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _prosesLogout(context, ref),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Keluar dari Sistem',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 48,
                    ), // Padding bawah agar tidak tertutup nav bar
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET UTILITAS UNTUK UI CLEAN & DRY (Don't Repeat Yourself) ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16, thickness: 0.5);
  }
}
