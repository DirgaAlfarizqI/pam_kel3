// Model Perencanaan Tani Jagung sesuai Mockup UI TaniJagung

class PerencanaanTaniModel {
  // ==========================================
  // 1. DATA LAHAN
  // ==========================================
  double luasInput;
  String satuanLuas; // 'Hektare (ha)' atau 'Meter persegi (m²)'
  String jenisBenih; // 'Pioneer', 'BISI', 'NK', 'Benih Lokal'
  String deskripsiBenih;

  // ==========================================
  // 2. KEBUTUHAN BIBIT & PUPUK (Saprodi)
  // ==========================================
  double kebutuhanBenihKg; // 20 kg / ha
  double kebutuhanPhonskaKg; // 300 kg / ha
  double kebutuhanUreaKg; // 200 kg / ha

  // ==========================================
  // 3. BIAYA & HARGA (Modal Awal & Operasional)
  // ==========================================
  double biayaBenih; // Rp 350.000
  double biayaPhonska; // Rp 900.000
  double biayaUrea; // Rp 600.000

  double biayaOlahLahan; // Rp 500.000
  double biayaTenagaKerja; // Rp 800.000
  double biayaLainLain; // Rp 350.000 (pestisida, dll)
  double biayaSewaDanLainnya; // Rp 12.750.000 (investasi lahan/sarana agar Total Biaya = 16.250.000 sesuai mockup)

  double hargaJualPerKg; // Rp 4.000

  // ==========================================
  // 4. ESTIMASI HASIL PANEN
  // ==========================================
  double estimasiHasilKg; // 7.000 kg (7 ton)
  int siklusPanenPerTahun; // 3 kali

  PerencanaanTaniModel({
    this.luasInput = 1.0,
    this.satuanLuas = 'Hektare (ha)',
    this.jenisBenih = 'Pioneer',
    this.deskripsiBenih = 'Benih jagung unggul',
    this.kebutuhanBenihKg = 20.0,
    this.kebutuhanPhonskaKg = 300.0,
    this.kebutuhanUreaKg = 200.0,
    this.biayaBenih = 350000.0,
    this.biayaPhonska = 900000.0,
    this.biayaUrea = 600000.0,
    this.biayaOlahLahan = 500000.0,
    this.biayaTenagaKerja = 800000.0,
    this.biayaLainLain = 350000.0,
    this.biayaSewaDanLainnya = 12750000.0,
    this.hargaJualPerKg = 4000.0,
    this.estimasiHasilKg = 7000.0,
    this.siklusPanenPerTahun = 3,
  });

  // Luas dalam Hektare
  double get luasDalamHa {
    if (satuanLuas == 'Meter persegi (m²)') {
      return luasInput / 10000.0;
    }
    return luasInput;
  }

  // Luas dalam m2
  double get luasDalamM2 => luasDalamHa * 10000.0;

  // Sesuaikan saprodi dan biaya saat luas berubah
  void sesuaikanDenganLuas(double luasHaBaru) {
    if (luasHaBaru <= 0) return;
    kebutuhanBenihKg = luasHaBaru * 20.0;
    kebutuhanPhonskaKg = luasHaBaru * 300.0;
    kebutuhanUreaKg = luasHaBaru * 200.0;

    biayaBenih = luasHaBaru * 350000.0;
    biayaPhonska = luasHaBaru * 900000.0;
    biayaUrea = luasHaBaru * 600000.0;

    biayaOlahLahan = luasHaBaru * 500000.0;
    biayaTenagaKerja = luasHaBaru * 800000.0;
    biayaLainLain = luasHaBaru * 350000.0;
    biayaSewaDanLainnya = luasHaBaru * 12750000.0;

    estimasiHasilKg = luasHaBaru * 7000.0;
  }

  // Total Modal Awal (Saprodi)
  double get totalModalAwal => biayaBenih + biayaPhonska + biayaUrea;

  // Total Biaya Operasional
  double get totalBiayaOperasional => biayaOlahLahan + biayaTenagaKerja + biayaLainLain;

  // Total Biaya 1 Panen (Modal Awal + Operasional + Sewa/Lainnya = Rp 16.250.000 untuk 1 ha)
  double get totalBiaya1Panen => totalModalAwal + totalBiayaOperasional + biayaSewaDanLainnya;

  // Total Pendapatan 1 Panen (7.000 kg x Rp 4.000 = Rp 28.000.000)
  double get totalPendapatan1Panen => estimasiHasilKg * hargaJualPerKg;

  // Laba Bersih 1 Panen (Rp 28.000.000 - Rp 16.250.000 = Rp 11.750.000)
  double get labaBersih1Panen => totalPendapatan1Panen - totalBiaya1Panen;

  // ==========================================
  // PROYEKSI 3 KALI PANEN
  // ==========================================
  double get totalPendapatan3Panen => totalPendapatan1Panen * siklusPanenPerTahun;
  double get totalBiaya3Panen => totalBiaya1Panen * siklusPanenPerTahun;
  double get totalLabaBersih3Panen => labaBersih1Panen * siklusPanenPerTahun;
}

// Format Angka & Mata Uang
class FormatHelper {
  static String rupiah(num value) {
    final bool isNegatif = value < 0;
    final int angkaBulat = value.abs().round();
    final String s = angkaBulat.toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }

    return '${isNegatif ? "- Rp " : "Rp "}${buffer.toString()}';
  }

  static String angka(num value, {int desimal = 1}) {
    if (value % 1 == 0) {
      final int bulat = value.toInt();
      final String s = bulat.toString();
      final StringBuffer buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return value.toStringAsFixed(desimal).replaceAll('.', ',');
  }
}
