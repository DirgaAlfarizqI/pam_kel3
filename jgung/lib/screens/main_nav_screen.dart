import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../repositories/tani_jagung_repository.dart';
import 'catatan/jurnal_aktivitas_screen.dart';
import 'dashboard/beranda_screen.dart';
import 'keuangan/keuangan_screen.dart';
import 'lahan/lahan_list_screen.dart';
import 'profil/profil_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;
  late final TaniJagungRepository _repo;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _repo = TaniJagungRepository();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      BerandaScreen(repo: _repo, onNavigateTab: _onTabTapped),
      LahanListScreen(repo: _repo),
      JurnalAktivitasScreen(repo: _repo),
      KeuanganScreen(repo: _repo),
      ProfilScreen(repo: _repo),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.hijauTua,
          unselectedItemColor: AppColors.teksPudar,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.landscape_outlined),
              activeIcon: Icon(Icons.landscape),
              label: 'Lahan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Catatan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Keuangan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
