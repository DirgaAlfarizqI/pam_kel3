import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';

class PrediksiPanenScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const PrediksiPanenScreen({super.key, required this.repo});

  @override
  State<PrediksiPanenScreen> createState() => _PrediksiPanenScreenState();
}

class _PrediksiPanenScreenState extends State<PrediksiPanenScreen> {
  String? _selectedPlantingId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final plantings = widget.repo.getActivePlantings();
        if (_selectedPlantingId == null && plantings.isNotEmpty) {
          _selectedPlantingId = plantings.first.plantingId;
        }

        final selectedPlanting = _selectedPlantingId != null
            ? widget.repo.getPlantingById(_selectedPlantingId!)
            : null;
        final selectedLand = selectedPlanting != null
            ? widget.repo.getLandById(selectedPlanting.landId)
            : null;

        // Hitung estimasi berbasis rata-rata data historis pengguna jika ada
        final finishedPlantings = widget.repo.getFinishedPlantings();
        double totalHistYieldKg = 0;
        double totalHistAreaHa = 0;

        for (final fp in finishedPlantings) {
          final land = widget.repo.getLandById(fp.landId);
          final harvestKg = widget.repo.getTotalHarvestKgForPlanting(fp.plantingId);
          if (harvestKg > 0 && land != null && land.areaHa > 0) {
            totalHistYieldKg += harvestKg;
            totalHistAreaHa += land.areaHa;
          }
        }

        final bool hasHistory = totalHistAreaHa > 0;
        final double avgHistProductivity = hasHistory ? (totalHistYieldKg / totalHistAreaHa) : 0.0;

        double estimatedYieldKg = 0.0;
        if (hasHistory && selectedLand != null) {
          estimatedYieldKg = avgHistProductivity * selectedLand.areaHa;
        }

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Estimasi Hasil Panen'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DemoBanner(isDemo: widget.repo.isDemoMode),

                // Penjelasan Transparansi & Metode
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PEMBERITAHUAN METODE ESTIMASI',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1565C0)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Aplikasi ini tidak menggunakan klaim model machine learning otomatis tanpa dataset tervalidasi. '
                              'Estimasi di bawah dihitung murni berdasarkan rata-rata produktivitas historis siklus panen sebelumnya di lahan Anda. '
                              'Hasil panen aktual tetap wajib dicatat manual setelah penimbangan panen selesai.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF0D47A1), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pilih Siklus Aktif
                TaniCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Siklus Penanaman Aktif',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.teksUtama),
                      ),
                      const SizedBox(height: 8),
                      if (plantings.isEmpty)
                        const Text(
                          'Belum ada siklus penanaman aktif saat ini.',
                          style: TextStyle(color: AppColors.teksSekunder),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedPlantingId,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: plantings.map((p) {
                            final l = widget.repo.getLandById(p.landId);
                            return DropdownMenuItem(
                              value: p.plantingId,
                              child: Text('${p.name} - ${l?.name ?? ""} (${p.cornVariety})'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedPlantingId = val),
                        ),
                      if (selectedLand != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.square_foot, size: 16, color: AppColors.hijau),
                            const SizedBox(width: 6),
                            Text(
                              'Luas Lahan: ${TaniFormatter.angka(selectedLand.areaHa)} Hektare (ha)',
                              style: const TextStyle(fontSize: 13, color: AppColors.teksSekunder),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Kartu Estimasi Berdasarkan Data Historis
                TaniCard(
                  color: AppColors.hijauTua,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimasi Berdasarkan Data Historis',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      if (!hasHistory) ...[
                        const Text(
                          'Belum Tersedia',
                          style: TextStyle(color: AppColors.kuningJagungTerang, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Estimasi memerlukan minimal satu siklus panen sebelumnya yang tercatat untuk menghitung rata-rata produktivitas riil.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${TaniFormatter.angka(estimatedYieldKg)} kg',
                              style: const TextStyle(color: AppColors.kuningJagungTerang, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${TaniFormatter.angka(estimatedYieldKg / 1000.0, maxDecimals: 2)} Ton)',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Berdasarkan rata-rata historis produktivitas usaha tani Anda: '
                          '${TaniFormatter.angka(avgHistProductivity / 1000.0, maxDecimals: 2)} ton/ha.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info Integrasi ML Di Masa Depan
                TaniCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.hub_outlined, color: AppColors.hijauTua),
                          SizedBox(width: 8),
                          Text(
                            'Status Integrasi Model Machine Learning',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      const Text(
                        'Modul prediksi berbasis AI/ML saat ini berstatus: Belum Terintegrasi Dataset.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.peringatan),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Untuk menjaga integritas data keuangan petani jagung, TaniJagung tidak menampilkan persentase akurasi acak atau perkiraan tanpa bukti validasi ilmiah.',
                        style: TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
