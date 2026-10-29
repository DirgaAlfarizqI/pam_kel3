import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';
import '../lahan/detail_penanaman_screen.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const RiwayatLaporanScreen({super.key, required this.repo});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  String _selectedFilter = 'Semua';
  String? _selectedLandId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final lands = widget.repo.getLands();
        final allPlantings = widget.repo.getPlantings(landId: _selectedLandId);

        final filtered = allPlantings.where((p) {
          if (_selectedFilter == 'Selesai') return p.isSelesai;
          if (_selectedFilter == 'Aktif') return p.isAktif;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Riwayat & Laporan Usaha Tani'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              DemoBanner(isDemo: widget.repo.isDemoMode),

              // Filter Controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    // Status Filter
                    DropdownButton<String>(
                      value: _selectedFilter,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua Status')),
                        DropdownMenuItem(value: 'Selesai', child: Text('Siklus Selesai')),
                        DropdownMenuItem(value: 'Aktif', child: Text('Sedang Aktif')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFilter = val);
                      },
                    ),
                    const Spacer(),
                    // Land Filter
                    DropdownButton<String?>(
                      value: _selectedLandId,
                      underline: const SizedBox.shrink(),
                      hint: const Text('Semua Lahan'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Semua Lahan')),
                        ...lands.map((l) => DropdownMenuItem(value: l.landId, child: Text(l.name))),
                      ],
                      onChanged: (val) => setState(() => _selectedLandId = val),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada riwayat penanaman yang sesuai kriteria.',
                          style: TextStyle(color: AppColors.teksSekunder),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final planting = filtered[idx];
                          final land = widget.repo.getLandById(planting.landId);
                          final totalExpense = widget.repo.getTotalExpensesForPlanting(planting.plantingId);
                          final harvestRecords = widget.repo.getHarvestRecords(plantingId: planting.plantingId);
                          final totalHarvestKg = widget.repo.getTotalHarvestKgForPlanting(planting.plantingId);
                          final totalRevenue = widget.repo.getTotalRevenueForPlanting(planting.plantingId);
                          final bool hasHarvest = harvestRecords.isNotEmpty;

                          final double netProfit = totalRevenue - totalExpense;
                          final double productivity = (land != null && land.areaHa > 0 && hasHarvest)
                              ? TaniCalculator.calculateProductivity(harvestKg: totalHarvestKg, areaHa: land.areaHa)
                              : 0.0;

                          final String status = TaniCalculator.determineProfitLossStatus(
                            hasHarvestData: hasHarvest,
                            revenue: hasHarvest ? totalRevenue : null,
                            totalExpenses: totalExpense,
                          );

                          return TaniCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPenanamanScreen(
                                    repo: widget.repo,
                                    plantingId: planting.plantingId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${planting.name} (${planting.cornVariety})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    TaniBadge(label: planting.isSelesai ? status : 'AKTIF'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${land?.name ?? ""} • Luas: ${land != null ? TaniFormatter.angka(land.areaHa) : "-"} ha',
                                  style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                ),
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMiniStat(
                                        'Mulai Tanam',
                                        TaniFormatter.tanggalSingkat(planting.plantingDate),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMiniStat(
                                        'Panen Aktual',
                                        planting.actualHarvestDate != null
                                            ? TaniFormatter.tanggalSingkat(planting.actualHarvestDate)
                                            : 'Belum Panen',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMiniStat(
                                        'Produktivitas',
                                        hasHarvest ? '${TaniFormatter.angka(productivity, maxDecimals: 2)} t/ha' : '-',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMiniStat(
                                        'Total Biaya',
                                        TaniFormatter.rupiah(totalExpense),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMiniStat(
                                        'Hasil Panen',
                                        hasHarvest ? '${TaniFormatter.angka(totalHarvestKg)} kg' : 'Belum Dicatat',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMiniStat(
                                        'Laba Bersih',
                                        hasHarvest ? TaniFormatter.rupiah(netProfit) : '-',
                                        isColored: hasHarvest,
                                        isPositive: netProfit >= 0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Buka Laporan Penuh', style: TextStyle(fontSize: 12, color: AppColors.hijau, fontWeight: FontWeight.bold)),
                                      Icon(Icons.chevron_right, size: 16, color: AppColors.hijau),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isColored = false, bool isPositive = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.teksPudar)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isColored
                ? (isPositive ? AppColors.untung : AppColors.rugi)
                : AppColors.teksUtama,
          ),
        ),
      ],
    );
  }
}
