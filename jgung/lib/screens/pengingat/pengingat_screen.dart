import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../models/app_models.dart';
import '../../repositories/tani_jagung_repository.dart';

class PengingatScreen extends StatefulWidget {
  final TaniJagungRepository repo;

  const PengingatScreen({super.key, required this.repo});

  @override
  State<PengingatScreen> createState() => _PengingatScreenState();
}

class _PengingatScreenState extends State<PengingatScreen> {
  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime pickedDate = DateTime.now().add(const Duration(days: 3));
    String? selectedPlantingId;

    final plantings = widget.repo.getActivePlantings();
    if (plantings.isNotEmpty) {
      selectedPlantingId = plantings.first.plantingId;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Buat Pengingat Baru', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Judul Pengingat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Pemupukan Susulan Ke-2',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tanggal Pengingat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: pickedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() => pickedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.latar,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.garis),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event, color: AppColors.hijau, size: 20),
                          const SizedBox(width: 8),
                          Text(TaniFormatter.tanggal(pickedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (plantings.isNotEmpty) ...[
                    const Text('Terkait Siklus Penanaman', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedPlantingId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: plantings.map((p) => DropdownMenuItem(value: p.plantingId, child: Text(p.name))).toList(),
                      onChanged: (val) => setModalState(() => selectedPlantingId = val),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text('Keterangan (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Dosis pupuk yang direncanakan, toko pembelian, dll.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hijauTua,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  widget.repo.addReminder(
                    title: titleController.text.trim(),
                    scheduledDate: pickedDate,
                    plantingId: selectedPlantingId,
                    description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final reminders = widget.repo.getReminders();

        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Pengingat & Notifikasi'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none, size: 64, color: AppColors.teksPudar),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada jadwal pengingat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Buat pengingat jadwal pemupukan, pencatatan biaya, atau perkiraan panen Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.teksSekunder),
                      ),
                      const SizedBox(height: 16),
                      TaniButton(
                        text: 'Buat Pengingat Pertama',
                        isFullWidth: false,
                        onPressed: _showAddReminderDialog,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reminders.length,
                  itemBuilder: (context, idx) {
                    final r = reminders[idx];
                    final planting = r.plantingId != null ? widget.repo.getPlantingById(r.plantingId!) : null;

                    return TaniCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            activeColor: AppColors.hijauTua,
                            value: r.isCompleted,
                            onChanged: (_) => widget.repo.toggleReminder(r.reminderId),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    decoration: r.isCompleted ? TextDecoration.lineThrough : null,
                                    color: r.isCompleted ? AppColors.teksPudar : AppColors.teksUtama,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jadwal: ${TaniFormatter.tanggal(r.scheduledDate)}'
                                  '${planting != null ? " • ${planting.name}" : ""}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder),
                                ),
                                if (r.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    r.description!,
                                    style: const TextStyle(fontSize: 12, color: AppColors.teksPudar),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.rugi),
                            onPressed: () => widget.repo.deleteReminder(r.reminderId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
            onPressed: _showAddReminderDialog,
            icon: const Icon(Icons.alarm_add),
            label: const Text('Tambah Pengingat'),
          ),
        );
      },
    );
  }
}
