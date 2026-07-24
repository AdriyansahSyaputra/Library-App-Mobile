import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_book_form_controller.dart';

class AdminAddBookPage extends ConsumerStatefulWidget {
  const AdminAddBookPage({super.key});

  @override
  ConsumerState<AdminAddBookPage> createState() => _AdminAddBookPageState();
}

class _AdminAddBookPageState extends ConsumerState<AdminAddBookPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _judulController = TextEditingController();
  final _penulisController = TextEditingController();
  final _penerbitController = TextEditingController();
  final _isbnController = TextEditingController();
  final _tahunController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _stokController = TextEditingController();

  // State UI Lokal
  String _kategoriTerpilih = 'Fiksi';
  final List<String> _kategoriList = [
    'Biografi',
    'Fiksi',
    'Sains',
    'Sejarah',
    'Teknologi',
  ];
  File? _imageFile;

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _isbnController.dispose();
    _tahunController.dispose();
    _lokasiController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _eksekusiSimpan() {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sampul buku wajib diunggah!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Memanggil controller yang sudah disatukan penamaannya
      ref
          .read(bookFormControllerProvider.notifier)
          .submitNewBook(
            imageFile: _imageFile!,
            judul: _judulController.text.trim(),
            penulis: _penulisController.text.trim(),
            penerbit: _penerbitController.text.trim(),
            kategori: _kategoriTerpilih,
            isbn: _isbnController.text.trim(),
            tahunTerbit: _tahunController.text.trim(),
            lokasiRak: _lokasiController.text.trim(),
            stok: _stokController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantau status dari controller
    final formState = ref.watch(bookFormControllerProvider);

    // Dengarkan notifikasi sukses/gagal
    ref.listen<AsyncValue<void>>(bookFormControllerProvider, (previous, next) {
      if (!next.isLoading && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buku berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (!next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Tambah Buku Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // --- 1. SEKSI SAMPUL BUKU ---
            _buildSectionTitle('SAMPUL BUKU'),
            GestureDetector(
              onTap: formState.isLoading ? null : _pickImage,
              child: Container(
                height: 220,
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageFile != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap untuk Upload\n(Wajib)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. SEKSI INFORMASI UTAMA ---
            _buildSectionTitle('INFORMASI UTAMA'),
            _buildFormGroup([
              _buildTextField(
                _judulController,
                'Judul Buku',
                Icons.book_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _penulisController,
                'Nama Penulis',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kategoriTerpilih,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _kategoriList.map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) {
                  setState(() => _kategoriTerpilih = val!);
                },
              ),
            ]),
            const SizedBox(height: 32),

            // --- 3. SEKSI PUBLIKASI & INVENTARIS ---
            _buildSectionTitle('DETAIL PUBLIKASI & RAK'),
            _buildFormGroup([
              _buildTextField(
                _penerbitController,
                'Penerbit',
                Icons.business_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _tahunController,
                'Tahun Terbit',
                Icons.calendar_today_outlined,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(_isbnController, 'ISBN', Icons.qr_code_outlined),
              const SizedBox(height: 16),
              _buildTextField(
                _stokController,
                'Jumlah Stok',
                Icons.inventory_2_outlined,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(_lokasiController, 'Lokasi Rak', Icons.shelves),
            ]),
            const SizedBox(height: 48),

            // --- 4. TOMBOL SUBMIT ---
            ElevatedButton(
              onPressed: formState.isLoading ? null : _eksekusiSimpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: formState.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan Buku Baru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildFormGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Wajib diisi' : null,
    );
  }
}
