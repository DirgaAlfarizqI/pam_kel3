import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';

class AnalisisProduktivitasScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const AnalisisProduktivitasScreen({super.key, required this.repo});

  @override
  State<AnalisisProduktivitasScreen> createState() => _AnalisisProduktivitasScreenState();
}

class _AnalisisProduktivitasScreenState extends State<AnalisisProduktivitasScreen> {
  String? _selectedLandId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final lands = widget.repo.getLands();
        final plantings = widget.repo.getPlantings(landId: _selectedLandId);

        // Kumpulkan siklus yang sudah memiliki data hasil panen tercatat
        final List<Map<String, dynamic>> productivityItems = [];

        for (final p in plantings) {
          final land = widget.repo.getLandById(p.landId);
          final double harvestKg = widget.repo.getTotalHarvestKgForPlanting(p.plantingId);
          if (harvestKg > 0 && land != null && land.areaHa > 0) {
            final double prodTonPerHa = TaniCalculator.calculateProductivity(
              harvestKg: harvestKg,
              areaHa: land.areaHa,
            );
            productivityItems.add({
              'planting': p,
              'land': land,
              'harvestKg': harvestKg,
              'harvestTon': harvestKg / 1000.0,
              'areaHa': land.areaHa,
              'productivity': prodTonPerHa,
            });
          }
        }

        // Hitung rata-rata produktivitas
        double avgProductivity = 0.0;
        if (productivityItems.isNotEmpty) {
          final double sum = productivityItems.fold(0.0, (acc, item) => acc + (item['productivity'] as double));
          avgProductivity = sum / productivityItems.length;
        }

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Analisis Produktivitas'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DemoBanner(isDemo: widget.repo.isDemoMode),

                // Kartu Formula Produktivitas Transparan
                TaniCard(
                  color: const Color(0xFFF1F8F4),
                  border: Border.all(color: AppColors.hijau.withOpacity(0.3)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.hijauPudar,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calculate, color: AppColors.hijauTua, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rumus Produktivitas Aktual',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.hijauTua),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'produktivitas (ton/ha) = hasilPanenTon / luasLahanHa',
                              style: TextStyle(fontSize: 12, color: AppColors.teksUtama, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Lahan
                Row(
                  children: [
                    const Text('Filter Lahan:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.garis),
                        ),
                        child: DropdownButton<String?>(
                          value: _selectedLandId,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Semua Lahan')),
                            ...lands.map((l) => DropdownMenuItem(value: l.landId, child: Text(l.name))),
                          ],
                          onChanged: (val) => setState(() => _selectedLandId = val),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Kartu Ringkasan Rata-rata Produktivitas
                TaniCard(
                  color: AppColors.hijauTua,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rata-rata Produktivitas',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            avgProductivity > 0
                                ? '${TaniFormatter.angka(avgProductivity, maxDecimals: 2)} ton/ha'
                                : 'Belum Ada Panen',
                            style: const TextStyle(
                              color: AppColors.kuningJagungTerang,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dari ${productivityItems.length} siklus panen tercatat',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bar_chart, color: Colors.white, size: 36),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Perbandingan Produktivitas Tiap Siklus',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                ),
                const SizedBox(height: 12),

                if (productivityItems.isEmpty)
                  TaniCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.analytics_outlined, size: 48, color: AppColors.teksPudar),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada data panen aktual yang tercatat.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Setelah panen selesai, masukkan hasil panen aktual di halaman Detail Penanaman atau Input Panen.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...productivityItems.map((item) {
                    final PlantingModel p = item['planting'];
                    final LandModel l = item['land'];
                    final double prod = item['productivity'];
                    final double harvestTon = item['harvestTon'];
                    final double areaHa = item['areaHa'];

                    // Maksimum acuan untuk visualisasi bar (10 ton/ha)
                    final double ratio = (prod / 10.0).clamp(0.0, 1.0);

                    return TaniCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${p.name} (${p.cornVariety})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.hijauPudar,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${TaniFormatter.angka(prod, maxDecimals: 2)} ton/ha',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.hijauTua, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lahan: ${l.name} • Luas: ${TaniFormatter.angka(areaHa)} ha',
                            style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                          ),
                          const SizedBox(height: 12),

                          // Visual Bar Grafis
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 12,
                              backgroundColor: AppColors.latar,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.hijau),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Panen Aktual: ${TaniFormatter.angka(item['harvestKg'])} kg (${TaniFormatter.angka(harvestTon)} ton)',
                                style: const TextStyle(fontSize: 12, color: AppColors.teksUtama, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                p.actualHarvestDate != null
                                    ? TaniFormatter.tanggalSingkat(p.actualHarvestDate)
                                    : 'Selesai',
                                style: const TextStyle(fontSize: 11, color: AppColors.teksPudar),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
