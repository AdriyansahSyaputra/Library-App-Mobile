import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

// Menggunakan ConsumerWidget agar bisa membaca data Riverpod,
// dan implements PreferredSizeWidget agar dikenali sebagai AppBar oleh Scaffold.
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menarik data user yang sedang login secara real-time
    final userState = ref.watch(currentUserProvider);
    final user = userState.valueOrNull;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          // Logo SMA 6
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Perpus SMA 6',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage:
                user?.fotoProfil != null && user!.fotoProfil.isNotEmpty
                ? NetworkImage(
                    user.fotoProfil,
                  ) // Nanti diganti base64 sesuai rencana
                : null,
            child: user?.fotoProfil == null || user!.fotoProfil.isEmpty
                ? const Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
        ),
      ],
    );
  }

  // Wajib ditambahkan agar Flutter tahu tinggi standar AppBar ini
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
