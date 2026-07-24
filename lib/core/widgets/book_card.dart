import 'package:flutter/material.dart';
import 'package:library_mobile/features/catalog/providers/book_provider.dart';
import '../constants/app_colors.dart';

class BookCardWidget extends StatelessWidget {
  final BookModel book;

  const BookCardWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = book.status == 'tersedia' && book.stok > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: book.sampul.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(book.sampul),
                          fit: BoxFit
                              .cover, // Gambar dipotong menyesuaikan kotak
                        )
                      : null,
                ),
                child: book.sampul.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.successBg
                        : AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAvailable ? 'Tersedia' : 'Dipinjam',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAvailable
                          ? AppColors.successText
                          : AppColors.dangerText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          book.judul,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          book.penulis,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
