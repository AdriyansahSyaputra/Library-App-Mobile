import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/widgets/book_card.dart';
import '../../providers/book_provider.dart';

class CategoryDetailPage extends ConsumerWidget {
  final String categoryName;
  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kategori: $categoryName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: booksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allBooks) {
          final categoryBooks = allBooks
              .where((b) => b.kategori == categoryName)
              .toList();

          if (categoryBooks.isEmpty) {
            return const Center(child: Text('Tidak ada buku di kategori ini.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: categoryBooks.length,
            itemBuilder: (context, index) {
              final book = categoryBooks[index];
              return GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoutes.bookDetail, extra: book);
                },
                child: BookCardWidget(book: book),
              );
            },
          );
        },
      ),
    );
  }
}
