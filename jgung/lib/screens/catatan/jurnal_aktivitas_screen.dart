import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';
import 'form_aktivitas_screen.dart';

class JurnalAktivitasScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const JurnalAktivitasScreen({super.key, required this.repo});

  @override
  State<JurnalAktivitasScreen> createState() => _JurnalAktivitasScreenState();
}

class _JurnalAktivitasScreenState extends State<JurnalAktivitasScreen> {
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Penanaman',
    'Pemupukan',
    'Pestisida',
    'Pengolahan Lahan',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final allActivities = widget.repo.getActivities();
        final filteredActivities = _selectedFilter == 'Semua'
            ? allActivities
            : allActivities.where((a) => a.type.toLowerCase().contains(_selectedFilter.toLowerCase())).toList();

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Jurnal Aktivitas Penanaman'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              DemoBanner(isDemo: widget.repo.isDemoMode),

              // Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final bool isSel = f == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSel,
                          selectedColor: AppColors.hijauTua,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.teksUtama,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSel ? AppColors.hijauTua : AppColors.garis),
                          ),
                          onSelected: (_) => setState(() => _selectedFilter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(
                child: filteredActivities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_edu_outlined, size: 64, color: AppColors.teksPudar),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada catatan aktivitas',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Catat setiap kegiatan penanaman, pemupukan, dan pengolahan lahan Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.teksSekunder),
                            ),
                            const SizedBox(height: 16),
                            TaniButton(
                              text: 'Catat Aktivitas Pertama',
                              isFullWidth: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => FormAktivitasScreen(repo: widget.repo)),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredActivities.length,
                        itemBuilder: (context, index) {
                          final act = filteredActivities[index];
                          final planting = widget.repo.getPlantingById(act.plantingId);
                          final land = planting != null ? widget.repo.getLandById(planting.landId) : null;

                          return TaniCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline indicator icon
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getIconBgColor(act.type),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_getActivityIcon(act.type), color: AppColors.hijauTua, size: 22),
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
                                            TaniFormatter.tanggal(act.date),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.hijau,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.latar,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              act.type,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        act.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.teksUtama,
                                        ),
                                      ),
                                      if (act.quantity != null || act.cost != null) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.kuningPudar,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${act.quantity != null ? "${TaniFormatter.angka(act.quantity)} ${act.unit ?? ''} " : ""}'
                                            '${act.cost != null ? "• Biaya: ${TaniFormatter.rupiah(act.cost)}" : ""}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teksUtama),
                                          ),
                                        ),
                                      ],
                                      if (act.notes != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          act.notes!,
                                          style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(
                                        '${planting?.name ?? "Penanaman"} • ${land?.name ?? ""}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.teksPudar),
                                      ),
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormAktivitasScreen(repo: widget.repo)),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Catat Aktivitas'),
          ),
        );
      },
    );
  }

  Color _getIconBgColor(String type) {
    if (type.toLowerCase().contains('pupuk')) return AppColors.hijauPudar;
    if (type.toLowerCase().contains('tanam')) return const Color(0xFFE8F5E9);
    if (type.toLowerCase().contains('pestisida')) return const Color(0xFFFFEBEE);
    return AppColors.kuningPudar;
  }

  IconData _getActivityIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('pupuk')) return Icons.grain;
    if (t.contains('tanam')) return Icons.grass;
    if (t.contains('pestisida')) return Icons.bug_report_outlined;
    if (t.contains('air') || t.contains('siram')) return Icons.water_drop_outlined;
    if (t.contains('olah')) return Icons.agriculture_outlined;
    if (t.contains('panen')) return Icons.inventory_2_outlined;
    return Icons.history_edu;
  }
}
