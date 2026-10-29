import 'package:flutter/material.dart';
import 'models/perencanaan_tani_model.dart';
import 'forms/form_lahan.dart';
import 'forms/form_bibit_pupuk.dart';
import 'forms/form_biaya.dart';
import 'forms/form_hasil.dart';
import 'screens/ringkasan_analisis_screen.dart';

class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  State<StepperScreen> createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  // Model data terpusat sesuai alur mockup
  final PerencanaanTaniModel _model = PerencanaanTaniModel();

  // Langkah aktif: 0 (Lahan), 1 (Bibit & Pupuk), 2 (Biaya), 3 (Hasil)
  int _currentStep = 0;

  final List<String> _stepTitles = ['Lahan', 'Bibit & Pupuk', 'Biaya', 'Hasil'];

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Langkah 4 selesai -> Buka Halaman Ringkasan & Analisis (Screen 6 di mockup)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RingkasanAnalisisScreen(model: _model),
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _previousStep,
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
            // 1. Indikator Langkah (Stepper Header sesuai Mockup)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              child: _buildStepperIndicator(),
            ),

            // Garis tipis pembatas
            const Divider(height: 1, color: Colors.black12),

            // 2. Konten Form Aktif (Lahan, Bibit & Pupuk, Biaya, Hasil)
            Expanded(
              child: _buildCurrentStepContent(),
            ),

            // 3. Tombol Navigasi Bawah (Lanjut -> / Lihat Ringkasan ->)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17633D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: _nextStep,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == 3 ? 'Lihat Ringkasan' : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

  // Indikator 4 Langkah sesuai mockup
  Widget _buildStepperIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_stepTitles.length, (index) {
        final bool isActive = index == _currentStep;
        final bool isCompleted = index < _currentStep;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  // Garis Kiri
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : (isCompleted || isActive
                              ? const Color(0xFF17633D)
                              : const Color(0xFFE0E5E2)),
                    ),
                  ),
                  // Lingkaran Angka/Centang
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? const Color(0xFF17633D)
                          : const Color(0xFFF0F4F2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  // Garis Kanan
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == _stepTitles.length - 1
                          ? Colors.transparent
                          : (isCompleted
                              ? const Color(0xFF17633D)
                              : const Color(0xFFE0E5E2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Judul Langkah
              Text(
                _stepTitles[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                  color: isActive || isCompleted
                      ? const Color(0xFF183B2B)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Mengembalikan form yang sesuai dengan step aktif
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return FormLahan(
          model: _model,
          onDataChanged: () => setState(() {}),
        );
      case 1:
        return FormBibitPupuk(
          model: _model,
          onUbahLuasLahan: () => setState(() => _currentStep = 0),
        );
      case 2:
        return FormBiaya(
          model: _model,
          onDataChanged: () => setState(() {}),
        );
      case 3:
        return FormHasil(
          model: _model,
          onDataChanged: () => setState(() {}),
        );
      default:
        return const Center(child: Text("Halaman tidak ditemukan"));
    }
  }
}