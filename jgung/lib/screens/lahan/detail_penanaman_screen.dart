import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';
import '../catatan/form_aktivitas_screen.dart';
import '../keuangan/form_pengeluaran_screen.dart';
import '../panen/form_panen_screen.dart';

class DetailPenanamanScreen extends StatelessWidget {
  final TaniJagungRepository repo;
  final String plantingId;

  const DetailPenanamanScreen({
    super.key,
    required this.repo,
    required this.plantingId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final planting = repo.getPlantingById(plantingId);
        if (planting == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Penanaman')),
            body: const Center(child: Text('Data penanaman tidak ditemukan')),
          );
        }

        final land = repo.getLandById(planting.landId);
        final expenses = repo.getExpenses(plantingId: plantingId);
        final activities = repo.getActivities(plantingId: plantingId);
        final harvests = repo.getHarvestRecords(plantingId: plantingId);

        final double totalExpense = repo.getTotalExpensesForPlanting(plantingId);
        final double totalHarvestKg = repo.getTotalHarvestKgForPlanting(plantingId);
        final double totalRevenue = repo.getTotalRevenueForPlanting(plantingId);
        final bool hasHarvest = harvests.isNotEmpty;

        final double netProfit = TaniCalculator.calculateProfitLoss(totalRevenue, totalExpense);
        final String profitStatus = TaniCalculator.determineProfitLossStatus(
          hasHarvestData: hasHarvest,
          revenue: hasHarvest ? totalRevenue : null,
          totalExpenses: totalExpense,
        );

        final double productivity = (land != null && hasHarvest)
            ? TaniCalculator.calculateProductivity(harvestKg: totalHarvestKg, areaHa: land.areaHa)
            : 0.0;

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: Text(planting.name),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Informasi Utama Lahan & Penanaman
                TaniCard(
                  color: AppColors.hijauTua,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              land?.name ?? 'Lahan Jagung',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          TaniBadge(label: planting.status.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.square_foot, size: 16, color: AppColors.kuningJagung),
                          const SizedBox(width: 6),
                          Text(
                            'Luas Lahan: ${land != null ? TaniFormatter.angka(land.areaHa) : "-"} ha',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.grass, size: 16, color: AppColors.kuningJagung),
                          const SizedBox(width: 6),
                          Text(
                            'Varietas: ${planting.cornVariety}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mulai Tanam', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  TaniFormatter.tanggalSingkat(planting.plantingDate),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Perkiraan Panen', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  TaniFormatter.tanggalSingkat(planting.estimatedHarvestDate),
                                  style: const TextStyle(color: AppColors.kuningJagungTerang, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Panen Aktual', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  planting.actualHarvestDate != null
                                      ? TaniFormatter.tanggalSingkat(planting.actualHarvestDate)
                                      : 'Belum Panen',
                                  style: TextStyle(
                                    color: planting.actualHarvestDate != null ? Colors.white : Colors.white60,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tombol Aksi Langsung
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.hijauTua,
                          side: const BorderSide(color: AppColors.hijau),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormPengeluaranScreen(
                                repo: repo,
                                initialPlantingId: plantingId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Catat Biaya', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.hijauTua,
                          side: const BorderSide(color: AppColors.hijau),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormPengeluaranScreen(
                                repo: repo,
                                initialPlantingId: plantingId,
                                initialCategory: 'Pupuk',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.grain, size: 18),
                        label: const Text('Pemupukan', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kuningJagung,
                          foregroundColor: AppColors.teksUtama,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormPanenScreen(
                                repo: repo,
                                initialPlantingId: plantingId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.inventory_2_outlined, size: 18),
                        label: const Text('Panen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Ringkasan Finansial Siklus Ini
                TaniCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ringkasan Keuangan Siklus',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                          ),
                          TaniBadge(label: profitStatus),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildInfoRow('Total Pengeluaran Valid', TaniFormatter.rupiah(totalExpense)),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Hasil Panen Aktual',
                        hasHarvest ? '${TaniFormatter.angka(totalHarvestKg)} kg (${TaniFormatter.angka(totalHarvestKg / 1000.0)} ton)' : 'Belum Dicatat',
                        textColor: hasHarvest ? AppColors.teksUtama : AppColors.peringatan,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Total Pendapatan Panen',
                        hasHarvest ? TaniFormatter.rupiah(totalRevenue) : 'Belum Ada',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Produktivitas Panen',
                        hasHarvest ? '${TaniFormatter.angka(productivity, maxDecimals: 2)} ton/ha' : 'Belum Tersedia',
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Laba / Rugi Bersih:',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                          ),
                          Text(
                            hasHarvest ? TaniFormatter.rupiah(netProfit) : '-',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: !hasHarvest
                                  ? AppColors.teksPudar
                                  : (netProfit >= 0 ? AppColors.untung : AppColors.rugi),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Riwayat Pengeluaran Siklus
                TaniCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rincian Biaya (${expenses.length} Transaksi)',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.hijau),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormPengeluaranScreen(
                                    repo: repo,
                                    initialPlantingId: plantingId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      if (expenses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Belum ada catatan pengeluaran untuk siklus ini.',
                              style: TextStyle(color: AppColors.teksSekunder),
                            ),
                          ),
                        )
                      else
                        ...expenses.map((exp) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.hijauPudar,
                                child: Icon(
                                  exp.category == 'Pupuk' ? Icons.grain : Icons.receipt_long,
                                  color: AppColors.hijauTua,
                                  size: 20,
                                ),
                              ),
                              title: Text(exp.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(
                                '${exp.category} • ${TaniFormatter.tanggalSingkat(exp.date)}'
                                '${exp.quantity != null ? " (${TaniFormatter.angka(exp.quantity)} ${exp.unit ?? ''})" : ""}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                TaniFormatter.rupiah(exp.amount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormPengeluaranScreen(
                                      repo: repo,
                                      existingExpense: exp,
                                    ),
                                  ),
                                );
                              },
                            )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Riwayat Aktivitas Siklus
                TaniCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jurnal Aktivitas (${activities.length})',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.hijau),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormAktivitasScreen(
                                    repo: repo,
                                    initialPlantingId: plantingId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      if (activities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Belum ada aktivitas tercatat untuk siklus ini.',
                              style: TextStyle(color: AppColors.teksSekunder),
                            ),
                          ),
                        )
                      else
                        ...activities.map((act) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.kuningPudar,
                                child: const Icon(Icons.history_edu, color: AppColors.kuningJagung, size: 20),
                              ),
                              title: Text(act.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text('${act.description} • ${TaniFormatter.tanggalSingkat(act.date)}', style: const TextStyle(fontSize: 12)),
                            )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.teksSekunder)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.teksUtama,
          ),
        ),
      ],
    );
  }
}
