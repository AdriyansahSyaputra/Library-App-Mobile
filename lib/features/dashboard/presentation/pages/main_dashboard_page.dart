import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'home_page.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';

// 1. STATE GLOBAL UNTUK MENGONTROL POSISI TAB
final dashboardTabIndexProvider = StateProvider<int>((ref) => 0);

class MainDashboardPage extends ConsumerWidget {
  const MainDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Pantau pergerakan tab secara real-time
    final currentIndex = ref.watch(dashboardTabIndexProvider);

    final List<Widget> pages = [
      const HomePage(),
      const CatalogPage(), // Tab Katalog
      const Center(child: Text('Halaman Riwayat (Segera Hadir)')),
      const Center(child: Text('Halaman Profil (Segera Hadir)')),
    ];

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // 3. Ubah index saat ikon tab ditekan
          ref.read(dashboardTabIndexProvider.notifier).state = index;
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
