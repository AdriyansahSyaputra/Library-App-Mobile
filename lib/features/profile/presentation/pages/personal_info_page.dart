import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/cloudinary_api.dart';
import '../../../../../data/services/cloudinary_service.dart';
import '../../../auth/providers/auth_provider.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _nisController;
  late TextEditingController _kelasController;
  late TextEditingController _emailController;

  // Variabel untuk menyimpan gambar dari galeri secara lokal
  File? _selectedImageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _nisController = TextEditingController();
    _kelasController = TextEditingController();
    _emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        setState(() {
          _namaController.text = user.namaLengkap;
          _nisController.text = user.nis;
          _kelasController.text = user.kelas;
          _emailController.text = user.email;
          _existingImageUrl = user.fotoProfil; // Tarik URL gambar lama
        });
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _kelasController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi memanggil galeri dengan kompresi tingkat tinggi
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // imageQuality: 40 akan mengompres file 5MB menjadi ~150KB seketika
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
      maxWidth: 800, // Cegah resolusi terlalu raksasa
    );

    if (image != null) {
      setState(() {
        _selectedImageFile = File(image.path);
      });
    }
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception("Sesi pengguna tidak valid.");

      String? finalImageUrl = _existingImageUrl;
      bool hasNewImageUploaded = false;

      // 1. Unggah foto baru ke Cloudinary
      if (_selectedImageFile != null) {
        final uploadedUrl = await CloudinaryService.uploadImage(
          _selectedImageFile!,
          uploadPreset: ApiConstants.cloudinaryProfilePreset,
        );
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
          hasNewImageUploaded = true;
        }
      }

      // 2. Simpan ke Firebase Realtime DB
      final updateData = {
        'nama_lengkap': _namaController.text
            .trim(), // Pastikan key DB Anda benar
        'nis': _nisController.text.trim(),
        'kelas': _kelasController.text.trim(),
      };

      if (finalImageUrl != null) {
        updateData['fotoProfil'] = finalImageUrl;
      }

      final dbRef = FirebaseDatabase.instance.ref('users/${user.idUser}');
      await dbRef.update(updateData);

      if (hasNewImageUploaded &&
          _existingImageUrl != null &&
          _existingImageUrl!.isNotEmpty) {
        CloudinaryService.deleteImage(_existingImageUrl!);
      }

      // 4. Sinkronisasi Data UI
      final _ = await ref.refresh(currentUserProvider.future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: AppColors.successBg,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.dangerBg,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- KOMPONEN FOTO PROFIL ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          image: _buildProfileImageProvider(),
                        ),
                        child:
                            _selectedImageFile == null &&
                                _existingImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- FORM INPUT CRUD ---
              _buildInputLabel('Nama Lengkap'),
              _buildTextField(
                _namaController,
                'Masukkan nama lengkap',
                Icons.person_outline,
              ),

              _buildInputLabel('Nomor Induk Siswa (NIS)'),
              _buildTextField(
                _nisController,
                'Masukkan NIS',
                Icons.badge_outlined,
                isNumber: true,
              ),

              _buildInputLabel('Kelas'),
              _buildTextField(
                _kelasController,
                'Contoh: XII IPA 1',
                Icons.class_outlined,
              ),

              _buildInputLabel('Email (Hubungi Admin untuk ubah)'),
              _buildTextField(
                _emailController,
                'Email Anda',
                Icons.email_outlined,
                isReadOnly: true,
              ),

              const SizedBox(height: 48),

              // --- TOMBOL SIMPAN ---
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logika cerdas untuk menentukan sumber gambar (File Lokal vs URL Internet)
  DecorationImage? _buildProfileImageProvider() {
    if (_selectedImageFile != null) {
      return DecorationImage(
        image: FileImage(_selectedImageFile!),
        fit: BoxFit.cover,
      );
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(_existingImageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isNumber = false,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: isReadOnly
            ? null
            : (value) =>
                  value!.isEmpty ? 'Bagian ini tidak boleh kosong' : null,
        style: TextStyle(color: isReadOnly ? Colors.grey : null),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: isReadOnly ? Colors.grey : AppColors.primary,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
