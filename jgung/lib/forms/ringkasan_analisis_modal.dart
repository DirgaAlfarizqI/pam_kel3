import 'package:flutter/material.dart';
import '../models/perencanaan_tani_model.dart';

class RingkasanAnalisisModal extends StatelessWidget {
  final PerencanaanTaniModel model;

  const RingkasanAnalisisModal({super.key, required this.model});

  static void show(BuildContext context, PerencanaanTaniModel model) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RingkasanAnalisisModal(model: model),
    );
  }

  Widget _buildRowItem(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: bold ? const Color(0xFF183B2B) : const Color(0xFF5A7265),
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? (bold ? const Color(0xFF183B2B) : Colors.black87),
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double omzet = model.totalPendapatan1Panen;
    final double biaya = model.totalBiaya1Panen;
    final double profit = model.labaBersih1Panen;
    final bool isUntung = profit >= 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.assessment_rounded, color: Color(0xFF17633D)),
                const SizedBox(width: 10),
                const Text(
                  'Ringkasan Data & Biaya',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B2B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRowItem('Luas Lahan', '${FormatHelper.angka(model.luasDalamHa, desimal: 2)} ha'),
                  _buildRowItem('Jenis Benih', model.jenisBenih),
                  _buildRowItem('Hasil Panen', '${FormatHelper.angka(model.estimasiHasilKg, desimal: 0)} kg'),
                  _buildRowItem('Harga Jual', '${FormatHelper.rupiah(model.hargaJualPerKg)}/kg'),
                  const Divider(height: 18),
                  _buildRowItem('Total Modal Awal', FormatHelper.rupiah(model.totalModalAwal)),
                  _buildRowItem('Total Biaya Operasional', FormatHelper.rupiah(model.totalBiayaOperasional)),
                  _buildRowItem('Total Biaya', FormatHelper.rupiah(biaya), bold: true),
                  const Divider(height: 18),
                  _buildRowItem('Estimasi Omzet', FormatHelper.rupiah(omzet)),
                  _buildRowItem(
                    'Laba Bersih',
                    FormatHelper.rupiah(profit),
                    bold: true,
                    valueColor: isUntung ? const Color(0xFF17633D) : Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
