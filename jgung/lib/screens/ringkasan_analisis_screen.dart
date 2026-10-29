import 'package:flutter/material.dart';
import '../models/perencanaan_tani_model.dart';
import 'proyeksi_panen_screen.dart';

class RingkasanAnalisisScreen extends StatefulWidget {
  final PerencanaanTaniModel model;

  const RingkasanAnalisisScreen({super.key, required this.model});

  @override
  State<RingkasanAnalisisScreen> createState() => _RingkasanAnalisisScreenState();
}

class _RingkasanAnalisisScreenState extends State<RingkasanAnalisisScreen> {
  // 0: 1x Panen, 1: 3x Panen / Tahun
  int _selectedToggle = 0;

  Widget _buildRowRincian(IconData ikon, String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(ikon, size: 18, color: const Color(0xFF17633D)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF183B2B),
              ),
            ),
          ),
          Text(
            nilai,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B2B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool is1x = _selectedToggle == 0;

    final double pendapatan = is1x
        ? widget.model.totalPendapatan1Panen
        : widget.model.totalPendapatan3Panen;
    final double biaya = is1x
        ? widget.model.totalBiaya1Panen
        : widget.model.totalBiaya3Panen;
    final double laba = is1x
        ? widget.model.labaBersih1Panen
        : widget.model.totalLabaBersih3Panen;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              'TaniJagung',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Layar
                    const Text(
                      'Ringkasan & Analisis',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183B2B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Segmented (1x Panen | 3x Panen / Tahun)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedToggle = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: is1x ? const Color(0xFF17633D) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '1x Panen',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: is1x ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedToggle = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !is1x ? const Color(0xFF17633D) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '3x Panen / Tahun',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !is1x ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kartu Hijau Tua Laba Bersih
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3828),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F3828).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                is1x ? 'Laba Bersih (1 Panen)' : 'Laba Bersih (3 Panen)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF5ED),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.eco, size: 12, color: Color(0xFF17633D)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Untung',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF17633D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            FormatHelper.rupiah(laba),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Pendapatan',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                              Text(
                                FormatHelper.rupiah(pendapatan),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Biaya',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                              Text(
                                FormatHelper.rupiah(biaya),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Laba Bersih',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                              Text(
                                FormatHelper.rupiah(laba),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bagian Rincian
                    const Text(
                      'Rincian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183B2B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildRowRincian(
                      Icons.agriculture_rounded,
                      'Hasil Panen',
                      '${FormatHelper.angka(widget.model.estimasiHasilKg, desimal: 0)} kg',
                    ),
                    _buildRowRincian(
                      Icons.sell_outlined,
                      'Harga Jual/Kg',
                      FormatHelper.rupiah(widget.model.hargaJualPerKg),
                    ),
                    _buildRowRincian(
                      Icons.account_balance_wallet_outlined,
                      'Modal Awal',
                      FormatHelper.rupiah(widget.model.totalModalAwal),
                    ),
                    _buildRowRincian(
                      Icons.engineering_outlined,
                      'Biaya Operasional',
                      FormatHelper.rupiah(widget.model.totalBiayaOperasional),
                    ),
                    _buildRowRincian(
                      Icons.receipt_long_outlined,
                      'Total Biaya',
                      FormatHelper.rupiah(widget.model.totalBiaya1Panen),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Bawah: Lanjut ke Proyeksi 3 Panen ->
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17633D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProyeksiPanenScreen(model: widget.model),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjut ke Proyeksi 3 Panen',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
