import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';

class FormPengeluaranScreen extends StatefulWidget {
  final TaniJagungRepository repo;
  final String? initialPlantingId;
  final String? initialCategory;
  final ExpenseModel? existingExpense;

  const FormPengeluaranScreen({
    super.key,
    required this.repo,
    this.initialPlantingId,
    this.initialCategory,
    this.existingExpense,
  });

  @override
  State<FormPengeluaranScreen> createState() => _FormPengeluaranScreenState();
}

class _FormPengeluaranScreenState extends State<FormPengeluaranScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedPlantingId;
  late String _selectedCategory;
  DateTime _date = DateTime.now();

  late TextEditingController _descController;
  late TextEditingController _qtyController;
  late TextEditingController _unitPriceController;
  late TextEditingController _totalAmountController;
  late TextEditingController _notesController;
  String _unit = 'kg';

  final List<String> _categories = [
    'Pupuk',
    'Benih',
    'Pestisida',
    'Pengolahan Lahan',
    'Tenaga Kerja',
    'Sewa Alat',
    'Transportasi',
    'Biaya Panen',
    'Biaya Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    final plantings = widget.repo.getPlantings();
    _selectedPlantingId = widget.existingExpense?.plantingId ??
        widget.initialPlantingId ??
        (plantings.isNotEmpty ? plantings.first.plantingId : '');

    _selectedCategory = widget.existingExpense?.category ??
        widget.initialCategory ??
        'Pupuk';

    _date = widget.existingExpense?.date ?? DateTime.now();
    _descController = TextEditingController(text: widget.existingExpense?.description ?? '');
    _qtyController = TextEditingController(
      text: widget.existingExpense?.quantity != null
          ? widget.existingExpense!.quantity.toString()
          : (_selectedCategory == 'Pupuk' ? '25' : ''),
    );
    _unit = widget.existingExpense?.unit ?? 'kg';
    _unitPriceController = TextEditingController(
      text: widget.existingExpense?.unitPrice != null
          ? widget.existingExpense!.unitPrice!.toInt().toString()
          : (_selectedCategory == 'Pupuk' ? '6000' : ''),
    );
    _totalAmountController = TextEditingController(
      text: widget.existingExpense != null
          ? widget.existingExpense!.amount.toInt().toString()
          : (_selectedCategory == 'Pupuk' ? '150000' : ''),
    );
    _notesController = TextEditingController(text: widget.existingExpense?.notes ?? '');

    if (_selectedCategory == 'Pupuk' && widget.existingExpense == null) {
      _descController.text = 'Pupuk Urea';
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _qtyController.dispose();
    _unitPriceController.dispose();
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalculateFromQtyAndPrice() {
    final double q = double.tryParse(_qtyController.text.replaceAll(',', '.')) ?? 0.0;
    final double p = double.tryParse(_unitPriceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    if (q > 0 && p > 0) {
      final double total = TaniCalculator.calculateFertilizerCost(q, p);
      _totalAmountController.text = total.toInt().toString();
      setState(() {});
    }
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

    final double amount = double.parse(
      _totalAmountController.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    final double? qty = _qtyController.text.trim().isNotEmpty
        ? double.tryParse(_qtyController.text.replaceAll(',', '.'))
        : null;
    final double? unitPrice = _unitPriceController.text.trim().isNotEmpty
        ? double.tryParse(_unitPriceController.text.replaceAll('.', '').replaceAll(',', '.'))
        : null;

    if (widget.existingExpense == null) {
      widget.repo.addExpense(
        plantingId: _selectedPlantingId,
        date: _date,
        category: _selectedCategory,
        description: _descController.text.trim(),
        quantity: qty,
        unit: qty != null ? _unit : null,
        unitPrice: unitPrice,
        amount: amount,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengeluaran berhasil dicatat')),
      );
    } else {
      widget.repo.updateExpense(
        widget.existingExpense!.copyWith(
          plantingId: _selectedPlantingId,
          date: _date,
          category: _selectedCategory,
          description: _descController.text.trim(),
          quantity: qty,
          unit: qty != null ? _unit : null,
          unitPrice: unitPrice,
          amount: amount,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengeluaran berhasil diperbarui')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final plantings = widget.repo.getPlantings();
    final bool isFertilizer = _selectedCategory == 'Pupuk';
    final bool isEdit = widget.existingExpense != null;

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran'),
        backgroundColor: AppColors.hijauTua,
        foregroundColor: Colors.white,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Pengeluaran?'),
                    content: const Text('Apakah Anda yakin ingin menghapus catatan pengeluaran ini?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          widget.repo.deleteExpense(widget.existingExpense!.expenseId);
                          Navigator.pop(ctx); // Dialog
                          Navigator.pop(context); // Screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catatan pengeluaran dihapus')),
                          );
                        },
                        child: const Text('Hapus', style: TextStyle(color: AppColors.rugi)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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
                      'Kategori Biaya',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                            if (val == 'Pupuk' && _descController.text.isEmpty) {
                              _descController.text = 'Pupuk Urea';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tanggal Transaksi',
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
                            const Icon(Icons.calendar_today, color: AppColors.hijau),
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

                    Text(
                      isFertilizer ? 'Nama Pupuk' : 'Nama Barang / Keterangan',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: isFertilizer ? 'Contoh: Urea, NPK Phonska, ZA' : 'Keterangan pengeluaran',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.edit_note, color: AppColors.hijau),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Keterangan wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),
                    // Kuantitas & Harga per satuan (Manual input, bebas edit)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFertilizer ? 'Jumlah Pupuk (kg)' : 'Jumlah Barang (Opsional)',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _qtyController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: isFertilizer ? '25' : '1',
                                  suffixText: _unit,
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (_) => _recalculateFromQtyAndPrice(),
                                validator: (val) {
                                  if (isFertilizer && (val == null || val.trim().isEmpty)) {
                                    return 'Jumlah pupuk wajib diisi';
                                  }
                                  if (val != null && val.trim().isNotEmpty) {
                                    final p = double.tryParse(val.replaceAll(',', '.'));
                                    if (p == null || p < 0) return 'Harus angka positif';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFertilizer ? 'Harga per kg (Rp)' : 'Harga Satuan (Opsional)',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _unitPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  hintText: '6000',
                                  prefixText: 'Rp ',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => _recalculateFromQtyAndPrice(),
                                validator: (val) {
                                  if (isFertilizer && (val == null || val.trim().isEmpty)) {
                                    return 'Harga per kg wajib diisi';
                                  }
                                  if (val != null && val.trim().isNotEmpty) {
                                    final p = double.tryParse(val.replaceAll('.', '').replaceAll(',', '.'));
                                    if (p == null || p < 0) return 'Harus angka positif';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Total Biaya Pengeluaran (Rp)',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.teksUtama),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _totalAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 150000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments_outlined, color: AppColors.hijau),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Total biaya wajib diisi';
                        final p = double.tryParse(val.replaceAll('.', '').replaceAll(',', '.'));
                        if (p == null || p < 0) return 'Harus angka positif';
                        return null;
                      },
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
                        hintText: 'Toko pertanian, nomor nota, kualitas, dll.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TaniButton(
                text: isEdit ? 'Simpan Perubahan Biaya' : 'Simpan Pengeluaran',
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
