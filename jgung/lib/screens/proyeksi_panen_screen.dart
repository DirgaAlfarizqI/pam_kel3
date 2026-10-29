import 'package:flutter/material.dart';
import '../models/perencanaan_tani_model.dart';
import 'dashboard_screen.dart';

class ProyeksiPanenScreen extends StatelessWidget {
  final PerencanaanTaniModel model;

  const ProyeksiPanenScreen({super.key, required this.model});

  Widget _buildKartuStat({
    required IconData ikon,
    required Color warnaIkon,
    required Color warnaLatarIkon,
    required String judul,
    required String nilai,
    Widget? trailingChip,
    Color? warnaLatarKartu,
    Color? warnaTeksNilai,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warnaLatarKartu ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: warnaLatarIkon,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: warnaIkon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      judul,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    ?trailingChip,
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  nilai,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: warnaTeksNilai ?? const Color(0xFF183B2B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarGroup({
    required String namaPanen,
    required String labelPendapatan,
    required String labelBiaya,
    required double rasioPendapatan,
    required double rasioBiaya,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bar Hijau (Pendapatan)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    labelPendapatan,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF17633D)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 100 * rasioPendapatan,
                    decoration: const BoxDecoration(
                      color: Color(0xFF17633D),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              // Bar Kuning (Biaya)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    labelBiaya,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE5A016)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 100 * rasioBiaya,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0C66A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          namaPanen,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF183B2B)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double pendapatan3x = model.totalPendapatan3Panen;
    final double biaya3x = model.totalBiaya3Panen;
    final double laba3x = model.totalLabaBersih3Panen;

    final String labelPendapatanPerPanen = '${(model.totalPendapatan1Panen / 1000000).toStringAsFixed(0)} jt';
    final String labelBiayaPerPanen = (model.totalBiaya1Panen / 1000000).toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              'TaniJagung',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Layar
                    const Text(
                      'Proyeksi 3 Kali Panen',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183B2B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dalam 1 tahun, Anda bisa melakukan 3 kali panen dengan hasil dan keuntungan yang sama (estimasi).',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 1: Total Pendapatan (3 Panen)
                    _buildKartuStat(
                      ikon: Icons.lock_outline_rounded,
                      warnaIkon: const Color(0xFF17633D),
                      warnaLatarIkon: const Color(0xFFEAF5ED),
                      judul: 'Total Pendapatan (3 Panen)',
                      nilai: FormatHelper.rupiah(pendapatan3x),
                    ),

                    // Card 2: Total Biaya (3 Panen)
                    _buildKartuStat(
                      ikon: Icons.receipt_long_outlined,
                      warnaIkon: const Color(0xFFE5A016),
                      warnaLatarIkon: const Color(0xFFFFF7E3),
                      judul: 'Total Biaya (3 Panen)',
                      nilai: FormatHelper.rupiah(biaya3x),
                    ),

                    // Card 3: Total Laba Bersih (3 Panen)
                    _buildKartuStat(
                      ikon: Icons.eco_rounded,
                      warnaIkon: const Color(0xFF17633D),
                      warnaLatarIkon: const Color(0xFFD4EBD8),
                      warnaLatarKartu: const Color(0xFFF1F8F3),
                      warnaTeksNilai: const Color(0xFF17633D),
                      judul: 'Total Laba Bersih (3 Panen)',
                      nilai: FormatHelper.rupiah(laba3x),
                      trailingChip: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4EBD8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 10, color: Color(0xFF17633D)),
                            SizedBox(width: 3),
                            Text(
                              'Untung',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17633D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Judul Perbandingan Setiap Panen
                    const Text(
                      'Perbandingan Setiap Panen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF183B2B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Legend: Pendapatan & Biaya
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF17633D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Pendapatan',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0C66A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Biaya',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Grafik Bar Chart
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFDFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5EDE8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBarGroup(
                            namaPanen: 'Panen 1',
                            labelPendapatan: labelPendapatanPerPanen,
                            labelBiaya: '$labelBiayaPerPanen jt',
                            rasioPendapatan: 1.0,
                            rasioBiaya: 0.60,
                          ),
                          _buildBarGroup(
                            namaPanen: 'Panen 2',
                            labelPendapatan: labelPendapatanPerPanen,
                            labelBiaya: '$labelBiayaPerPanen jt',
                            rasioPendapatan: 1.0,
                            rasioBiaya: 0.60,
                          ),
                          _buildBarGroup(
                            namaPanen: 'Panen 3',
                            labelPendapatan: labelPendapatanPerPanen,
                            labelBiaya: '$labelBiayaPerPanen jt',
                            rasioPendapatan: 1.0,
                            rasioBiaya: 0.60,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Tombol Selesai / Ke Beranda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17633D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(model: model),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Simpan & Buka Beranda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.home_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
