import 'package:equatable/equatable.dart';

class BukuModel extends Equatable {
  final String idBuku;
  final String judulBuku;
  final String namaPengarang;
  final String namaPenerbit;
  final int tahunTerbit;
  final String lokasiRak;
  final int jumlahStok;

  const BukuModel({
    required this.idBuku,
    required this.judulBuku,
    required this.namaPengarang,
    required this.namaPenerbit,
    required this.tahunTerbit,
    required this.lokasiRak,
    required this.jumlahStok,
  });

  factory BukuModel.fromMap(Map<String, dynamic> map, String id) {
    return BukuModel(
      idBuku: id,
      judulBuku: map['judul_buku'] ?? '',
      namaPengarang: map['nama_pengarang'] ?? '',
      namaPenerbit: map['nama_penerbit'] ?? '',
      tahunTerbit: map['tahun_terbit']?.toInt() ?? 0,
      lokasiRak: map['lokasi_rak'] ?? '',
      jumlahStok: map['jumlah_stok']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul_buku': judulBuku,
      'nama_pengarang': namaPengarang,
      'nama_penerbit': namaPenerbit,
      'tahun_terbit': tahunTerbit,
      'lokasi_rak': lokasiRak,
      'jumlah_stok': jumlahStok,
    };
  }

  @override
  List<Object?> get props => [
    idBuku,
    judulBuku,
    namaPengarang,
    namaPenerbit,
    tahunTerbit,
    lokasiRak,
    jumlahStok,
  ];
}
