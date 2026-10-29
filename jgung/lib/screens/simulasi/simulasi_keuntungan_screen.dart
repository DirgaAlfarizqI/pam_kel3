import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/calculator.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';

class SimulasiKeuntunganScreen extends StatefulWidget {
  const SimulasiKeuntunganScreen({super.key});

  @override
  State<SimulasiKeuntunganScreen> createState() => _SimulasiKeuntunganScreenState();
}

class _SimulasiKeuntunganScreenState extends State<SimulasiKeuntunganScreen> {
  double _simulasiPanenKg = 8000.0;
  double _simulasiHargaJual = 4000.0;
  double _simulasiTotalBiaya = 12000000.0;

  @override
  Widget build(BuildContext context) {
    final double revenue = TaniCalculator.calculateHarvestRevenue(_simulasiPanenKg, _simulasiHargaJual);
    final double netProfit = TaniCalculator.calculateProfitLoss(revenue, _simulasiTotalBiaya);
    final String status = TaniCalculator.determineProfitLossStatus(
      hasHarvestData: true,
      revenue: revenue,
      totalExpenses: _simulasiTotalBiaya,
    );

    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        title: const Text('Simulasi Keuntungan'),
        backgroundColor: AppColors.hijauTua,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Peringatan Transparan: Simulasi Tidak Mengubah Pembukuan
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.kuningPudar,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.kuningJagung),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.peringatan, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIMULASI INTERAKTIF',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.peringatan),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Perhitungan di halaman ini hanya perkiraan skenario dan TIDAK akan mengubah atau memengaruhi data pembukuan keuangan aktual Anda.',
                          style: TextStyle(fontSize: 12, color: AppColors.teksUtama),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kartu Hasil Simulasi
            TaniCard(
              color: AppColors.hijauTua,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimasi Hasil Simulasi',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      TaniBadge(label: status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TaniFormatter.rupiah(netProfit),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0 ? AppColors.kuningJagungTerang : AppColors.rugi,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    netProfit >= 0 ? 'Potensi Keuntungan Bersih' : 'Potensi Kerugian',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pendapatan Kotor', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            TaniFormatter.rupiah(revenue),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Perkiraan Biaya', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            TaniFormatter.rupiah(_simulasiTotalBiaya),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Volume Panen', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${TaniFormatter.angka(_simulasiPanenKg / 1000.0)} Ton',
                            style: const TextStyle(color: AppColors.kuningJagungTerang, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kontrol Parameter Simulasi
            TaniCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Parameter Skenario',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                  ),
                  const SizedBox(height: 16),

                  // 1. Perkiraan Hasil Panen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Perkiraan Hasil Panen', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        '${TaniFormatter.angka(_simulasiPanenKg)} kg (${TaniFormatter.angka(_simulasiPanenKg / 1000.0)} ton)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.hijau),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulasiPanenKg,
                    min: 1000,
                    max: 20000,
                    divisions: 38,
                    activeColor: AppColors.hijau,
                    onChanged: (val) => setState(() => _simulasiPanenKg = val),
                  ),

                  const SizedBox(height: 12),

                  // 2. Harga Jual Jagung Pipil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Harga Jual per kg', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        TaniFormatter.rupiah(_simulasiHargaJual),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.hijau),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulasiHargaJual,
                    min: 2500,
                    max: 8000,
                    divisions: 55,
                    activeColor: AppColors.kuningJagung,
                    onChanged: (val) => setState(() => _simulasiHargaJual = val),
                  ),

                  const SizedBox(height: 12),

                  // 3. Perkiraan Total Biaya
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Perkiraan Total Biaya', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        TaniFormatter.rupiah(_simulasiTotalBiaya),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rugi),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulasiTotalBiaya,
                    min: 2000000,
                    max: 30000000,
                    divisions: 56,
                    activeColor: AppColors.peringatan,
                    onChanged: (val) => setState(() => _simulasiTotalBiaya = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
