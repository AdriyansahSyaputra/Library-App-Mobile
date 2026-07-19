import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/book_provider.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  final BookModel book;
  const BookDetailPage({super.key, required this.book});

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  bool _isLoading = false;

  // State lokal untuk melacak apakah user baru saja klik pinjam di sesi ini
  bool _hasBorrowed = false;

  void _executeBorrow() async {
    if (widget.book.stok <= 0) return;

    setState(() => _isLoading = true);

    try {
      // Menjalankan fungsi kurangi stok di Firebase
      await ref
          .read(bookServiceProvder)
          .borrowBook(widget.book.id, widget.book.stok);

      // Memicu perubahan UI tombol dan stok secara instan
      setState(() => _hasBorrowed = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Berhasil meminjam buku! Silakan ambil di perpustakaan.',
            ),
            backgroundColor: AppColors.successText,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppColors.dangerText,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Kalkulasi Data Real-Time di Layar
    // Jika user sudah klik pinjam, kurangi tampilan stok di layar sebanyak 1
    final int displayStock = widget.book.stok - (_hasBorrowed ? 1 : 0);

    // Status visual: jika stok visual habis atau user menekan pinjam, status menjadi 'dipinjam'
    final String displayStatus = (displayStock <= 0 || _hasBorrowed)
        ? 'Dipinjam'
        : 'Tersedia';

    // Kunci tombol: Tombol aktif JIKA stok > 0 DAN user belum menekan tombol pinjam
    final bool canBorrow = widget.book.stok > 0 && !_hasBorrowed;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Buku',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Placeholder
            Center(
              child: Container(
                width: 160,
                height: 240,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Judul & Penulis
            Text(
              widget.book.judul,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Oleh: ${widget.book.penulis}",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Susunan Data Lengkap
            _buildInfoRow('ISBN', widget.book.isbn),
            _buildInfoRow('Kategori', widget.book.kategori),
            _buildInfoRow('Tahun Terbit', widget.book.tahunTerbit),
            _buildInfoRow('Penerbit', widget.book.penerbit),
            _buildInfoRow('Lokasi Rak', widget.book.lokasiRak),

            // Highlight Status & Stok
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: displayStatus == 'Tersedia'
                          ? AppColors.successBg
                          : AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: displayStatus == 'Tersedia'
                            ? AppColors.successText
                            : AppColors.dangerText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildInfoRow(
              'Sisa Stok',
              displayStock > 0 ? displayStock.toString() : 'Habis (0)',
            ),

            const SizedBox(height: 48),

            // TOMBOL PINJAM (Dengan Logika Disable)
            ElevatedButton(
              onPressed: canBorrow && !_isLoading ? _executeBorrow : null,
              style: ElevatedButton.styleFrom(
                // Tombol menjadi abu-abu jika canBorrow bernilai false
                backgroundColor: canBorrow
                    ? AppColors.primary
                    : Colors.grey.withValues(alpha: 0.3),
                disabledBackgroundColor: Colors.grey.withValues(
                  alpha: 0.3,
                ), // Fallback warna disable Material 3
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      // Perubahan teks dinamis
                      _hasBorrowed
                          ? 'Sedang Dipinjam'
                          : (widget.book.stok > 0
                                ? 'Pinjam Buku Ini'
                                : 'Stok Habis'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Komponen pembantu untuk merender baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
