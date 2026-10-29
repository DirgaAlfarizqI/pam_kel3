import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color hijauTua = Color(0xFF0F3828);
  static const Color hijau = Color(0xFF176344);
  static const Color kuning = Color(0xFFF0C66A);

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _sembunyikanPassword = true;
  bool _setuju = false;
  bool _isLoading = false; // Tambahan: untuk indikator loading

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _daftar() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) return;

    // 2. Cek centang syarat & ketentuan
    if (!_setuju) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan setujui syarat dan ketentuan.'),
        ),
      );
      return;
    }

    // 3. Mulai proses loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 4. Proses pendaftaran ke Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // (Opsional) Simpan nama lengkap ke profil Firebase
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(_namaController.text.trim());
      }

      // 5. Jika berhasil
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman login
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // 6. Jika gagal (misal email sudah terdaftar, password lemah, dll)
      String pesanError = 'Terjadi kesalahan. Silakan coba lagi.';

      if (e.code == 'weak-password') {
        pesanError = 'Kata sandi terlalu lemah (minimal 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        pesanError = 'Email ini sudah terdaftar. Silakan gunakan email lain.';
      } else if (e.code == 'invalid-email') {
        pesanError = 'Format email tidak valid.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesanError),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Menangkap error umum lainnya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 7. Matikan loading apapun hasilnya
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _dekorasi(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: const Color(0xFFF5F7F5),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.agriculture_rounded,
                    size: 55,
                    color: hijau,
                  ),
                ),

                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    'Bergabung dengan TaniJagung',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: hijauTua,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Buat akun untuk mulai mengelola usaha tani.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF65736A),
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text('Nama lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _dekorasi(
                    'Masukkan nama lengkap',
                    Icons.person_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dekorasi(
                    'nama@email.com',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text('Kata sandi'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _sembunyikanPassword,
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _sembunyikanPassword =
                          !_sembunyikanPassword;
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
                    if (value == null || value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text('Konfirmasi kata sandi'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _konfirmasiController,
                  obscureText: _sembunyikanPassword,
                  decoration: _dekorasi(
                    'Ulangi kata sandi',
                    Icons.lock_reset_rounded,
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: hijau,
                  value: _setuju,
                  onChanged: (value) {
                    setState(() {
                      _setuju = value ?? false;
                    });
                  },
                  title: const Text(
                    'Saya menyetujui syarat dan ketentuan.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    // Jika sedang loading, tombol tidak bisa ditekan
                    onPressed: _isLoading ? null : _daftar,
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Buat Akun'),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Sudah punya akun? Masuk',
                      style: TextStyle(
                        color: hijau,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Icon(
                    Icons.spa_rounded,
                    color: kuning,
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