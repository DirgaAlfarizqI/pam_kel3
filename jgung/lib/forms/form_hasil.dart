import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/perencanaan_tani_model.dart';

class FormHasil extends StatefulWidget {
  final PerencanaanTaniModel model;
  final VoidCallback onDataChanged;

  const FormHasil({
    super.key,
    required this.model,
    required this.onDataChanged,
  });

  @override
  State<FormHasil> createState() => _FormHasilState();
}

class _FormHasilState extends State<FormHasil> {
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

  @override
  Widget build(BuildContext context) {
    final double hasilKg = widget.model.estimasiHasilKg;
    final double hasilTon = hasilKg / 1000.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Layar
          const Text(
            'Estimasi Hasil Panen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Berdasarkan luas lahan, rata-rata hasil panen bisa mencapai 6-8 ton per hektare (tergantung kondisi).',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // Kartu Estimasi Hasil Panen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4E6D8)),
            ),
            child: Row(
              children: [
                // Ikon Jagung
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.agriculture_rounded,
                      color: Color(0xFFE5A016),
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Informasi Hasil
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimasi Hasil Panen',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${FormatHelper.angka(hasilKg, desimal: 0)} kg',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF183B2B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(${FormatHelper.angka(hasilTon, desimal: 0)} ton) per panen',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge ± 6-8 ton/ha
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC8DEC9)),
                  ),
                  child: const Text(
                    '± 6-8 ton/ha',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17633D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Judul Pengaturan Lainnya
          const Text(
            'Pengaturan Lainnya',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 14),

          // Field 1: Siklus Panen per Tahun
          Text(
            'Siklus Panen per Tahun',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCE5DD)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: widget.model.siklusPanenPerTahun,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('1 kali', style: TextStyle(fontSize: 13, color: Color(0xFF183B2B))),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('2 kali', style: TextStyle(fontSize: 13, color: Color(0xFF183B2B))),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('3 kali', style: TextStyle(fontSize: 13, color: Color(0xFF183B2B))),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      widget.model.siklusPanenPerTahun = val;
                    });
                    widget.onDataChanged();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 2: Harga Jual per Kg
          Text(
            'Harga Jual per Kg',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
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
                  '/kg',
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
