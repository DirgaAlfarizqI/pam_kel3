import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/perencanaan_tani_model.dart';

class FormLahan extends StatefulWidget {
  final PerencanaanTaniModel model;
  final VoidCallback onDataChanged;

  const FormLahan({
    super.key,
    required this.model,
    required this.onDataChanged,
  });

  @override
  State<FormLahan> createState() => _FormLahanState();
}

class _FormLahanState extends State<FormLahan> {
  late final TextEditingController _luasController;

  final List<Map<String, String>> _daftarBenih = [
    {
      'nama': 'Pioneer',
      'deskripsi': 'Benih jagung unggul',
    },
    {
      'nama': 'BISI',
      'deskripsi': 'Tahan penyakit & tongkol padat',
    },
    {
      'nama': 'NK (Syngenta)',
      'deskripsi': 'Potensi hasil tinggi & biji merah',
    },
    {
      'nama': 'Benih Lokal',
      'deskripsi': 'Benih varietas lokal bersertifikat',
    },
  ];

  @override
  void initState() {
    super.initState();
    _luasController = TextEditingController(
      text: widget.model.luasInput.toString().replaceAll(RegExp(r'\.0$'), ''),
    );
  }

  @override
  void dispose() {
    _luasController.dispose();
    super.dispose();
  }

  void _pilihBenih() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Jenis Benih',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183B2B),
                  ),
                ),
                const SizedBox(height: 12),
                ..._daftarBenih.map((item) {
                  final isDipilih = widget.model.jenisBenih == item['nama'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.eco, color: Color(0xFF17633D)),
                    ),
                    title: Text(
                      item['nama']!,
                      style: TextStyle(
                        fontWeight: isDipilih ? FontWeight.bold : FontWeight.w600,
                        color: const Color(0xFF183B2B),
                      ),
                    ),
                    subtitle: Text(
                      item['deskripsi']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: isDipilih
                        ? const Icon(Icons.check_circle, color: Color(0xFF17633D))
                        : null,
                    onTap: () {
                      setState(() {
                        widget.model.jenisBenih = item['nama']!;
                        widget.model.deskripsiBenih = item['deskripsi']!;
                      });
                      widget.onDataChanged();
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Layar
          const Text(
            'Data Lahan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Masukkan luas lahan yang akan ditanami jagung.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Label Luas Lahan
          const Text(
            'Luas Lahan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 8),

          // Row Input Luas + Satuan
          Row(
            children: [
              // Kotak input angka luas
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _luasController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF183B2B),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDCE5DD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDCE5DD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF17633D), width: 1.5),
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.replaceAll(',', '.'));
                      if (parsed != null && parsed > 0) {
                        widget.model.luasInput = parsed;
                        widget.model.sesuaikanDenganLuas(widget.model.luasDalamHa);
                        setState(() {});
                        widget.onDataChanged();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Dropdown Satuan
              Expanded(
                flex: 5,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDCE5DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.model.satuanLuas,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      items: const [
                        DropdownMenuItem(
                          value: 'Hektare (ha)',
                          child: Text(
                            'Hektare (ha)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF183B2B),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Meter persegi (m²)',
                          child: Text(
                            'Meter persegi (m²)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF183B2B),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            widget.model.satuanLuas = val;
                            widget.model.sesuaikanDenganLuas(widget.model.luasDalamHa);
                          });
                          widget.onDataChanged();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Info konversi (ⓘ 1 ha = 10.000 m²)
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                '1 ha = 10.000 m²',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Label Jenis Benih
          const Text(
            'Jenis Benih',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B2B),
            ),
          ),
          const SizedBox(height: 8),

          // Kartu Pilihan Benih
          InkWell(
            onTap: _pilihBenih,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE5DD)),
              ),
              child: Row(
                children: [
                  // Logo/Ikon Pioneer
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDCE5DD)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.grass_rounded,
                        color: Color(0xFF17633D),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Nama & Deskripsi Benih
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.model.jenisBenih,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF183B2B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.model.deskripsiBenih,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black45,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
