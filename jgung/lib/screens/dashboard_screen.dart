import 'package:flutter/material.dart';
import '../models/perencanaan_tani_model.dart';
import '../stepper_screen.dart';

class DashboardScreen extends StatefulWidget {
  final PerencanaanTaniModel? model;

  const DashboardScreen({super.key, this.model});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  Widget _buildMenuItem({
    required IconData ikon,
    required String judul,
    required String subjudul,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EDE8)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F6F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(ikon, color: const Color(0xFF17633D), size: 22),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF183B2B),
          ),
        ),
        subtitle: Text(
          subjudul,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45, size: 20),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model ?? PerencanaanTaniModel();
    final String luasText = '${FormatHelper.angka(model.luasDalamHa, desimal: 1)} ha';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Hijau Tua
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 56),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F3828),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Logo + Settings
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.eco, color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 6),
                              const Text(
                                'TaniJagung',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Salam & Tagline
                      const Text(
                        'Halo, Petani Hebat!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: const Text(
                          'Semangat terus mengelola lahan menuju hasil yang lebih baik.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Card Luas Lahan
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -32,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2EBE5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF5ED),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.grass_rounded, color: Color(0xFF17633D), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Luas Lahan',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                luasText,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF183B2B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${model.siklusPanenPerTahun} kali panen / tahun',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 52),

            // Daftar Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    ikon: Icons.receipt_long_outlined,
                    judul: 'Hitung Ulang & Buat Rencana Baru',
                    subjudul: 'Mulai perencanaan tanam jagung baru',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StepperScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    ikon: Icons.history_rounded,
                    judul: 'Riwayat Perhitungan',
                    subjudul: 'Lihat data perhitungan sebelumnya',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    ikon: Icons.menu_book_rounded,
                    judul: 'Tips & Panduan',
                    subjudul: 'Cara meningkatkan hasil panen',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    ikon: Icons.tune_rounded,
                    judul: 'Pengaturan',
                    subjudul: 'Satuan, harga, dan data asumsi',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    ikon: Icons.info_outline_rounded,
                    judul: 'Tentang Aplikasi',
                    subjudul: 'Versi 1.0.0',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        selectedItemColor: const Color(0xFF17633D),
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline_rounded),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
