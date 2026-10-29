import 'package:flutter/material.dart';
import '../models/perencanaan_tani_model.dart';

class FormBibitPupuk extends StatelessWidget {
  final PerencanaanTaniModel model;
  final VoidCallback onUbahLuasLahan;

  const FormBibitPupuk({
    super.key,
    required this.model,
    required this.onUbahLuasLahan,
  });

  Widget _buildItemKebutuhan({
    required IconData ikon,
    required Color warnaIkon,
    required Color warnaLatarIkon,
    required String nama,
    required String jumlah,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EDE8)),
      ),
      child: Row(
        children: [
          // Kotak Ikon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: warnaLatarIkon,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, color: warnaIkon, size: 24),
          ),
          const SizedBox(width: 14),
          // Nama Item
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF183B2B),
              ),
            ),
          ),
          // Jumlah / Bobot
          Text(
            jumlah,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF183B2B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double luasHa = model.luasDalamHa;
    final String teksLuas = FormatHelper.angka(luasHa, desimal: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Layar
          const Text(
            'Kebutuhan Bibit & Pupuk',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Perhitungan berdasarkan luas lahan dan rekomendasi kebutuhan per hektare.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // Card Rekomendasi per 1 ha
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDE7E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco_outlined, size: 16, color: Color(0xFF17633D)),
                    SizedBox(width: 6),
                    Text(
                      'Rekomendasi per 1 ha',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF183B2B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Bibit
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4D9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.grain_rounded, color: Color(0xFFE5A016), size: 20),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bibit',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '20 kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF183B2B),
                          ),
                        ),
                      ],
                    ),
                    // Phonska
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF4F1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF00897B), size: 20),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Phonska',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '300 kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF183B2B),
                          ),
                        ),
                      ],
                    ),
                    // Urea
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF5E35B1), size: 20),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Urea',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '200 kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF183B2B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Label Kebutuhan untuk [X] ha
          Text(
            'Kebutuhan untuk $teksLuas ha',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 12),

          // List Kebutuhan sesuai mockup
          _buildItemKebutuhan(
            ikon: Icons.grain_rounded,
            warnaIkon: const Color(0xFFE5A016),
            warnaLatarIkon: const Color(0xFFFFF7E3),
            nama: 'Bibit ${model.jenisBenih}',
            jumlah: '${FormatHelper.angka(model.kebutuhanBenihKg, desimal: 0)} kg',
          ),
          _buildItemKebutuhan(
            ikon: Icons.shopping_bag_outlined,
            warnaIkon: const Color(0xFF00897B),
            warnaLatarIkon: const Color(0xFFE0F2F1),
            nama: 'Pupuk Phonska',
            jumlah: '${FormatHelper.angka(model.kebutuhanPhonskaKg, desimal: 0)} kg',
          ),
          _buildItemKebutuhan(
            ikon: Icons.inventory_2_outlined,
            warnaIkon: const Color(0xFF78909C),
            warnaLatarIkon: const Color(0xFFECEFF1),
            nama: 'Pupuk Urea',
            jumlah: '${FormatHelper.angka(model.kebutuhanUreaKg, desimal: 0)} kg',
          ),
          const SizedBox(height: 16),

          // Tombol Ubah Luas Lahan (Outlined)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF183B2B),
                side: const BorderSide(color: Color(0xFFDCE5DD), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: onUbahLuasLahan,
              child: const Text(
                'Ubah Luas Lahan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
