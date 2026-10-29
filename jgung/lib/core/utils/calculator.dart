/// Kelas utilitas murni untuk seluruh perhitungan bisnis TaniJagung
/// Sesuai aturan:
/// - Penambahan 4 bulan kalender untuk estimasi panen dengan penanganan hari valid.
/// - Konversi hasil panen ton ke kg.
/// - Perhitungan pendapatan = hasilPanenKg * hargaJualPerKg.
/// - Perhitungan laba bersih = pendapatan - totalPengeluaran.
/// - Status laba: UNTUNG, RUGI, IMPAS, atau BELUM LENGKAP.
/// - Perhitungan produktivitas = hasilPanenTon / luasLahanHa.
class TaniCalculator {
  /// Menghitung perkiraan tanggal panen dengan menambahkan 4 bulan kalender.
  /// Menangani tanggal yang tidak ada pada bulan tujuan (misal 31 Jan -> akhir Mei).
  static DateTime calculateEstimatedHarvestDate(DateTime plantingDate) {
    int targetYear = plantingDate.year;
    int targetMonth = plantingDate.month + 4;

    if (targetMonth > 12) {
      targetYear += (targetMonth - 1) ~/ 12;
      targetMonth = ((targetMonth - 1) % 12) + 1;
    }

    // Cari hari maksimal di bulan target
    final int daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final int targetDay = plantingDate.day > daysInTargetMonth ? daysInTargetMonth : plantingDate.day;

    return DateTime(
      targetYear,
      targetMonth,
      targetDay,
      plantingDate.hour,
      plantingDate.minute,
      plantingDate.second,
    );
  }

  /// Menghitung biaya pupuk berdasarkan jumlah kilogram dan harga per kilogram.
  static double calculateFertilizerCost(double quantityKg, double pricePerKg) {
    if (quantityKg < 0 || pricePerKg < 0) return 0.0;
    return quantityKg * pricePerKg;
  }

  /// Menghitung konversi hasil panen ke kilogram.
  static double convertHarvestToKg(double quantity, String unit) {
    if (quantity < 0) return 0.0;
    final String cleanUnit = unit.trim().toLowerCase();
    if (cleanUnit == 'ton') {
      return quantity * 1000.0;
    }
    return quantity;
  }

  /// Menghitung total pendapatan dari panen.
  static double calculateHarvestRevenue(double quantityKg, double salePricePerKg) {
    if (quantityKg < 0 || salePricePerKg < 0) return 0.0;
    return quantityKg * salePricePerKg;
  }

  /// Menghitung total pengeluaran dari daftar biaya.
  static double calculateTotalExpenses(Iterable<double> amounts) {
    double total = 0.0;
    for (final amt in amounts) {
      if (amt > 0) total += amt;
    }
    return total;
  }

  /// Menghitung laba/rugi bersih (pendapatan - total pengeluaran).
  static double calculateProfitLoss(double revenue, double totalExpenses) {
    return revenue - totalExpenses;
  }

  /// Menentukan status finansial:
  /// - 'BELUM LENGKAP' jika belum ada panen atau harga jual belum dicatat
  /// - 'UNTUNG' jika laba bersih > 0
  /// - 'RUGI' jika laba bersih < 0
  /// - 'IMPAS' jika laba bersih == 0
  static String determineProfitLossStatus({
    required bool hasHarvestData,
    required double? revenue,
    required double totalExpenses,
  }) {
    if (!hasHarvestData || revenue == null) {
      return 'BELUM LENGKAP';
    }
    final double net = revenue - totalExpenses;
    if (net > 0) {
      return 'UNTUNG';
    } else if (net < 0) {
      return 'RUGI';
    } else {
      return 'IMPAS';
    }
  }

  /// Menghitung produktivitas dalam Ton per Hektare.
  /// produktivitasTonPerHa = (hasilPanenKg / 1000) / luasLahanHa
  static double calculateProductivity({
    required double harvestKg,
    required double areaHa,
  }) {
    if (areaHa <= 0 || harvestKg <= 0) return 0.0;
    final double harvestTon = harvestKg / 1000.0;
    return harvestTon / areaHa;
  }
}
