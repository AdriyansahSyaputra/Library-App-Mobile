import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/widgets/book_card.dart';
import '../../../../catalog/providers/book_provider.dart';

class AdminCategoryDetailPage extends ConsumerWidget {
  final String categoryName;

  const AdminCategoryDetailPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Kategori: $categoryName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: booksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allBooks) {
          // Filter buku hanya untuk kategori yang dipilih
          final categoryBooks = allBooks
              .where((book) => book.kategori == categoryName)
              .toList();

          if (categoryBooks.isEmpty) {
            return const Center(child: Text('Kategori kosong.'));
          }

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 kolom sejajar
              childAspectRatio: 0.65, // Rasio portrait
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categoryBooks.length,
            itemBuilder: (context, index) {
              final book = categoryBooks[index];
              return GestureDetector(
                onTap: () => context.push('/admin-book-detail', extra: book),
                child: BookCardWidget(
                  book: book,
                ), // Menggunakan widget kustom Anda
              );
            },
          );
        },
      ),
    );
  }
}
