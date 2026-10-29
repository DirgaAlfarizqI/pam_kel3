import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'screens/main_nav_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const Color _hijauGelap = Color(0xFF0F3828);
  static const Color _kuningJagung = Color(0xFFEBB455);

  late final AnimationController _masukController;
  late final AnimationController _tombolController;
  late final Animation<double> _animasiAtas;
  late final Animation<double> _animasiBawah;
  late final Animation<double> _tombolNaikTurun;

  @override
  void initState() {
    super.initState();

    _masukController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _animasiAtas = CurvedAnimation(
      parent: _masukController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );

    _animasiBawah = CurvedAnimation(
      parent: _masukController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );

    _masukController.forward();

    _tombolController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _tombolNaikTurun = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _tombolController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _masukController.dispose();
    _tombolController.dispose();
    super.dispose();
  }

  void _mulaiSekarang() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavScreen(),
      ),
    );
  }

  void _keLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Widget _muncul(Animation<double> animasi, Widget child) {
    return FadeTransition(
      opacity: animasi,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animasi),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _hijauGelap,
      body: Stack(
        children: [
          // 1. Foto ladang jagung sebagai background.
          Positioned.fill(
            child: Image.asset(
              'assets/images/cornfield.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: _hijauGelap);
              },
            ),
          ),

          // 2. Overlay hijau gelap.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(15, 56, 40, 0.80),
                    Color.fromRGBO(15, 56, 40, 0.15),
                    Color.fromRGBO(15, 56, 40, 0.40),
                    Color.fromRGBO(15, 56, 40, 0.96),
                  ],
                  stops: [0.0, 0.35, 0.62, 1.0],
                ),
              ),
            ),
          ),

          // 3. Konten.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tinggi = constraints.maxHeight;

                final jarakKeTombol =
                (tinggi * 0.05).clamp(34.0, 42.0).toDouble();
                final jarakKeFooter =
                (tinggi * 0.05).clamp(34.0, 42.0).toDouble();
                final ukuranJudul =
                (lebarLayar * 0.105).clamp(32.0, 46.0).toDouble();

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: tinggi),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),

                            // ===== BAGIAN ATAS: logo + tagline =====
                            _muncul(
                              _animasiAtas,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.eco_rounded,
                                        size: ukuranJudul * 1.15,
                                        color: _kuningJagung,
                                      ),
                                      const SizedBox(width: 10),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Tani',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ukuranJudul,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Jagung',
                                              style: TextStyle(
                                                color: _kuningJagung,
                                                fontSize: ukuranJudul,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 26),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: lebarLayar * 0.75,
                                    ),
                                    child: const Text(
                                      'Kelola lahan, hitung kebutuhan, raih hasil maksimal.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 24),

                            // ===== BAGIAN BAWAH: fitur, tombol, footer =====
                            _muncul(
                              _animasiBawah,
                              Column(
                                children: [
                                  const Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _FiturItem(
                                          ikon: Icons.eco_outlined,
                                          label: 'Perhitungan\nKebutuhan',
                                        ),
                                      ),
                                      _PemisahFitur(),
                                      Expanded(
                                        child: _FiturItem(
                                          ikon: Icons.bar_chart_rounded,
                                          label: 'Estimasi\nHasil Panen',
                                        ),
                                      ),
                                      _PemisahFitur(),
                                      Expanded(
                                        child: _FiturItem(
                                          ikon: Icons.monetization_on_outlined,
                                          label: 'Analisis\nUntung-Rugi',
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: jarakKeTombol),

                                  // Tombol Mulai Sekarang
                                  AnimatedBuilder(
                                    animation: _tombolNaikTurun,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset:
                                        Offset(0, _tombolNaikTurun.value),
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                235, 180, 85, 0.35),
                                            blurRadius: 16,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: _kuningJagung,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          // Memanggil fungsi _mulaiSekarang
                                          onTap: _mulaiSekarang,
                                          child: const SizedBox(
                                            height: 56,
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Mulai Sekarang',
                                                  style: TextStyle(
                                                    color: _hijauGelap,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: _hijauGelap,
                                                  size: 22,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),
                                  TextButton(
                                    onPressed: _keLogin,
                                    child: const Text(
                                      'Sudah punya akun? Masuk',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: jarakKeFooter),

                                  const Text(
                                    'Bersama TaniJagung, petani lebih maju',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        child: Divider(
                                          color: Color.fromRGBO(
                                              235, 180, 85, 0.7),
                                          thickness: 1,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.eco_rounded,
                                        size: 14,
                                        color: _kuningJagung,
                                      ),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        width: 28,
                                        child: Divider(
                                          color: Color.fromRGBO(
                                              235, 180, 85, 0.7),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Satu item fitur: ikon bulat + label.
class _FiturItem extends StatefulWidget {
  final IconData ikon;
  final String label;

  const _FiturItem({
    required this.ikon,
    required this.label,
  });

  @override
  State<_FiturItem> createState() => _FiturItemState();
}

class _FiturItemState extends State<_FiturItem> {
  bool _ditekan = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _ditekan = true),
      onTapUp: (_) => setState(() => _ditekan = false),
      onTapCancel: () => setState(() => _ditekan = false),
      child: AnimatedScale(
        scale: _ditekan ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ditekan
                    ? const Color.fromRGBO(255, 255, 255, 0.22)
                    : const Color.fromRGBO(255, 255, 255, 0.10),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.85),
                  width: 1.4,
                ),
              ),
              child: Icon(
                widget.ikon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Garis tipis pemisah antar fitur.
class _PemisahFitur extends StatelessWidget {
  const _PemisahFitur();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 56,
      color: const Color.fromRGBO(255, 255, 255, 0.28),
    );
  }
}