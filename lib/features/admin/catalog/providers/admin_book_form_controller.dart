import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/constants/cloudinary_api.dart';
import '../../../../data/services/cloudinary_service.dart';

// 1. Controller Provider
final bookFormControllerProvider =
    StateNotifierProvider<BookFormController, AsyncValue<void>>((ref) {
      return BookFormController();
    });

class BookFormController extends StateNotifier<AsyncValue<void>> {
  BookFormController() : super(const AsyncValue.data(null));

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('books');

  // ==========================================
  // LOGIKA KOMPRESI GAMBAR (Optimalisasi Memori)
  // ==========================================
  Future<File?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final outPath =
        "${filePath.substring(0, filePath.lastIndexOf('.'))}_compressed.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 60, // Kualitas optimal, ukuran file ringan
      minWidth: 480,
      minHeight: 640,

      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  // ==========================================
  // FUNGSI 1: TAMBAH BUKU BARU
  // ==========================================
  Future<void> submitNewBook({
    required File imageFile,
    required String judul,
    required String penulis,
    required String penerbit,
    required String kategori,
    required String isbn,
    required String tahunTerbit,
    required String lokasiRak,
    required String stok,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Kompresi Gambar
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) throw Exception("Gagal mengompresi gambar.");

      // 2. Upload ke Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(
        compressedImage,
        uploadPreset: ApiConstants.cloudinaryBookPreset,
      );

      if (imageUrl == null) throw Exception("Gagal mendapatkan URL gambar.");

      // 3. Simpan ke Firebase
      final newBookData = {
        'judul': judul,
        'penulis': penulis,
        'penerbit': penerbit,
        'kategori': kategori,
        'isbn': isbn,
        'tahun_terbit': tahunTerbit,
        'lokasi_rak': lokasiRak,
        'stok': stok,
        'sampul': imageUrl,
        'status': 'tersedia',
        'tgl_input': DateTime.now().toIso8601String(),
      };

      await _dbRef.push().set(newBookData);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ==========================================
  // FUNGSI 2: EDIT / UPDATE BUKU (Hapus Sampul Lama)
  // ==========================================
  Future<void> updateBook({
    required String bookId,
    required String oldImageUrl,
    File? newImageFile,
    required String judul,
    required String penulis,
    required String penerbit,
    required String kategori,
    required String isbn,
    required String tahunTerbit,
    required String lokasiRak,
    required String stok,
  }) async {
    state = const AsyncValue.loading();
    try {
      String finalImageUrl = oldImageUrl;

      // Jika admin mengunggah gambar baru
      if (newImageFile != null) {
        final compressedImage = await _compressImage(newImageFile);
        if (compressedImage == null) {
          throw Exception("Gagal mengompresi gambar baru.");
        }

        final uploadedUrl = await CloudinaryService.uploadImage(
          compressedImage,
          uploadPreset: ApiConstants.cloudinaryBookPreset,
        );

        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
          // Hapus gambar lama dari Cloudinary
          await CloudinaryService.deleteImage(oldImageUrl);
        }
      }

      // Update data di Firebase
      final updatedData = {
        'judul': judul,
        'penulis': penulis,
        'penerbit': penerbit,
        'kategori': kategori,
        'isbn': isbn,
        'tahun_terbit': tahunTerbit,
        'lokasi_rak': lokasiRak,
        'stok': stok,
        'sampul': finalImageUrl,
      };

      await _dbRef.child(bookId).update(updatedData);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
