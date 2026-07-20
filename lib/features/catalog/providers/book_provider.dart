import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

// 1. MODEL BUKU
class BookModel {
  final String id;
  final String isbn;
  final String judul;
  final String penulis;
  final String kategori;
  final String tahunTerbit;
  final String status;
  final int stok;
  final String sampul;
  final String lokasiRak;
  final String penerbit;

  BookModel({
    required this.id,
    required this.isbn,
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.tahunTerbit,
    required this.status,
    required this.stok,
    required this.sampul,
    required this.lokasiRak,
    required this.penerbit,
  });

  factory BookModel.fromMap(String key, Map<dynamic, dynamic> map) {
    int parsedStok = int.tryParse(map['stok'].toString()) ?? 0;

    return BookModel(
      id: key,
      isbn: map['isbn']?.toString() ?? '-',
      judul: map['judul']?.toString() ?? 'Tanpa Judul',
      penulis: map['penulis']?.toString() ?? 'Tanpa Penulis',
      kategori: map['kategori']?.toString() ?? 'Lainnya',
      tahunTerbit: map['tahun_terbit']?.toString() ?? '-',
      status: map['status']?.toString() ?? 'tersedia',
      stok: parsedStok,
      sampul: map['sampul']?.toString() ?? '',
      lokasiRak: map['lokasi_rak']?.toString() ?? '-',
      penerbit: map['penerbit']?.toString() ?? '-',
    );
  }
}

// 2. SERVICE FIREBASE
class BookService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'books',
  ); // Sesuai nama JSON Anda

  Stream<List<BookModel>> streamBooks() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        return BookModel.fromMap(
          e.key.toString(),
          e.value as Map<dynamic, dynamic>,
        );
      }).toList();
    });
  }

  // Logika Transaksi Peminjaman Sederhana
  Future<void> borrowBook(String bookId, int currentStock) async {
    final newStock = currentStock - 1;
    final newStatus = newStock <= 0 ? 'dipinjam' : 'tersedia';

    await _dbRef.child(bookId).update({
      'stok': newStock
          .toString(), // Disimpan sebagai String mengikuti skema awal JSON
      'status': newStatus,
    });
  }
}

// 3. PROVIDER RIVERPOD
final bookServiceProvder = Provider((ref) => BookService());
final booksStreamProvider = StreamProvider<List<BookModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;

  if (user == null) {
    return Stream.value([]);
  }
  
  return ref.watch(bookServiceProvder).streamBooks();
});
