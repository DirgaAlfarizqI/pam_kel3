import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataLahanForm extends StatefulWidget {
  const DataLahanForm({super.key});

  @override
  State<DataLahanForm> createState() => _DataLahanFormState();
}

class _DataLahanFormState extends State<DataLahanForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _luasController =
  TextEditingController(text: '1');
  final TextEditingController _namaLahanController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  String _satuan = 'Hektare (ha)';
  String _benih = 'Pioneer';

  final List<String> _daftarBenih = [
    'Pioneer',
    'BISI',
    'NK',
    'Benih lokal',
  ];

  double get _luasInput {
    return double.tryParse(
      _luasController.text.replaceAll(',', '.'),
    ) ??
        0;
  }

  double get _luasDalamHa {
    switch (_satuan) {
      case 'Meter persegi (m²)':
        return _luasInput / 10000;
      default:
        return _luasInput;
    }
  }

  @override
  void dispose() {
    _luasController.dispose();
    _namaLahanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pilihBenih() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Jenis Benih',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B2B),
                  ),
                ),
                const SizedBox(height: 12),
                ..._daftarBenih.map(
                      (benih) => ListTile(
                    leading: const Icon(
                      Icons.grass,
                      color: Color(0xFF17633D),
                    ),
                    title: Text(benih),
                    trailing: benih == _benih
                        ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF17633D),
                    )
                        : null,
                    onTap: () {
                      Navigator.pop(context, benih);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (pilihan != null && mounted) {
      setState(() {
        _benih = pilihan;
      });
    }
  }

  void _simpanData() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nama = _namaLahanController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final luasHa = _luasDalamHa;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.check_circle,
            color: Color(0xFF17633D),
            size: 48,
          ),
          title: const Text('Data Lahan Siap'),
          content: Text(
            'Nama lahan: $nama\n'
                'Lokasi: ${lokasi.isEmpty ? "-" : lokasi}\n'
                'Luas: ${luasHa.toStringAsFixed(4)} ha\n'
                'Jenis benih: $_benih\n\n'
                'Data berhasil divalidasi, tetapi belum '
                'disimpan secara permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Kembali'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF17633D),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  Widget _label(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF183B2B),
        ),
      ),
    );
  }

  InputDecoration _dekorasi(
      String hint, {
        IconData? ikon,
      }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: ikon == null ? null : Icon(ikon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF7F9F6),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5DD),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5DD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF17633D),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Lahan',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: Color(0xFF183B2B),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Lengkapi informasi lahan untuk memulai '
                  'perencanaan tanam.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF718078),
              ),
            ),
            const SizedBox(height: 24),

            // Nama lahan
            _label('Nama Lahan'),
            TextFormField(
              controller: _namaLahanController,
              textCapitalization: TextCapitalization.words,
              decoration: _dekorasi(
                'Contoh: Lahan Jagung Utara',
                ikon: Icons.landscape_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama lahan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Lokasi lahan
            _label('Lokasi Lahan'),
            TextFormField(
              controller: _lokasiController,
              textCapitalization: TextCapitalization.words,
              decoration: _dekorasi(
                'Desa, kecamatan, atau kabupaten',
                ikon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 20),

            // Luas lahan
            _label('Luas Lahan'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _luasController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                      ),
                    ],
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: _dekorasi('Masukkan luas'),
                    validator: (value) {
                      final angka = double.tryParse(
                        (value ?? '').replaceAll(',', '.'),
                      );

                      if (angka == null || angka <= 0) {
                        return 'Masukkan luas yang valid';
                      }

                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 155,
                  child: DropdownButtonFormField<String>(
                    initialValue: _satuan,
                    isExpanded: true,
                    decoration: _dekorasi('Satuan'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Hektare (ha)',
                        child: Text(
                          'Hektare (ha)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Meter persegi (m²)',
                        child: Text(
                          'Meter persegi (m²)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _satuan = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Informasi konversi luas
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4EC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF17633D),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Setara ${_luasDalamHa.toStringAsFixed(4)} ha '
                          '(${(_luasDalamHa * 10000).toStringAsFixed(1)} m²)',
                      style: const TextStyle(
                        color: Color(0xFF17633D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan benih
            _label('Jenis Benih Jagung'),
            InkWell(
              onTap: _pilihBenih,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDCE5DD),
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.grass,
                        color: Color(0xFF17633D),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _benih,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF183B2B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ketuk untuk mengganti pilihan benih',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718078),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF718078),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol periksa data
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _simpanData,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Periksa Data Lahan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF17633D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Pastikan luas lahan sudah benar sebelum '
                    'melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF718078),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
