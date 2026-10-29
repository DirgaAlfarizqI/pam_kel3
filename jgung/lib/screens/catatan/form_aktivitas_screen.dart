import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';

class FormAktivitasScreen extends StatefulWidget {
  final TaniJagungRepository repo;
  final String? initialPlantingId;

  const FormAktivitasScreen({
    super.key,
    required this.repo,
    this.initialPlantingId,
  });

  @override
  State<FormAktivitasScreen> createState() => _FormAktivitasScreenState();
}

class _FormAktivitasScreenState extends State<FormAktivitasScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedPlantingId;
  DateTime _date = DateTime.now();
  String _selectedType = 'Pemupukan';
  late TextEditingController _descController;
  late TextEditingController _notesController;
  late TextEditingController _qtyController;
  late TextEditingController _costController;
  String _unit = 'kg';
  bool _includeCost = false;

  final List<Map<String, dynamic>> _activityTypes = [
    {'type': 'Penanaman', 'icon': Icons.grass},
    {'type': 'Pemupukan', 'icon': Icons.grain},
    {'type': 'Pestisida', 'icon': Icons.bug_report_outlined},
    {'type': 'Penyiraman', 'icon': Icons.water_drop_outlined},
    {'type': 'Pengolahan Lahan', 'icon': Icons.agriculture_outlined},
    {'type': 'Tenaga Kerja', 'icon': Icons.groups_outlined},
    {'type': 'Panen', 'icon': Icons.inventory_2_outlined},
    {'type': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    final plantings = widget.repo.getPlantings();
    _selectedPlantingId = widget.initialPlantingId ??
        (plantings.isNotEmpty ? plantings.first.plantingId : '');
    _descController = TextEditingController();
    _notesController = TextEditingController();
    _qtyController = TextEditingController();
    _costController = TextEditingController();
  }

  @override
  void dispose() {
    _descController.dispose();
    _notesController.dispose();
    _qtyController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlantingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih siklus penanaman terlebih dahulu')),
      );
      return;
    }

    final double? qty = _qtyController.text.trim().isNotEmpty
        ? double.tryParse(_qtyController.text.replaceAll(',', '.'))
        : null;
    final double? cost = _includeCost && _costController.text.trim().isNotEmpty
        ? double.tryParse(_costController.text.replaceAll('.', '').replaceAll(',', '.'))
        : null;

    widget.repo.addActivity(
      plantingId: _selectedPlantingId,
      date: _date,
      type: _selectedType,
      description: _descController.text.trim(),
      quantity: qty,
      unit: qty != null ? _unit : null,
      cost: cost,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aktivitas berhasil dicatat di jurnal'),
        backgroundColor: AppColors.hijauTua,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final plantings = widget.repo.getPlantings();

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Catat Aktivitas Budidaya'),
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
                      'Siklus Penanaman',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPlantingId.isNotEmpty ? _selectedPlantingId : null,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: plantings.map((p) {
                        final land = widget.repo.getLandById(p.landId);
                        return DropdownMenuItem(
                          value: p.plantingId,
                          child: Text('${p.name} (${land?.name ?? ""})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPlantingId = val);
                      },
                      validator: (val) => val == null || val.isEmpty ? 'Pilih penanaman' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Pilih Jenis Aktivitas',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 10),

                    // Grid Jenis Aktivitas
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _activityTypes.length,
                      itemBuilder: (context, idx) {
                        final item = _activityTypes[idx];
                        final bool isSel = item['type'] == _selectedType;
                        return InkWell(
                          onTap: () => setState(() => _selectedType = item['type']),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.hijauTua : AppColors.latar,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.hijauTua : AppColors.garis,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: isSel ? AppColors.kuningJagung : AppColors.hijauTua,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['type'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? Colors.white : AppColors.teksUtama,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Tanggal Kegiatan',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
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
                            Text(
                              TaniFormatter.tanggal(_date),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi / Catatan Kegiatan',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Pemupukan kedua Urea 25 kg & NPK Phonska',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),
                    // Toggle mencatat biaya transaksi sekaligus
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Aktivitas ini melibatkan biaya/bahan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      value: _includeCost,
                      onChanged: (val) => setState(() => _includeCost = val ?? false),
                    ),

                    if (_includeCost) ...[
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _qtyController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Bahan',
                                hintText: 'Contoh: 25',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _unit,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(value: 'kg', child: Text('kg')),
                                DropdownMenuItem(value: 'liter', child: Text('liter')),
                                DropdownMenuItem(value: 'karung', child: Text('karung')),
                                DropdownMenuItem(value: 'jam', child: Text('jam')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _unit = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _costController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Total Biaya (Rp)',
                          prefixText: 'Rp ',
                          hintText: '150000',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],

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
                        hintText: 'Kondisi cuaca saat bekerja, catatan pekerja, dll.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TaniButton(
                text: 'Simpan ke Jurnal Aktivitas',
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
