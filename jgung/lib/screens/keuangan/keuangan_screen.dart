import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';
import '../simulasi/simulasi_keuntungan_screen.dart';
import 'form_pengeluaran_screen.dart';

class KeuanganScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const KeuanganScreen({super.key, required this.repo});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPlantingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final plantings = widget.repo.getPlantings();
        final expenses = widget.repo.getExpenses(plantingId: _selectedPlantingId);
        final breakdown = widget.repo.getExpenseCategoryBreakdown(_selectedPlantingId);

        double totalExpense = 0.0;
        breakdown.forEach((_, v) => totalExpense += v);

        double totalRevenue = 0.0;
        double totalHarvestKg = 0.0;

        if (_selectedPlantingId != null) {
          totalRevenue = widget.repo.getTotalRevenueForPlanting(_selectedPlantingId!);
          totalHarvestKg = widget.repo.getTotalHarvestKgForPlanting(_selectedPlantingId!);
        } else {
          for (final p in plantings) {
            totalRevenue += widget.repo.getTotalRevenueForPlanting(p.plantingId);
            totalHarvestKg += widget.repo.getTotalHarvestKgForPlanting(p.plantingId);
          }
        }

        final bool hasHarvest = totalHarvestKg > 0;
        final double netProfit = totalRevenue - totalExpense;
        final String profitStatus = TaniCalculator.determineProfitLossStatus(
          hasHarvestData: hasHarvest,
          revenue: hasHarvest ? totalRevenue : null,
          totalExpenses: totalExpense,
        );

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Keuangan Usaha Tani'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.calculate_outlined, color: Colors.white),
                tooltip: 'Simulasi Keuntungan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SimulasiKeuntunganScreen()),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.kuningJagung,
              labelColor: AppColors.kuningJagung,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Analisis Biaya & Laba'),
                Tab(text: 'Daftar Pengeluaran'),
              ],
            ),
          ),
          body: Column(
            children: [
              DemoBanner(isDemo: widget.repo.isDemoMode),

              // Filter Dropdown Siklus Penanaman
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 20, color: AppColors.hijau),
                    const SizedBox(width: 8),
                    const Text('Filter Siklus:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: _selectedPlantingId,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Semua Siklus Penanaman')),
                          ...plantings.map((p) => DropdownMenuItem(
                                value: p.plantingId,
                                child: Text('${p.name} (${p.cornVariety})'),
                              )),
                        ],
                        onChanged: (val) => setState(() => _selectedPlantingId = val),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: Analisis Biaya & Komposisi
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kartu Laba / Rugi Bersih
                          TaniCard(
                            color: AppColors.hijauTua,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Ringkasan Finansial Aktual',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    TaniBadge(label: profitStatus),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasHarvest ? TaniFormatter.rupiah(netProfit) : TaniFormatter.rupiah(-totalExpense),
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: hasHarvest
                                        ? (netProfit >= 0 ? AppColors.kuningJagungTerang : AppColors.rugi)
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasHarvest
                                      ? (netProfit >= 0 ? 'Keuntungan Bersih Tercatat' : 'Kerugian Bersih Tercatat')
                                      : 'Total biaya berjalan (Hasil panen belum dicatat)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const Divider(color: Colors.white24, height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Total Pendapatan', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        Text(
                                          hasHarvest ? TaniFormatter.rupiah(totalRevenue) : 'Rp 0',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Total Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        Text(
                                          TaniFormatter.rupiah(totalExpense),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Hasil Panen', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                        Text(
                                          hasHarvest ? '${TaniFormatter.angka(totalHarvestKg)} kg' : '-',
                                          style: const TextStyle(color: AppColors.kuningJagungTerang, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Komposisi Kategori Biaya
                          TaniCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Komposisi Pengeluaran',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                                    ),
                                    Text(
                                      TaniFormatter.rupiah(totalExpense),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.hijau),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                if (breakdown.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('Belum ada transaksi pengeluaran.', style: TextStyle(color: AppColors.teksSekunder)),
                                    ),
                                  )
                                else
                                  ...breakdown.entries.map((entry) {
                                    final double pct = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;
                                    final Color barColor = _getCategoryColor(entry.key);

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(color: barColor, shape: BoxShape.circle),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    entry.key,
                                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${TaniFormatter.angka(pct, maxDecimals: 1)}% (${TaniFormatter.rupiah(entry.value)})',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teksSekunder),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: totalExpense > 0 ? entry.value / totalExpense : 0,
                                              backgroundColor: AppColors.latar,
                                              valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tombol Masuk ke Simulasi Keuntungan
                          TaniCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SimulasiKeuntunganScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.kuningPudar,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.insights, color: AppColors.kuningJagung, size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Simulasi Keuntungan',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Uji skenario hasil panen dan harga jual tanpa mengubah pembukuan.',
                                        style: TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.black45),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TAB 2: Daftar Transaksi Pengeluaran
                    expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.teksPudar),
                                const SizedBox(height: 12),
                                const Text('Belum ada transaksi pengeluaran.', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                TaniButton(
                                  text: 'Tambah Pengeluaran',
                                  isFullWidth: false,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FormPengeluaranScreen(
                                          repo: widget.repo,
                                          initialPlantingId: _selectedPlantingId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: expenses.length,
                            itemBuilder: (context, idx) {
                              final exp = expenses[idx];
                              return TaniCard(
                                margin: const EdgeInsets.only(bottom: 10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FormPengeluaranScreen(
                                        repo: widget.repo,
                                        existingExpense: exp,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(exp.category).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        exp.category == 'Pupuk' ? Icons.grain : Icons.receipt_long,
                                        color: _getCategoryColor(exp.category),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp.description,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${exp.category} • ${TaniFormatter.tanggalSingkat(exp.date)}'
                                            '${exp.quantity != null ? " (${TaniFormatter.angka(exp.quantity)} ${exp.unit ?? ''})" : ""}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      TaniFormatter.rupiah(exp.amount),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.teksUtama),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormPengeluaranScreen(
                    repo: widget.repo,
                    initialPlantingId: _selectedPlantingId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Catat Biaya'),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pupuk':
        return const Color(0xFF2E7D32);
      case 'Benih':
        return const Color(0xFFF9A825);
      case 'Pestisida':
        return const Color(0xFFC62828);
      case 'Pengolahan Lahan':
        return const Color(0xFF6A1B9A);
      case 'Tenaga Kerja':
        return const Color(0xFF0277BD);
      default:
        return const Color(0xFF546E7A);
    }
  }
}
