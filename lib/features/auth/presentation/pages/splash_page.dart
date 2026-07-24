import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/router/app_routes.dart';
import '../../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // 1. Beri waktu agar animasi splash screen tampil estetik
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;

    // Jika di memori lokal tidak ada token, langsung lempar ke Login
    if (firebaseUser == null) {
      context.go(AppRoutes.login);
      return;
    }

    try {
      // 2. Tarik data Role langsung secara independen.
      final dbService = ref.read(databaseServiceProvider);
      final userDataMap = await dbService.getUserData(firebaseUser.uid);

      if (!mounted) return;

      if (userDataMap != null) {
        // Ambil string role secara eksplisit
        final role = userDataMap['role'] as String?;

        // Segarkan data provider di latar belakang agar UI lainnya bersih
        ref.invalidate(currentUserProvider);

        // 3. Eksekusi Navigasi Presisi
        if (role == 'admin' || role == 'head_admin') {
          context.go(AppRoutes.adminDashboard);
        } else {
          context.go(AppRoutes.siswaDashboard);
        }
      } else {
        // Jika user ada di Auth, tapi datanya terhapus di RTDB, bersihkan paksa.
        await FirebaseAuth.instance.signOut();
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (e) {
      // Jika terjadi error fatal (tidak ada koneksi sama sekali), amankan aplikasi
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_library_rounded, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Menyiapkan Ruang Baca...',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
