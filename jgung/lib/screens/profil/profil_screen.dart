import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../repositories/tani_jagung_repository.dart';
import '../../login_screen.dart';
import '../analisis/analisis_produktivitas_screen.dart';
import '../laporan/riwayat_laporan_screen.dart';
import '../prediksi/prediksi_panen_screen.dart';
import '../simulasi/simulasi_keuntungan_screen.dart';

class ProfilScreen extends StatelessWidget {
  final TaniJagungRepository repo;

  const ProfilScreen({super.key, required this.repo});

  void _showEditProfileDialog(BuildContext context) {
    final controller = TextEditingController(text: repo.currentUser.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Profil'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
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
              if (controller.text.trim().isNotEmpty) {
                repo.updateProfileName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppColors.hijauTua),
            SizedBox(width: 8),
            Text('TaniJagung'),
          ],
        ),
        content: const Text(
          'TaniJagung adalah aplikasi pembukuan dan analisis usaha tani jagung yang dirancang khusus untuk petani mandiri.\n\n'
          'Fitur Utama:\n'
          '• Pencatatan manual terstruktur (Benih, Pupuk, Biaya Olah, Tenaga Kerja).\n'
          '• Perhitungan otomatis pendapatan, laba/rugi, dan produktivitas (ton/ha).\n'
          '• Perhitungan tanggal kalender panen (+4 bulan).\n'
          '• Isolasi data per siklus penanaman dan lahan.\n'
          '• Riwayat & analisis lintas musim tanam.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun TaniJagung?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rugi, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.latar,
          appBar: AppBar(
            title: const Text('Profil Pengguna'),
            backgroundColor: AppColors.hijauTua,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                DemoBanner(isDemo: repo.isDemoMode),

                // Card Avatar & Nama
                TaniCard(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.kuningJagung,
                        child: Icon(Icons.person, color: AppColors.hijauTua, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              repo.currentUser.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.teksUtama),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              repo.currentUser.email,
                              style: const TextStyle(fontSize: 13, color: AppColors.teksSekunder),
                            ),
                            const SizedBox(height: 6),
                            const TaniBadge(label: 'Petani Terdaftar'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.hijau),
                        onPressed: () => _showEditProfileDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Fitur Tambahan & Analisis Lanjutan
                TaniCard(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.analytics_outlined,
                        title: 'Analisis Produktivitas',
                        subtitle: 'Perbandingan ton/ha antarlahan & musim',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AnalisisProduktivitasScreen(repo: repo)),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.history_edu,
                        title: 'Riwayat & Laporan Lengkap',
                        subtitle: 'Daftar seluruh siklus penanaman selesai',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RiwayatLaporanScreen(repo: repo)),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.insights,
                        title: 'Simulasi Keuntungan',
                        subtitle: 'Uji parameter hasil dan harga jual',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SimulasiKeuntunganScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.online_prediction,
                        title: 'Prediksi Hasil Panen',
                        subtitle: 'Estimasi berbasis rata-rata historis',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PrediksiPanenScreen(repo: repo)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Pengaturan Akun & Mode Demo
                TaniCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.kuningPudar,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.science_outlined, color: AppColors.kuningJagung),
                        ),
                        title: const Text('Mode Demo & Simulasi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Tampilkan data contoh untuk demonstrasi', style: TextStyle(fontSize: 12)),
                        value: repo.isDemoMode,
                        activeColor: AppColors.hijauTua,
                        onChanged: (val) => repo.setDemoMode(val),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Bantuan & Panduan',
                        subtitle: 'Cara mencatat dan mengelola siklus tani',
                        onTap: () => _showAboutDialog(context),
                      ),
                      const Divider(height: 1),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'Tentang TaniJagung',
                        subtitle: 'Versi 1.0.0 (Flutter Android)',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol Keluar Akun
                TaniButton(
                  text: 'Keluar dari Akun',
                  customColor: const Color(0xFFFFEBEE),
                  customTextColor: AppColors.rugi,
                  icon: Icons.logout,
                  onPressed: () => _logout(context),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.hijauPudar,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.hijauTua, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.teksSekunder)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.black38),
      onTap: onTap,
    );
  }
}
