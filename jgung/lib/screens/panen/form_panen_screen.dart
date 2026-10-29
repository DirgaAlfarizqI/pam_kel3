import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';

class FormPanenScreen extends StatefulWidget {
  final TaniJagungRepository repo;
  final String? initialPlantingId;

  const FormPanenScreen({
    super.key,
    required this.repo,
    this.initialPlantingId,
  });

  @override
  State<FormPanenScreen> createState() => _FormPanenScreenState();
}

class _FormPanenScreenState extends State<FormPanenScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedPlantingId;
  DateTime _harvestDate = DateTime.now();
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  String _selectedUnit = 'ton'; // 'ton' atau 'kg'

  @override
  void initState() {
    super.initState();
    final activePlantings = widget.repo.getActivePlantings();
    _selectedPlantingId = widget.initialPlantingId ??
        (activePlantings.isNotEmpty ? activePlantings.first.plantingId : '');
    _quantityController = TextEditingController();
    _priceController = TextEditingController(text: '4000');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'PILIH TANGGAL PANEN AKTUAL',
    );
    if (picked != null) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlantingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih siklus penanaman terlebih dahulu')),
      );
      return;
    }

    final double quantity = double.parse(_quantityController.text.trim().replaceAll(',', '.'));
    final double price = double.parse(_priceController.text.trim().replaceAll('.', '').replaceAll(',', '.'));

    // Validasi tanggal panen vs tanggal tanam
    final planting = widget.repo.getPlantingById(_selectedPlantingId);
    if (planting != null && _harvestDate.isBefore(planting.plantingDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal panen aktual tidak boleh sebelum tanggal mulai tanam.'),
          backgroundColor: AppColors.rugi,
        ),
      );
      return;
    }

    widget.repo.recordHarvest(
      plantingId: _selectedPlantingId,
      harvestDate: _harvestDate,
      quantity: quantity,
      unit: _selectedUnit,
      salePricePerKg: price,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil panen aktual berhasil dicatat dan siklus ditandai selesai!'),
        backgroundColor: AppColors.untung,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final plantings = widget.repo.getPlantings();
    final double inputQty = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final double inputPrice = double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;

    final double qtyKg = TaniCalculator.convertHarvestToKg(inputQty, _selectedUnit);
    final double revenue = TaniCalculator.calculateHarvestRevenue(qtyKg, inputPrice);
    final double totalExpenses = _selectedPlantingId.isNotEmpty
        ? widget.repo.getTotalExpensesForPlanting(_selectedPlantingId)
        : 0.0;
    final double netProfit = TaniCalculator.calculateProfitLoss(revenue, totalExpenses);

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Input Hasil Panen Aktual'),
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
                      'Pilih Siklus Penanaman',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPlantingId.isNotEmpty ? _selectedPlantingId : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grass, color: AppColors.hijau),
                      ),
                      items: plantings.map((p) {
                        final land = widget.repo.getLandById(p.landId);
                        return DropdownMenuItem(
                          value: p.plantingId,
                          child: Text('${p.name} - ${land?.name ?? ""} (${p.cornVariety})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPlantingId = val);
                      },
                      validator: (val) => val == null || val.isEmpty ? 'Pilih penanaman' : null,
                    ),
                    const SizedBox(height: 16),

                    // Tanggal Panen Aktual
                    const Text(
                      'Tanggal Panen Aktual',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickHarvestDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.latar,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.garis),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available, color: AppColors.untung),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tanggal Panen Selesai', style: TextStyle(fontSize: 11, color: AppColors.teksPudar)),
                                  Text(
                                    TaniFormatter.tanggal(_harvestDate),
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

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jumlah Hasil Panen',
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _quantityController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  hintText: 'Contoh: 5.5',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.scale, color: AppColors.hijau),
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Jumlah wajib diisi';
                                  final p = double.tryParse(val.replaceAll(',', '.'));
                                  if (p == null || p < 0) return 'Harus angka positif';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Satuan',
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'ton', child: Text('Ton')),
                                  DropdownMenuItem(value: 'kg', child: Text('Kg')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedUnit = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Harga Jual per Kilogram (Rp)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 4000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money, color: AppColors.hijau),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Harga jual wajib diisi';
                        final p = double.tryParse(val.replaceAll('.', '').replaceAll(',', '.'));
                        if (p == null || p < 0) return 'Harus angka positif';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Catatan Panen (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Kualitas pipil, kadar air saat timbang, pembeli, dll.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Kartu Live Perhitungan Keuangan Panen
              TaniCard(
                color: const Color(0xFFF1F8F4),
                border: Border.all(color: AppColors.hijau.withOpacity(0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate_outlined, color: AppColors.hijauTua),
                        const SizedBox(width: 8),
                        const Text(
                          'Ringkasan Finansial Otomatis',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.hijauTua),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildCalcRow('Kuantitas Hasil Dikonversi', '${TaniFormatter.angka(qtyKg)} kg (${TaniFormatter.angka(qtyKg / 1000.0)} ton)'),
                    const SizedBox(height: 6),
                    _buildCalcRow('Pendapatan Kotor', TaniFormatter.rupiah(revenue), isBold: true),
                    const SizedBox(height: 6),
                    _buildCalcRow('Total Pengeluaran Siklus Ini', TaniFormatter.rupiah(totalExpenses)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Laba Bersih Siklus Ini:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          TaniFormatter.rupiah(netProfit),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: netProfit >= 0 ? AppColors.untung : AppColors.rugi,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TaniBadge(
                        label: TaniCalculator.determineProfitLossStatus(
                          hasHarvestData: inputQty > 0,
                          revenue: revenue,
                          totalExpenses: totalExpenses,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              TaniButton(
                text: 'Simpan Hasil Panen & Selesaikan Siklus',
                onPressed: _save,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.teksSekunder)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.teksUtama,
          ),
        ),
      ],
    );
  }
}
