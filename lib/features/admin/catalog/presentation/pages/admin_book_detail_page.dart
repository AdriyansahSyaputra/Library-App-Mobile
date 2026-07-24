import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../catalog/providers/book_provider.dart';

class AdminBookDetailPage extends StatelessWidget {
  final BookModel book;

  const AdminBookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = book.status == 'tersedia' && book.stok > 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Detail Buku',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. SAMPUL BUKU & STATUS ---
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 260,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    image: book.sampul.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(book.sampul),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: book.sampul.isEmpty
                      ? const Icon(
                          Icons.menu_book_rounded,
                          size: 80,
                          color: Colors.grey,
                        )
                      : null,
                ),
                // Badge Status
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.successBg
                        : AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAvailable ? 'Tersedia' : 'Dipinjam',
                    style: TextStyle(
                      color: isAvailable
                          ? AppColors.successText
                          : AppColors.dangerText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. JUDUL & PENULIS ---
            Text(
              book.judul,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Oleh: ${book.penulis}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // --- 3. METADATA GRID LENGKAP (Sesuai Database) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(context, 'ISBN', book.isbn),
                  const Divider(),
                  _buildDetailRow(context, 'Kategori', book.kategori),
                  const Divider(),
                  _buildDetailRow(context, 'Lokasi Rak', book.lokasiRak),
                  const Divider(),
                  _buildDetailRow(context, 'Penerbit', book.penerbit),
                  const Divider(),
                  _buildDetailRow(context, 'Tahun Terbit', book.tahunTerbit),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Stok Tersedia',
                    book.stok.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // --- TOMBOL AKSI BAWAH (EDIT & DELETE) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementasi logika hapus / soft delete ke Firebase
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigasi ke form edit buku (context.push('/admin-edit-book', extra: book))
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text(
                    'Edit Data',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget bantuan untuk menampilkan baris data agar kode tetap Clean & DRY
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
