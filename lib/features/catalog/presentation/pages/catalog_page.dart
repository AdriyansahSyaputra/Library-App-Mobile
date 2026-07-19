import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app/router/app_routes.dart'; // Sesuaikan lokasi app_routes Anda
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/book_card.dart';
import '../../../../core/utils/kmp_algorithm.dart';
import '../../providers/book_provider.dart';
import '../../../dashboard/presentation/pages/home_page.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();

  // Menambahkan FocusNode untuk menangkap lemparan kursor dari Dashboard
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Wajib di-dispose agar tidak memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cek apakah saklar fokus dari dasbor sedang menyala (true)
      if (ref.read(searchAutoFocusProvider)) {
        _searchFocusNode.requestFocus();
        // Matikan kembali saklarnya agar kursor tidak mengunci terus-menerus
        ref.read(searchAutoFocusProvider.notifier).state = false;
      }
    });

    // 2. TARIK DATA BUKU DARI FIREBASE REAL-TIME
    final booksAsyncValue = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: booksAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(child: Text('Terjadi Kesalahan: $err')),
        data: (allBooks) {
          // 3. EKSTRAKSI KATEGORI DINAMIS
          final Set<String> uniqueCategories = {'Semua'};
          for (var book in allBooks) {
            // Hindari memasukkan kategori kosong atau null
            if (book.kategori.isNotEmpty && book.kategori != '-') {
              uniqueCategories.add(book.kategori);
            }
          }
          final List<String> kategoriChips = uniqueCategories.toList();

          // 4. IMPLEMENTASI ALGORITMA KMP (Real-time Filtering)
          final searchedBooks = allBooks.where((book) {
            final keyword = _searchController.text.trim();
            if (keyword.isEmpty)
              return true; // Tampilkan semua jika kotak pencarian kosong

            // Mencocokkan dengan Algoritma Knuth-Morris-Pratt
            bool matchTitle = KMPAlgorithm.search(book.judul, keyword);
            bool matchAuthor = KMPAlgorithm.search(book.penulis, keyword);

            return matchTitle || matchAuthor;
          }).toList();

          // 5. PENENTUAN BARIS KATEGORI YANG AKAN DI-RENDER
          final displayCategories = _selectedCategory == 'Semua'
              ? kategoriChips.where((c) => c != 'Semua').toList()
              : [_selectedCategory];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // BAGIAN 1: SEARCH BAR KMP
              // ==========================================
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: TextField(
                  focusNode: _searchFocusNode, // Menempelkan node fokus
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari dengan algoritma KMP...',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {}); // Segarkan UI saat dibersihkan
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // ==========================================
              // BAGIAN 2: FILTER KATEGORI (CHIPS)
              // ==========================================
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: kategoriChips.length,
                  itemBuilder: (context, index) {
                    final category = kategoriChips[index];
                    final isActive = _selectedCategory == category;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // BAGIAN 3: KORSEL BUKU BERDASARKAN KATEGORI
              // ==========================================
              Expanded(
                child: searchedBooks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayCategories.length,
                        itemBuilder: (context, index) {
                          final kategori = displayCategories[index];

                          // Filter buku berdasarkan kategori baris ini
                          final bukuKategoriIni = searchedBooks
                              .where((book) => book.kategori == kategori)
                              .toList();

                          // Jika kosong (karena filter teks KMP), sembunyikan baris ini
                          if (bukuKategoriIni.isEmpty)
                            return const SizedBox.shrink();

                          // Logika Pembatasan Max 15 Buku
                          final bool isMoreThan15 = bukuKategoriIni.length > 15;
                          final displayBooks = isMoreThan15
                              ? bukuKategoriIni.take(15).toList()
                              : bukuKategoriIni;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // HEADER KATEGORI & TOMBOL TAMPILKAN SEMUA
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        kategori.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                      ),
                                      if (isMoreThan15)
                                        TextButton(
                                          onPressed: () {
                                            // Pindah ke halaman Category Detail via GoRouter Path Parameters
                                            context.pushNamed(
                                              AppRoutes.kategoriDetail,
                                              pathParameters: {
                                                'kategori': kategori,
                                              },
                                            );
                                          },
                                          child: const Text(
                                            'Tampilkan Semua',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // RENDER KARTU BUKU HORIZONTAL
                                SizedBox(
                                  height: 250,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    itemCount: displayBooks.length,
                                    itemBuilder: (context, idx) {
                                      final book = displayBooks[idx];
                                      return GestureDetector(
                                        onTap: () {
                                          // Pindah ke detail buku via GoRouter Extra Parameters
                                          context.pushNamed(
                                            AppRoutes.bookDetail,
                                            extra: book,
                                          );
                                        },
                                        // Pemanggilan Widget Reusable
                                        child: Container(
                                          width:
                                              140, // Paksa lebar 140 agar sejajar di Horizontal Scroll
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: BookCardWidget(book: book),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Tampilan ketika buku tidak ditemukan oleh KMP
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Literatur tidak ditemukan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kata kunci tidak cocok pada judul maupun penulis.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
