import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/widgets/book_card.dart'; // Sesuaikan path
import '../../../../catalog/providers/book_provider.dart';

class AdminCatalogPage extends ConsumerStatefulWidget {
  const AdminCatalogPage({super.key});

  @override
  ConsumerState<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends ConsumerState<AdminCatalogPage> {
  final TextEditingController _searchController = TextEditingController();

  // State untuk pencarian dan filter kategori
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsyncValue = ref.watch(booksStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin-add-book'),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Buku Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: booksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (allBooks) {
          // --- 1. EKSTRAKSI KATEGORI DINAMIS ---
          // Mengambil semua kategori yang ada di DB tanpa duplikat
          final Set<String> uniqueCategories = {'Semua'};
          for (var book in allBooks) {
            uniqueCategories.add(book.kategori);
          }
          final categoryList = uniqueCategories.toList();

          // --- 2. LOGIKA FILTER GANDA (Pencarian + Chips Kategori) ---
          final filteredBooks = allBooks.where((book) {
            final matchesSearch =
                book.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                book.penulis.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory =
                _selectedCategory == 'Semua' ||
                book.kategori == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          // --- 3. MENGELOMPOKKAN BUKU (Grouping) ---
          final Map<String, List<BookModel>> booksByCategory = {};
          for (var book in filteredBooks) {
            booksByCategory.putIfAbsent(book.kategori, () => []).add(book);
          }
          final categories = booksByCategory.keys.toList()..sort();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- SEKSI 1: SEARCH BAR DENGAN BORDER TEGAS ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, atau ISBN...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),

                      // Border saat tidak fokus (tampak tipis namun jelas)
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      // Border saat diklik/fokus (tebal dan berwarna primer)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),

              // --- SEKSI 2: CHIPS KATEGORI HORIZONTAL ---
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44, // Ketinggian spesifik agar chips pas
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      final category = categoryList[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          side: isSelected
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // --- SEKSI 3: DAFTAR KATEGORI DAN BUKU ---
              if (filteredBooks.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Buku tidak ditemukan.')),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final categoryName = categories[index];
                    final categoryBooks = booksByCategory[categoryName]!;
                    return _buildCategorySection(
                      context,
                      categoryName,
                      categoryBooks,
                    );
                  }, childCount: categories.length),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  // (Fungsi _buildCategorySection tetap sama persis seperti kode Anda sebelumnya)
  Widget _buildCategorySection(
    BuildContext context,
    String categoryName,
    List<BookModel> books,
  ) {
    final displayBooks = books.length > 15 ? books.sublist(0, 15) : books;
    final bool hasMore = books.length > 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (hasMore)
                TextButton(
                  onPressed: () => context.push(
                    '/admin-category-detail',
                    extra: categoryName,
                  ),
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayBooks.length,
            itemBuilder: (context, index) {
              final book = displayBooks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => context.push('/admin-book-detail', extra: book),
                  child: SizedBox(
                    width: 140,
                    child: BookCardWidget(book: book),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
