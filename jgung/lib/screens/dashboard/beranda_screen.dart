import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';
import '../keuangan/form_pengeluaran_screen.dart';
import '../lahan/detail_penanaman_screen.dart';
import '../panen/form_panen_screen.dart';
import '../pengingat/pengingat_screen.dart';

class BerandaScreen extends StatelessWidget {
  final TaniJagungRepository repo;
  final Function(int)? onNavigateTab;

  const BerandaScreen({
    super.key,
    required this.repo,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final lands = repo.getLands();
        final activePlantings = repo.getActivePlantings();
        final reminders = repo.getReminders();
        final recentActivities = repo.getActivities().take(3).toList();

        // Hitung total luas lahan
        final double totalAreaHa = lands.fold(0.0, (sum, l) => sum + l.areaHa);

        // Hitung total pengeluaran untuk semua siklus aktif
        double totalActiveExpenses = 0.0;
        double totalActiveHarvestKg = 0.0;
        double totalActiveRevenue = 0.0;

        for (final p in activePlantings) {
          totalActiveExpenses += repo.getTotalExpensesForPlanting(p.plantingId);
          totalActiveHarvestKg += repo.getTotalHarvestKgForPlanting(p.plantingId);
          totalActiveRevenue += repo.getTotalRevenueForPlanting(p.plantingId);
        }

        final bool hasHarvest = totalActiveHarvestKg > 0;
        final double netProfit = totalActiveRevenue - totalActiveExpenses;
        final String profitStatus = TaniCalculator.determineProfitLossStatus(
          hasHarvestData: hasHarvest,
          revenue: hasHarvest ? totalActiveRevenue : null,
          totalExpenses: totalActiveExpenses,
        );

        return Scaffold(
          backgroundColor: AppColors.latar,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Demo Mode Banner jika aktif
                DemoBanner(isDemo: repo.isDemoMode),

                // Top Header (Hijau Tua)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.hijauTua,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Logo & Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.kuningJagung,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.eco, color: AppColors.hijauTua, size: 20),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'TaniJagung',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PengingatScreen(repo: repo)),
                                  );
                                },
                              ),
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.kuningJagung,
                                child: Icon(Icons.person, color: AppColors.hijauTua, size: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Greeting
                      Text(
                        'Halo, ${repo.currentUser.name}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semangat mengelola lahan jagungmu.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Kartu Ringkasan Total Lahan & Keuangan
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.landscape_outlined, color: AppColors.kuningJagung, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Total Lahan: ${lands.length} Petak (${TaniFormatter.angka(totalAreaHa, maxDecimals: 1)} ha)',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.kuningJagung,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${activePlantings.length} Siklus Aktif',
                                    style: const TextStyle(
                                      color: AppColors.hijauTua,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSummaryItem(
                                  label: 'Hasil Panen Aktual',
                                  value: hasHarvest
                                      ? '${TaniFormatter.angka(totalActiveHarvestKg)} kg'
                                      : 'Belum Dicatat',
                                  isHighlight: false,
                                ),
                                _buildSummaryItem(
                                  label: 'Total Biaya Aktif',
                                  value: TaniFormatter.rupiah(totalActiveExpenses),
                                  isHighlight: false,
                                ),
                                _buildSummaryItem(
                                  label: 'Laba / Status',
                                  value: hasHarvest
                                      ? TaniFormatter.rupiah(netProfit)
                                      : profitStatus,
                                  isHighlight: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol Aksi Cepat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aksi Cepat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teksUtama,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context: context,
                              icon: Icons.add_shopping_cart,
                              label: 'Tambah\nPengeluaran',
                              onTap: () {
                                if (activePlantings.isEmpty) {
                                  _showNoActivePlantingSnackbar(context);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormPengeluaranScreen(
                                      repo: repo,
                                      initialPlantingId: activePlantings.first.plantingId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionButton(
                              context: context,
                              icon: Icons.grain,
                              label: 'Catat\nPemupukan',
                              onTap: () {
                                if (activePlantings.isEmpty) {
                                  _showNoActivePlantingSnackbar(context);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormPengeluaranScreen(
                                      repo: repo,
                                      initialPlantingId: activePlantings.first.plantingId,
                                      initialCategory: 'Pupuk',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionButton(
                              context: context,
                              icon: Icons.inventory_outlined,
                              label: 'Input\nHasil Panen',
                              onTap: () {
                                if (activePlantings.isEmpty) {
                                  _showNoActivePlantingSnackbar(context);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormPanenScreen(
                                      repo: repo,
                                      initialPlantingId: activePlantings.first.plantingId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bagian Musim Tanam Aktif
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Musim Tanam Aktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teksUtama,
                        ),
                      ),
                      if (onNavigateTab != null)
                        TextButton(
                          onPressed: () => onNavigateTab!(1), // Tab Lahan
                          child: const Text('Lihat Semua'),
                        ),
                    ],
                  ),
                ),

                if (activePlantings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: TaniCard(
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.grass_outlined, size: 48, color: AppColors.teksPudar),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada penanaman aktif.',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.teksUtama),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Buka tab Lahan untuk memulai siklus penanaman jagung baru.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                            ),
                            const SizedBox(height: 12),
                            TaniButton(
                              text: 'Mulai Penanaman',
                              isFullWidth: false,
                              onPressed: () => onNavigateTab?.call(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...activePlantings.map((planting) {
                    final land = repo.getLandById(planting.landId);
                    final expenses = repo.getTotalExpensesForPlanting(planting.plantingId);
                    final harvestKg = repo.getTotalHarvestKgForPlanting(planting.plantingId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: TaniCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPenanamanScreen(
                                repo: repo,
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
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.teksUtama,
                                    ),
                                  ),
                                ),
                                const TaniBadge(label: 'AKTIF'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              land != null ? '${land.name} • ${TaniFormatter.angka(land.areaHa)} ha' : '-',
                              style: const TextStyle(fontSize: 13, color: AppColors.teksSekunder),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Mulai Tanam', style: TextStyle(fontSize: 11, color: AppColors.teksPudar)),
                                      Text(
                                        TaniFormatter.tanggalSingkat(planting.plantingDate),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Perkiraan Panen', style: TextStyle(fontSize: 11, color: AppColors.teksPudar)),
                                      Text(
                                        TaniFormatter.tanggalSingkat(planting.estimatedHarvestDate),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.hijau),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Biaya', style: TextStyle(fontSize: 11, color: AppColors.teksPudar)),
                                      Text(
                                        TaniFormatter.rupiah(expenses),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  harvestKg > 0
                                      ? 'Panen Tercatat: ${TaniFormatter.angka(harvestKg)} kg'
                                      : 'Hasil panen belum dicatat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: harvestKg > 0 ? AppColors.untung : AppColors.teksPudar,
                                    fontWeight: harvestKg > 0 ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Text('Detail', style: TextStyle(fontSize: 12, color: AppColors.hijau, fontWeight: FontWeight.bold)),
                                    Icon(Icons.chevron_right, size: 16, color: AppColors.hijau),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 16),

                // Kegiatan Terdekat / Pengingat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kegiatan Terdekat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teksUtama,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PengingatScreen(repo: repo)),
                          );
                        },
                        child: const Text('Kelola'),
                      ),
                    ],
                  ),
                ),

                if (reminders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Tidak ada pengingat aktif.', style: TextStyle(color: AppColors.teksSekunder)),
                  )
                else
                  ...reminders.take(3).map((r) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: TaniCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.hijauPudar,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.event_note, color: AppColors.hijauTua, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: r.isCompleted ? TextDecoration.lineThrough : null,
                                        color: r.isCompleted ? AppColors.teksPudar : AppColors.teksUtama,
                                      ),
                                    ),
                                    Text(
                                      TaniFormatter.tanggalSingkat(r.scheduledDate),
                                      style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                activeColor: AppColors.hijauTua,
                                value: r.isCompleted,
                                onChanged: (_) => repo.toggleReminder(r.reminderId),
                              ),
                            ],
                          ),
                        ),
                      )),

                const SizedBox(height: 24),

                // Aktivitas Terakhir
                if (recentActivities.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Aktivitas Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teksUtama,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recentActivities.map((act) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: TaniCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.kuningPudar,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.history_edu, color: AppColors.kuningJagung, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          act.type,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                        ),
                                        Text(
                                          TaniFormatter.tanggalSingkat(act.date),
                                          style: const TextStyle(fontSize: 11, color: AppColors.teksPudar),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      act.description,
                                      style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required bool isHighlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppColors.kuningJagungTerang : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.garis),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.hijauPudar,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.hijauTua, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teksUtama,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoActivePlantingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Belum ada siklus penanaman aktif. Tambahkan siklus penanaman di menu Lahan terlebih dahulu.'),
        backgroundColor: AppColors.hijauTua,
      ),
    );
  }
}
