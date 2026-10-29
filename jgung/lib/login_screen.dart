import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register_screen.dart';
import 'screens/main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color hijauTua = Color(0xFF0F3828);
  static const Color hijau = Color(0xFF176344);
  static const Color kuning = Color(0xFFEBB455);
  static const Color latar = Color(0xFFF5F7F5);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _sembunyikanPassword = true;
  bool _sedangLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _pesan(String pesan) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===== FUNGSI LOGIN EMAIL & PASSWORD =====
  Future<void> _masuk() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _sedangLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        _pesan('Berhasil masuk!');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavScreen()),
          );
        }

      } on FirebaseAuthException catch (e) {
        String pesanError = 'Terjadi kesalahan saat masuk';
        if (e.code == 'user-not-found') {
          pesanError = 'Pengguna tidak ditemukan';
        } else if (e.code == 'wrong-password') {
          pesanError = 'Kata sandi salah';
        } else if (e.code == 'invalid-credential') {
          pesanError = 'Email atau kata sandi tidak valid';
        }
        _pesan(pesanError);
      } catch (e) {
        _pesan('Gagal masuk: $e');
      } finally {
        if (mounted) setState(() => _sedangLoading = false);
      }
    }
  }

  // ===== FUNGSI LOGIN GOOGLE =====
  Future<void> _masukDenganGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _sedangLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      if (!googleSignIn.supportsAuthenticate()) {
        _pesan('Login Google tidak didukung pada perangkat ini');
        return;
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        _pesan('Gagal mendapatkan idToken dari Google');
        return;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      _pesan('Selamat datang, ${userCredential.user?.displayName ?? "Pengguna"}!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavScreen()),
        );
      }

    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _pesan('Login Google dibatalkan');
      } else {
        _pesan('Gagal login Google: ${e.description ?? e.code.name}');
      }
    } catch (e) {
      _pesan('Gagal login Google: $e');
    } finally {
      if (mounted) setState(() => _sedangLoading = false);
    }
  }

  // ===== FUNGSI LUPA KATA SANDI =====
  Future<void> _lupaPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _pesan('Isi email Anda terlebih dahulu untuk mereset kata sandi');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _pesan('Email reset kata sandi telah dikirim ke $email');
    } catch (e) {
      _pesan('Gagal mengirim email reset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final paddingBawah = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: hijauTua,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tinggiBody = constraints.maxHeight;
            final tinggiHeader =
            (tinggiBody * 0.34).clamp(230.0, 320.0).toDouble();
            const tumpukan = 28.0;
            final tinggiTeksHeader = tinggiHeader - tumpukan;
            final tinggiMinimalPanel =
            (tinggiBody - tinggiTeksHeader).clamp(0.0, double.infinity);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: tinggiHeader,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/cornfield.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: hijauTua);
                            },
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(15, 56, 40, 0.55),
                                  Color.fromRGBO(15, 56, 40, 0.92),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: tinggiTeksHeader,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding:
                              const EdgeInsets.fromLTRB(20, 8, 24, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Material(
                                    color: const Color.fromRGBO(0, 0, 0, 0.30),
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () => Navigator.maybePop(context),
                                      child: const SizedBox(
                                        width: 42,
                                        height: 42,
                                        child: Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.eco_rounded,
                                        color: kuning,
                                        size: 30,
                                      ),
                                      SizedBox(width: 8),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Tani',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Jagung',
                                              style: TextStyle(
                                                color: kuning,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Selamat Datang!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Masuk untuk melanjutkan ke TaniJagung',
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.85),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          builder: (context, nilai, child) {
                            return Opacity(
                              opacity: nilai,
                              child: Transform.translate(
                                offset: Offset(0, 28 * (1 - nilai)),
                                child: child,
                              ),
                            );
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: tinggiMinimalPanel,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: latar,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(tumpukan),
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                24,
                                28,
                                24,
                                24 + paddingBawah,
                              ),
                              child: _bangunForm(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bangunForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: hijauTua,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            enabled: !_sedangLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            decoration: const InputDecoration(
              hintText: 'nama@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailValid.hasMatch(email)) {
                return 'Masukkan alamat email yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Kata Sandi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: hijauTua,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            enabled: !_sedangLoading,
            focusNode: _passwordFocus,
            obscureText: _sembunyikanPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _masuk(),
            decoration: InputDecoration(
              hintText: 'Masukkan kata sandi',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _sembunyikanPassword = !_sembunyikanPassword;
                  });
                },
                icon: Icon(
                  _sembunyikanPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi wajib diisi';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _sedangLoading ? null : _lupaPassword,
              child: const Text(
                'Lupa kata sandi?',
                style: TextStyle(color: hijau),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _sedangLoading ? null : _masuk,
              child: _sedangLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text('Masuk'),
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau masuk dengan',
                  style: TextStyle(
                    color: Color(0xFF65736A),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _sedangLoading ? null : _masukDenganGoogle,
              icon: const Icon(
                Icons.g_mobiledata_rounded,
                size: 30,
              ),
              label: const Text('Lanjutkan dengan Google'),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum punya akun?',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF65736A),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _sedangLoading
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Daftar sekarang',
                  style: TextStyle(
                    color: hijau,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}