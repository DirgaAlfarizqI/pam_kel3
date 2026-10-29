import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';

class FormLahanScreen extends StatefulWidget {
  final TaniJagungRepository repo;
  final LandModel? existingLand;

  const FormLahanScreen({
    super.key,
    required this.repo,
    this.existingLand,
  });

  @override
  State<FormLahanScreen> createState() => _FormLahanScreenState();
}

class _FormLahanScreenState extends State<FormLahanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingLand?.name ?? '');
    _areaController = TextEditingController(
      text: widget.existingLand != null ? widget.existingLand!.areaHa.toString() : '',
    );
    _locationController = TextEditingController(text: widget.existingLand?.locationNote ?? '');
    _notesController = TextEditingController(text: widget.existingLand?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final String name = _nameController.text.trim();
    final double area = double.parse(_areaController.text.trim().replaceAll(',', '.'));
    final String location = _locationController.text.trim();
    final String notes = _notesController.text.trim();

    if (widget.existingLand == null) {
      widget.repo.addLand(
        name: name,
        areaHa: area,
        locationNote: location.isNotEmpty ? location : null,
        notes: notes.isNotEmpty ? notes : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lahan baru berhasil disimpan')),
      );
    } else {
      widget.repo.updateLand(
        widget.existingLand!.copyWith(
          name: name,
          areaHa: area,
          locationNote: location.isNotEmpty ? location : null,
          notes: notes.isNotEmpty ? notes : null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data lahan berhasil diperbarui')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.existingLand != null;

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Data Lahan' : 'Tambah Lahan Baru'),
        backgroundColor: AppColors.hijauTua,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaniCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lahan',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Lahan 1 - Sawah Utara',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.landscape, color: AppColors.hijau),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama lahan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Luas Lahan (Hektare)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 1.0 atau 0.8',
                        suffixText: 'Hektare (ha)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.square_foot, color: AppColors.hijau),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Luas lahan wajib diisi';
                        }
                        final parsed = double.tryParse(val.replaceAll(',', '.'));
                        if (parsed == null || parsed <= 0) {
                          return 'Luas lahan harus berupa angka positif lebih dari nol';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Lokasi / Keterangan (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Desa Karangmojo, Blok A',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin_drop, color: AppColors.hijau),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Catatan Tambahan (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Catatan kondisi irigasi, jenis tanah, dll.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TaniButton(
                text: isEdit ? 'Simpan Perubahan' : 'Tambah Lahan',
                onPressed: _save,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
