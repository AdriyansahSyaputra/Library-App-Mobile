import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/book_card.dart'; // Widget reusable kita
import '../../../auth/providers/auth_provider.dart';
import '../../../catalog/providers/book_provider.dart';
import '../pages/main_dashboard_page.dart'; 

// Provider pemicu agar search bar di halaman katalog otomatis aktif
final searchAutoFocusProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final user = userState.valueOrNull;

    // Menarik aliran data buku secara real-time
    final booksAsyncValue = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GREETING SECTION (Dipertahankan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.namaLengkap ?? 'Siswa',
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. SEARCH BAR (Navigasi + Pemicu Fokus)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  // Memicu state agar halaman katalog tahu user datang dari sini
                  ref.read(searchAutoFocusProvider.notifier).state = true;

                  // Navigasi ke halaman katalog (Asumsi Anda pakai GoRouter untuk pindah tab/halaman)
                  // Sesuaikan dengan struktur BottomNavigationBar Anda (misal context.go('/katalog'))
                  ref.read(dashboardTabIndexProvider.notifier).state = 1;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.01),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cari literatur atau penulis...',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // KATEGORI KOLEKSI TELAH DIHAPUS SESUAI PERMINTAAN
            const SizedBox(height: 32),

            // 3. KOLEKSI BARU DITAMBAHKAN (Grid 20 Buku)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Baru Ditambahkan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Render Grid Berdasarkan Data Asli
            booksAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allBooks) {
                // Logika Algoritma: Membalikkan urutan list untuk mendapat data terbaru,
                // lalu membatasinya maksimal 20 item.
                final recentBooks = allBooks.reversed.take(20).toList();

                if (recentBooks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Belum ada koleksi buku.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  // KUNCI ARSITEKTUR: shrinkWrap dan NeverScrollable mencegah bentrok dengan SingleChildScrollView
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: recentBooks.length,
                  itemBuilder: (context, index) {
                    final book = recentBooks[index];
                    return GestureDetector(
                      onTap: () {
                        // Menggunakan rute yang sama persis dengan katalog
                        context.pushNamed(AppRoutes.bookDetail, extra: book);
                      },
                      child: BookCardWidget(
                        book: book,
                      ), // Pemanggilan UI yang bersih
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
