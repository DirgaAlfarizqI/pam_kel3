import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';
import 'detail_penanaman_screen.dart';
import 'form_lahan_screen.dart';
import 'form_penanaman_screen.dart';

class LahanListScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const LahanListScreen({super.key, required this.repo});

  @override
  State<LahanListScreen> createState() => _LahanListScreenState();
}

class _LahanListScreenState extends State<LahanListScreen> {
  String _selectedFilterLandId = 'semua';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final lands = widget.repo.getLands();
        final filteredLands = _selectedFilterLandId == 'semua'
            ? lands
            : lands.where((l) => l.landId == _selectedFilterLandId).toList();

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Lahan & Penanaman'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                tooltip: 'Tambah Lahan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FormLahanScreen(repo: widget.repo)),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              DemoBanner(isDemo: widget.repo.isDemoMode),

              // Horizontal Filter Chips
              if (lands.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Semua Lahan',
                          isSelected: _selectedFilterLandId == 'semua',
                          onTap: () => setState(() => _selectedFilterLandId = 'semua'),
                        ),
                        ...lands.map((l) => _buildFilterChip(
                              label: l.name,
                              isSelected: _selectedFilterLandId == l.landId,
                              onTap: () => setState(() => _selectedFilterLandId = l.landId),
                            )),
                      ],
                    ),
                  ),
                ),

              Expanded(
                child: filteredLands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.landscape_outlined, size: 64, color: AppColors.teksPudar),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada data lahan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tambahkan lahan pertanian Anda untuk mulai mencatat siklus penanaman.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.teksSekunder),
                            ),
                            const SizedBox(height: 16),
                            TaniButton(
                              text: 'Tambah Lahan Sekarang',
                              isFullWidth: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => FormLahanScreen(repo: widget.repo)),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredLands.length,
                        itemBuilder: (context, index) {
                          final land = filteredLands[index];
                          final activePlanting = widget.repo
                              .getPlantings(landId: land.landId)
                              .where((p) => p.isAktif)
                              .toList();
                          final pastPlantings = widget.repo
                              .getPlantings(landId: land.landId)
                              .where((p) => p.isSelesai)
                              .toList();

                          return TaniCard(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            land.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.teksUtama,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Luas: ${TaniFormatter.angka(land.areaHa)} Hektare (ha)'
                                            '${land.locationNote != null ? " • ${land.locationNote}" : ""}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.hijau),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FormLahanScreen(
                                              repo: widget.repo,
                                              existingLand: land,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),

                                // Bagian Siklus Penanaman
                                if (activePlanting.isNotEmpty) ...[
                                  const Text(
                                    'Siklus Penanaman Aktif:',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.hijauTua),
                                  ),
                                  const SizedBox(height: 6),
                                  ...activePlanting.map((p) => Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.latar,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.garis),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${p.name} (${p.cornVariety})',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                                const TaniBadge(label: 'AKTIF'),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  'Tanam: ${TaniFormatter.tanggalSingkat(p.plantingDate)}',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Perkiraan: ${TaniFormatter.tanggalSingkat(p.estimatedHarvestDate)}',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.hijau, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.hijauTua,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => DetailPenanamanScreen(
                                                        repo: widget.repo,
                                                        plantingId: p.plantingId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text('Buka Detail', style: TextStyle(fontSize: 12)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.kuningPudar,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline, color: AppColors.peringatan, size: 20),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Tidak ada siklus penanaman aktif di lahan ini.',
                                            style: TextStyle(fontSize: 12, color: AppColors.teksUtama),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 8),

                                // Tombol Mulai Penanaman Baru di Lahan ini
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.hijauTua,
                                    side: const BorderSide(color: AppColors.hijau),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FormPenanamanScreen(
                                          repo: widget.repo,
                                          initialLandId: land.landId,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('+ Mulai Siklus Penanaman Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ),

                                if (pastPlantings.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${pastPlantings.length} siklus sebelumnya telah selesai tersimpan di Riwayat.',
                                    style: const TextStyle(fontSize: 11, color: AppColors.teksPudar),
                                  ),
                                ],
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
                MaterialPageRoute(builder: (_) => FormLahanScreen(repo: widget.repo)),
              );
            },
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Tambah Lahan'),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.hijauTua,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.teksUtama,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.hijauTua : AppColors.garis),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
