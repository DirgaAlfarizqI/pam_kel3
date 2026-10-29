import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/perencanaan_tani_model.dart';

class FormBiaya extends StatefulWidget {
  final PerencanaanTaniModel model;
  final VoidCallback onDataChanged;

  const FormBiaya({
    super.key,
    required this.model,
    required this.onDataChanged,
  });

  @override
  State<FormBiaya> createState() => _FormBiayaState();
}

class _FormBiayaState extends State<FormBiaya> {
  late final TextEditingController _hargaJualController;

  @override
  void initState() {
    super.initState();
    _hargaJualController = TextEditingController(
      text: FormatHelper.angka(widget.model.hargaJualPerKg, desimal: 0),
    );
  }

  @override
  void dispose() {
    _hargaJualController.dispose();
    super.dispose();
  }

  Widget _buildRowBiaya(String label, String nilai, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              color: const Color(0xFF183B2B),
            ),
          ),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: const Color(0xFF183B2B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Layar
          const Text(
            'Biaya & Harga',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Masukkan estimasi biaya dan harga jual sesuai kondisi di lapangan.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // Kartu 1: Modal Awal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5EDE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modal Awal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF183B2B),
                  ),
                ),
                const SizedBox(height: 10),
                _buildRowBiaya('Benih ${widget.model.jenisBenih}', FormatHelper.rupiah(widget.model.biayaBenih)),
                _buildRowBiaya('Pupuk Phonska', FormatHelper.rupiah(widget.model.biayaPhonska)),
                _buildRowBiaya('Pupuk Urea', FormatHelper.rupiah(widget.model.biayaUrea)),
                const Divider(height: 18, color: Color(0xFFE5EDE8)),
                _buildRowBiaya('Total Modal Awal', FormatHelper.rupiah(widget.model.totalModalAwal), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Kartu 2: Biaya Operasional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5EDE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biaya Operasional',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF183B2B),
                  ),
                ),
                const SizedBox(height: 10),
                _buildRowBiaya('Olah lahan', FormatHelper.rupiah(widget.model.biayaOlahLahan)),
                _buildRowBiaya('Tenaga kerja', FormatHelper.rupiah(widget.model.biayaTenagaKerja)),
                _buildRowBiaya('Lain-lain (pestisida, dll)', FormatHelper.rupiah(widget.model.biayaLainLain)),
                const Divider(height: 18, color: Color(0xFFE5EDE8)),
                _buildRowBiaya('Total Biaya Operasional', FormatHelper.rupiah(widget.model.totalBiayaOperasional), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bagian 3: Harga Jual Jagung
          const Text(
            'Harga Jual Jagung',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCE5DD)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Text(
                  'Rp ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF183B2B),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _hargaJualController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF183B2B),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      widget.model.hargaJualPerKg = parsed;
                      widget.onDataChanged();
                    },
                  ),
                ),
                Text(
                  'per kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
