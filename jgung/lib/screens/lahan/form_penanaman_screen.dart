import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';

class FormPenanamanScreen extends StatefulWidget {
  final TaniJagungRepository repo;
  final String? initialLandId;

  const FormPenanamanScreen({
    super.key,
    required this.repo,
    this.initialLandId,
  });

  @override
  State<FormPenanamanScreen> createState() => _FormPenanamanScreenState();
}

class _FormPenanamanScreenState extends State<FormPenanamanScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedLandId;
  late TextEditingController _nameController;
  late TextEditingController _varietyController;
  late TextEditingController _notesController;
  DateTime _plantingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final lands = widget.repo.getLands();
    _selectedLandId = widget.initialLandId ?? (lands.isNotEmpty ? lands.first.landId : '');
    _nameController = TextEditingController(text: 'Musim Tanam Baru ${DateTime.now().year}');
    _varietyController = TextEditingController(text: 'Bisi 18');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickPlantingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'PILIH TANGGAL MULAI TANAM',
    );
    if (picked != null) {
      setState(() {
        _plantingDate = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLandId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lahan terlebih dahulu')),
      );
      return;
    }

    final newPlanting = widget.repo.startNewPlanting(
      landId: _selectedLandId,
      name: _nameController.text.trim(),
      cornVariety: _varietyController.text.trim(),
      plantingDate: _plantingDate,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Siklus penanaman "${newPlanting.name}" berhasil dibuat'),
        backgroundColor: AppColors.hijauTua,
      ),
    );

    Navigator.pop(context, newPlanting);
  }

  @override
  Widget build(BuildContext context) {
    final lands = widget.repo.getLands();
    final DateTime estimatedHarvest = TaniCalculator.calculateEstimatedHarvestDate(_plantingDate);

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Mulai Siklus Penanaman'),
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
                      'Pilih Lahan',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLandId.isNotEmpty ? _selectedLandId : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.landscape, color: AppColors.hijau),
                      ),
                      items: lands.map((l) {
                        return DropdownMenuItem(
                          value: l.landId,
                          child: Text('${l.name} (${TaniFormatter.angka(l.areaHa)} ha)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLandId = val);
                      },
                      validator: (val) => val == null || val.isEmpty ? 'Pilih lahan' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Label / Nama Penanaman',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Musim Tanam 1 - 2026',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bookmark_border, color: AppColors.hijau),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nama penanaman wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Varietas Jagung',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _varietyController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Bisi 18, Pioneer P27, NK 212',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grass, color: AppColors.hijau),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Varietas jagung wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Perhitungan Tanggal Kalender',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 12),

                    // Tanggal Mulai Tanam
                    InkWell(
                      onTap: _pickPlantingDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.latar,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.garis),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: AppColors.hijau),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tanggal Mulai Tanam (Manual)', style: TextStyle(fontSize: 11, color: AppColors.teksPudar)),
                                  Text(
                                    TaniFormatter.tanggal(_plantingDate),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.edit_calendar, size: 20, color: AppColors.hijau),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Perkiraan Panen (+4 bulan kalender)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.kuningPudar,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.kuningJagung.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.peringatan),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Perkiraan Tanggal Panen (+4 Bulan Kalender)',
                                  style: TextStyle(fontSize: 11, color: AppColors.peringatan, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  TaniFormatter.tanggal(estimatedHarvest),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Rencana tanam, target, kondisi air, dll.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TaniButton(
                text: 'Simpan & Mulai Penanaman',
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
