import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String idUser;
  final String nis;
  final String email;
  final String namaLengkap;
  final String kelas;
  final String role; // 'admin' atau 'siswa'
  final String fotoProfil;

  const UserModel({
    required this.idUser,
    required this.nis,
    required this.email,
    required this.namaLengkap,
    required this.kelas,
    required this.role,
    this.fotoProfil = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      idUser: id,
      nis: map['nis'] ?? '',
      email: map['email'] ?? '',
      namaLengkap: map['nama_lengkap'] ?? '',
      kelas: map['kelas'] ?? '',
      role: map['role'] ?? 'siswa',
      fotoProfil: map['fotoProfil'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nis': nis,
      'email': email,
      'nama_lengkap': namaLengkap,
      'kelas': kelas,
      'role': role,
      'fotoProfil': fotoProfil,
    };
  }

  @override
  List<Object?> get props => [
    idUser,
    nis,
    email,
    namaLengkap,
    kelas,
    role,
    fotoProfil,
  ];
}
