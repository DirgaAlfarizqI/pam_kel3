import 'package:intl/intl.dart';

class TaniFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _shortDateFormat = DateFormat('d MMM yyyy', 'id_ID');

  /// Format angka ke Rupiah Indonesia, contoh: "Rp 150.000" atau "-Rp 50.000"
  static String rupiah(num? value) {
    if (value == null) return 'Rp 0';
    final bool isNegative = value < 0;
    final String formatted = _currencyFormat.format(value.abs());
    return isNegative ? '-$formatted' : formatted;
  }

  /// Format angka desimal Indonesia, contoh: "5,5" atau "10"
  static String angka(num? value, {int maxDecimals = 2}) {
    if (value == null) return '0';
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    String s = value.toStringAsFixed(maxDecimals);
    // Hapus nol berlebih di ujung
    while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
      s = s.substring(0, s.length - 1);
    }
    return s.replaceAll('.', ',');
  }

  /// Format tanggal Indonesia, misal: "12 Januari 2026"
  static String tanggal(DateTime? date) {
    if (date == null) return '-';
    try {
      return _dateFormat.format(date);
    } catch (_) {
      return '${date.day}-${date.month}-${date.year}';
    }
  }

  /// Format tanggal singkat Indonesia, misal: "12 Jan 2026"
  static String tanggalSingkat(DateTime? date) {
    if (date == null) return '-';
    try {
      return _shortDateFormat.format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
