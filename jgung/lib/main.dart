import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'welcome_screen.dart';

// =======================================================================
// PENTING: GANTI BAGIAN INI DENGAN WEB CLIENT ID DARI google-services.json
// =======================================================================
const String kServerClientId =
    '290711265716-q3brpslnbrlpulme5eaq6obnppuh0ob7.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaniJagungApp());
}

class TaniJagungApp extends StatefulWidget {
  const TaniJagungApp({super.key});

  static const Color hijauTua = Color(0xFF0F3828);
  static const Color hijau = Color(0xFF176344);
  static const Color kuningJagung = Color(0xFFF0C66A);
  static const Color latar = Color(0xFFF5F7F5);

  @override
  State<TaniJagungApp> createState() => _TaniJagungAppState();
}

class _TaniJagungAppState extends State<TaniJagungApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await GoogleSignIn.instance.initialize(serverClientId: kServerClientId);
    } catch (e) {
      debugPrint('Initialization error: $e');
      throw Exception(e.toString());
    }
  }

  void _retryInitialization() {
    setState(() {
      _initFuture = _initializeServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaniJagung',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingScreen();
          }

          if (snapshot.hasError) {
            return _InitializationErrorScreen(
              message: snapshot.error.toString(),
              onRetry: _retryInitialization,
            );
          }

          // Tampilkan Welcome / Splash Screen pertama kali
          return const WelcomeScreen();
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TaniJagungApp.latar,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TaniJagungApp.hijauTua,
        primary: TaniJagungApp.hijauTua,
        secondary: TaniJagungApp.kuningJagung,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: TaniJagungApp.hijauTua,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TaniJagungApp.hijauTua,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TaniJagungApp.hijauTua,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: Color(0xFF8BA99A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE4DE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE4DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TaniJagungApp.hijau, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5EAE6)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7ECE8),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: TaniJagungApp.hijauTua,
        ),
        headlineMedium: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
          color: TaniJagungApp.hijauTua,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: TaniJagungApp.hijauTua,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: TaniJagungApp.hijauTua,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF26352C)),
        bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF65736A)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFDDECE2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TaniJagungApp.latar,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 64, color: TaniJagungApp.hijauTua),
            SizedBox(height: 20),
            Text(
              'TaniJagung',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: TaniJagungApp.hijauTua,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: TaniJagungApp.hijau),
            SizedBox(height: 12),
            Text('Menyiapkan aplikasi...'),
          ],
        ),
      ),
    );
  }
}

class _InitializationErrorScreen extends StatelessWidget {
  const _InitializationErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaniJagungApp.latar,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aplikasi gagal dimulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: TaniJagungApp.hijauTua,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Terjadi kesalahan saat menghubungkan layanan Firebase.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
