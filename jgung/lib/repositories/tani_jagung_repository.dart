import 'package:flutter/foundation.dart';
import '../core/utils/calculator.dart';
import '../models/app_models.dart';

/// Repository terpusat untuk mengelola seluruh data TaniJagung secara reaktif.
/// Sesuai Aturan Utama:
/// - Isolasi data per pengguna (userId).
/// - Satu pengguna dapat memiliki beberapa lahan.
/// - Satu lahan dapat memiliki beberapa siklus penanaman.
/// - Semua pengeluaran, aktivitas, dan panen terikat pada plantingId unik.
/// - Data Demo diberi label eksplisit dan terpisah dari data produksi.
class TaniJagungRepository extends ChangeNotifier {
  static final TaniJagungRepository _instance = TaniJagungRepository._internal();
  factory TaniJagungRepository() => _instance;

  TaniJagungRepository._internal() {
    _initDemoData();
  }

  // Pengguna aktif saat ini
  UserModel _currentUser = const UserModel(
    userId: 'user_budi_01',
    name: 'Budi Santoso',
    email: 'budi.santoso@tanijagung.id',
    profilePhoto: null,
  );

  bool _isDemoMode = true; // Ditandai dengan label "Mode Demo"

  // Storage data in-memory
  final List<LandModel> _lands = [];
  final List<PlantingModel> _plantings = [];
  final List<ExpenseModel> _expenses = [];
  final List<HarvestModel> _harvests = [];
  final List<ActivityModel> _activities = [];
  final List<ReminderModel> _reminders = [];

  // ================= GETTERS =================
  UserModel get currentUser => _currentUser;
  bool get isDemoMode => _isDemoMode;

  void setDemoMode(bool value) {
    _isDemoMode = value;
    notifyListeners();
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateProfileName(String newName) {
    _currentUser = _currentUser.copyWith(name: newName);
    notifyListeners();
  }

  // ================= LAHAN (LANDS) =================
  List<LandModel> getLands() {
    return _lands.where((l) => l.userId == _currentUser.userId).toList();
  }

  LandModel? getLandById(String landId) {
    try {
      return _lands.firstWhere(
        (l) => l.landId == landId && l.userId == _currentUser.userId,
      );
    } catch (_) {
      return null;
    }
  }

  void addLand({
    required String name,
    required double areaHa,
    String? locationNote,
    String? notes,
  }) {
    if (areaHa <= 0) throw ArgumentError('Luas lahan harus lebih besar dari nol.');
    final newLand = LandModel(
      landId: 'land_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      name: name,
      areaHa: areaHa,
      locationNote: locationNote,
      notes: notes,
    );
    _lands.add(newLand);
    notifyListeners();
  }

  void updateLand(LandModel updatedLand) {
    if (updatedLand.areaHa <= 0) throw ArgumentError('Luas lahan harus lebih besar dari nol.');
    final idx = _lands.indexWhere((l) => l.landId == updatedLand.landId && l.userId == _currentUser.userId);
    if (idx != -1) {
      _lands[idx] = updatedLand;
      notifyListeners();
    }
  }

  void deleteLand(String landId) {
    _lands.removeWhere((l) => l.landId == landId && l.userId == _currentUser.userId);
    // Hapus juga siklus & data turunan lahan tersebut
    final plantingIdsToRemove = _plantings.where((p) => p.landId == landId).map((p) => p.plantingId).toSet();
    _plantings.removeWhere((p) => plantingIdsToRemove.contains(p.plantingId));
    _expenses.removeWhere((e) => plantingIdsToRemove.contains(e.plantingId));
    _harvests.removeWhere((h) => plantingIdsToRemove.contains(h.plantingId));
    _activities.removeWhere((a) => plantingIdsToRemove.contains(a.plantingId));
    _reminders.removeWhere((r) => r.plantingId != null && plantingIdsToRemove.contains(r.plantingId));
    notifyListeners();
  }

  // ================= SIKLUS PENANAMAN (PLANTINGS) =================
  List<PlantingModel> getPlantings({String? landId}) {
    return _plantings.where((p) {
      if (p.userId != _currentUser.userId) return false;
      if (landId != null && p.landId != landId) return false;
      return true;
    }).toList();
  }

  List<PlantingModel> getActivePlantings() {
    return _plantings.where((p) => p.userId == _currentUser.userId && p.isAktif).toList();
  }

  List<PlantingModel> getFinishedPlantings() {
    return _plantings.where((p) => p.userId == _currentUser.userId && p.isSelesai).toList();
  }

  PlantingModel? getPlantingById(String plantingId) {
    try {
      return _plantings.firstWhere(
        (p) => p.plantingId == plantingId && p.userId == _currentUser.userId,
      );
    } catch (_) {
      return null;
    }
  }

  PlantingModel startNewPlanting({
    required String landId,
    required String name,
    required String cornVariety,
    required DateTime plantingDate,
    String? notes,
  }) {
    // Estimasi panen dihitung otomatis: +4 bulan kalender
    final estimatedDate = TaniCalculator.calculateEstimatedHarvestDate(plantingDate);

    final newPlanting = PlantingModel(
      plantingId: 'planting_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      landId: landId,
      name: name,
      cornVariety: cornVariety,
      plantingDate: plantingDate,
      estimatedHarvestDate: estimatedDate,
      status: 'aktif',
      notes: notes,
    );

    _plantings.add(newPlanting);

    // Tambahkan pengingat awal untuk pemupukan dan perkiraan panen
    _reminders.add(ReminderModel(
      reminderId: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      plantingId: newPlanting.plantingId,
      title: 'Pemupukan Pertama ($name)',
      scheduledDate: plantingDate.add(const Duration(days: 14)),
      description: 'Jadwal aplikasi pemupukan awal setelah tanam.',
    ));

    notifyListeners();
    return newPlanting;
  }

  void updatePlanting(PlantingModel updatedPlanting) {
    final idx = _plantings.indexWhere((p) => p.plantingId == updatedPlanting.plantingId && p.userId == _currentUser.userId);
    if (idx != -1) {
      _plantings[idx] = updatedPlanting;
      notifyListeners();
    }
  }

  void finishPlanting({required String plantingId, required DateTime actualHarvestDate}) {
    final idx = _plantings.indexWhere((p) => p.plantingId == plantingId && p.userId == _currentUser.userId);
    if (idx != -1) {
      _plantings[idx] = _plantings[idx].copyWith(
        status: 'selesai',
        actualHarvestDate: actualHarvestDate,
      );
      notifyListeners();
    }
  }

  // ================= PENGELUARAN (EXPENSES) =================
  List<ExpenseModel> getExpenses({String? plantingId}) {
    return _expenses.where((e) {
      if (e.userId != _currentUser.userId) return false;
      if (plantingId != null && e.plantingId != plantingId) return false;
      return true;
    }).toList();
  }

  void addExpense({
    required String plantingId,
    required DateTime date,
    required String category,
    required String description,
    double? quantity,
    String? unit,
    double? unitPrice,
    required double amount,
    String? notes,
  }) {
    if (amount < 0) throw ArgumentError('Jumlah pengeluaran tidak boleh negatif.');
    if (quantity != null && quantity < 0) throw ArgumentError('Kuantitas tidak boleh negatif.');
    if (unitPrice != null && unitPrice < 0) throw ArgumentError('Harga satuan tidak boleh negatif.');

    final newExpense = ExpenseModel(
      expenseId: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      plantingId: plantingId,
      date: date,
      category: category,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      amount: amount,
      notes: notes,
    );

    _expenses.add(newExpense);
    notifyListeners();
  }

  void updateExpense(ExpenseModel updatedExpense) {
    if (updatedExpense.amount < 0) throw ArgumentError('Jumlah pengeluaran tidak boleh negatif.');
    final idx = _expenses.indexWhere((e) => e.expenseId == updatedExpense.expenseId && e.userId == _currentUser.userId);
    if (idx != -1) {
      _expenses[idx] = updatedExpense;
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.expenseId == expenseId && e.userId == _currentUser.userId);
    notifyListeners();
  }

  double getTotalExpensesForPlanting(String plantingId) {
    final items = _expenses.where((e) => e.plantingId == plantingId && e.userId == _currentUser.userId);
    return TaniCalculator.calculateTotalExpenses(items.map((e) => e.amount));
  }

  Map<String, double> getExpenseCategoryBreakdown(String? plantingId) {
    final items = plantingId != null
        ? _expenses.where((e) => e.plantingId == plantingId && e.userId == _currentUser.userId)
        : _expenses.where((e) => e.userId == _currentUser.userId);

    final Map<String, double> breakdown = {};
    for (final exp in items) {
      breakdown[exp.category] = (breakdown[exp.category] ?? 0.0) + exp.amount;
    }
    return breakdown;
  }

  // ================= HASIL PANEN (HARVEST RECORDS) =================
  List<HarvestModel> getHarvestRecords({String? plantingId}) {
    return _harvests.where((h) {
      if (h.userId != _currentUser.userId) return false;
      if (plantingId != null && h.plantingId != plantingId) return false;
      return true;
    }).toList();
  }

  void recordHarvest({
    required String plantingId,
    required DateTime harvestDate,
    required double quantity,
    required String unit, // 'ton' atau 'kg'
    required double salePricePerKg,
    String? notes,
  }) {
    if (quantity < 0) throw ArgumentError('Jumlah hasil panen tidak boleh negatif.');
    if (salePricePerKg < 0) throw ArgumentError('Harga jual tidak boleh negatif.');

    final double quantityKg = TaniCalculator.convertHarvestToKg(quantity, unit);
    final double revenue = TaniCalculator.calculateHarvestRevenue(quantityKg, salePricePerKg);

    final newHarvest = HarvestModel(
      harvestId: 'hrv_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      plantingId: plantingId,
      harvestDate: harvestDate,
      quantityKg: quantityKg,
      salePricePerKg: salePricePerKg,
      revenue: revenue,
      notes: notes,
    );

    _harvests.add(newHarvest);

    // Otomatis tandai siklus sebagai selesai dan update actualHarvestDate
    finishPlanting(plantingId: plantingId, actualHarvestDate: harvestDate);

    notifyListeners();
  }

  double getTotalHarvestKgForPlanting(String plantingId) {
    final items = _harvests.where((h) => h.plantingId == plantingId && h.userId == _currentUser.userId);
    double total = 0.0;
    for (final h in items) {
      total += h.quantityKg;
    }
    return total;
  }

  double getTotalRevenueForPlanting(String plantingId) {
    final items = _harvests.where((h) => h.plantingId == plantingId && h.userId == _currentUser.userId);
    double total = 0.0;
    for (final h in items) {
      total += h.revenue;
    }
    return total;
  }

  // ================= AKTIVITAS (ACTIVITIES) =================
  List<ActivityModel> getActivities({String? plantingId}) {
    final list = _activities.where((a) {
      if (a.userId != _currentUser.userId) return false;
      if (plantingId != null && a.plantingId != plantingId) return false;
      return true;
    }).toList();
    // Urutkan dari tanggal terbaru ke terlama
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addActivity({
    required String plantingId,
    required DateTime date,
    required String type,
    required String description,
    String? photoUrl,
    double? quantity,
    String? unit,
    double? cost,
    String? notes,
  }) {
    final newActivity = ActivityModel(
      activityId: 'act_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      plantingId: plantingId,
      date: date,
      type: type,
      description: description,
      photoUrl: photoUrl,
      quantity: quantity,
      unit: unit,
      cost: cost,
      notes: notes,
    );

    _activities.add(newActivity);

    // Jika aktivitas mencatat biaya yang sah, catat juga sebagai pengeluaran agar terpusat
    if (cost != null && cost > 0) {
      String cat = 'Lain-lain';
      if (type.toLowerCase().contains('pupuk')) {
        cat = 'Pupuk';
      } else if (type.toLowerCase().contains('tanam')) {
        cat = 'Benih';
      } else if (type.toLowerCase().contains('pestisida')) {
        cat = 'Pestisida';
      } else if (type.toLowerCase().contains('olah lahan')) {
        cat = 'Pengolahan Lahan';
      } else if (type.toLowerCase().contains('tenaga kerja')) {
        cat = 'Tenaga Kerja';
      }
      addExpense(
        plantingId: plantingId,
        date: date,
        category: cat,
        description: description,
        quantity: quantity,
        unit: unit,
        amount: cost,
        notes: notes,
      );
    }

    notifyListeners();
  }

  // ================= PENGINGAT (REMINDERS) =================
  List<ReminderModel> getReminders() {
    return _reminders.where((r) => r.userId == _currentUser.userId).toList();
  }

  void addReminder({
    String? plantingId,
    required String title,
    required DateTime scheduledDate,
    String? description,
  }) {
    final newReminder = ReminderModel(
      reminderId: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.userId,
      plantingId: plantingId,
      title: title,
      scheduledDate: scheduledDate,
      description: description,
      isCompleted: false,
    );
    _reminders.add(newReminder);
    notifyListeners();
  }

  void toggleReminder(String reminderId) {
    final idx = _reminders.indexWhere((r) => r.reminderId == reminderId && r.userId == _currentUser.userId);
    if (idx != -1) {
      _reminders[idx] = _reminders[idx].copyWith(isCompleted: !_reminders[idx].isCompleted);
      notifyListeners();
    }
  }

  void deleteReminder(String reminderId) {
    _reminders.removeWhere((r) => r.reminderId == reminderId && r.userId == _currentUser.userId);
    notifyListeners();
  }

  // ================= DATA SEED DEMO (JELAS DILABELI DEMO) =================
  void _initDemoData() {
    _lands.clear();
    _plantings.clear();
    _expenses.clear();
    _harvests.clear();
    _activities.clear();
    _reminders.clear();

    const uId = 'user_budi_01';

    // 1. Lahan 1: Sawah Utara (1.0 ha)
    const land1 = LandModel(
      landId: 'land_demo_01',
      userId: uId,
      name: 'Lahan 1 - Sawah Utara',
      areaHa: 1.0,
      locationNote: 'Desa Karangmojo, Blok A',
      notes: 'Lahan irigasi teknis dekat sungai.',
    );

    // 2. Lahan 2: Sawah Selatan (0.8 ha)
    const land2 = LandModel(
      landId: 'land_demo_02',
      userId: uId,
      name: 'Lahan 2 - Sawah Selatan',
      areaHa: 0.8,
      locationNote: 'Desa Karangmojo, Blok C',
      notes: 'Lahan tadah hujan tanah lempung berpasir.',
    );

    _lands.addAll([land1, land2]);

    // Siklus 1 (Lahan 1) - Aktif (Skenario Utama)
    final pDate1 = DateTime(2026, 1, 12);
    final pEst1 = TaniCalculator.calculateEstimatedHarvestDate(pDate1);
    final planting1 = PlantingModel(
      plantingId: 'planting_demo_01',
      userId: uId,
      landId: land1.landId,
      name: 'Musim Tanam Utama 2026',
      cornVariety: 'Bisi 18',
      plantingDate: pDate1,
      estimatedHarvestDate: pEst1,
      status: 'aktif',
      notes: 'Penanaman jagung pipil hibrida musim penghujan.',
    );

    // Siklus 2 (Lahan 2) - Aktif
    final pDate2 = DateTime(2026, 2, 20);
    final pEst2 = TaniCalculator.calculateEstimatedHarvestDate(pDate2);
    final planting2 = PlantingModel(
      plantingId: 'planting_demo_02',
      userId: uId,
      landId: land2.landId,
      name: 'Musim Tanam Lahan 2 - 2026',
      cornVariety: 'NK 212',
      plantingDate: pDate2,
      estimatedHarvestDate: pEst2,
      status: 'aktif',
      notes: 'Penanaman varietas tahan kekeringan.',
    );

    // Siklus Selesai Musim Tanam 2025 (Riwayat Laporan Historis)
    final pHistDate = DateTime(2025, 3, 10);
    final pHistActual = DateTime(2025, 7, 10);
    final plantingHist = PlantingModel(
      plantingId: 'planting_demo_hist_01',
      userId: uId,
      landId: land1.landId,
      name: 'Musim Tanam 2025 (Selesai)',
      cornVariety: 'Bisi 18',
      plantingDate: pHistDate,
      estimatedHarvestDate: TaniCalculator.calculateEstimatedHarvestDate(pHistDate),
      actualHarvestDate: pHistActual,
      status: 'selesai',
      notes: 'Siklus tahun lalu, hasil panen sangat baik.',
    );

    _plantings.addAll([planting1, planting2, plantingHist]);

    // Pengeluaran Siklus 1 (Sesuai Referensi Visual & Skenario)
    _expenses.addAll([
      ExpenseModel(
        expenseId: 'exp_demo_01',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 1, 12),
        category: 'Benih',
        description: 'Benih Bisi 18 (20 kg)',
        quantity: 20,
        unit: 'kg',
        unitPrice: 75000,
        amount: 1500000,
      ),
      ExpenseModel(
        expenseId: 'exp_demo_02',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 1, 15),
        category: 'Pupuk',
        description: 'Pupuk Urea (25 kg)',
        quantity: 25,
        unit: 'kg',
        unitPrice: 6000,
        amount: 150000,
      ),
      ExpenseModel(
        expenseId: 'exp_demo_03',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 1, 20),
        category: 'Pupuk',
        description: 'Pupuk NPK Phonska (300 kg)',
        quantity: 300,
        unit: 'kg',
        unitPrice: 12833.3,
        amount: 3850000,
      ),
      ExpenseModel(
        expenseId: 'exp_demo_04',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 1, 10),
        category: 'Pengolahan Lahan',
        description: 'Traktor dan pembajakan tanah',
        amount: 2000000,
      ),
      ExpenseModel(
        expenseId: 'exp_demo_05',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 2, 5),
        category: 'Tenaga Kerja',
        description: 'Upah tanam & penyiangan gulma',
        amount: 2500000,
      ),
      ExpenseModel(
        expenseId: 'exp_demo_06',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 2, 18),
        category: 'Pestisida',
        description: 'Insektisida ulat grayak & fungisida',
        amount: 1000000,
      ),
      ExpenseModel(
        expenseId: 'exp_demo_07',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 2, 25),
        category: 'Biaya Lain-lain',
        description: 'Transportasi angkut & sewa pompa',
        amount: 1500000,
      ),
    ]);

    // Pengeluaran Siklus Historis 2025
    _expenses.addAll([
      ExpenseModel(
        expenseId: 'exp_hist_01',
        userId: uId,
        plantingId: plantingHist.plantingId,
        date: DateTime(2025, 3, 10),
        category: 'Total Biaya Produksi',
        description: 'Seluruh operasional musim 2025',
        amount: 11500000,
      ),
    ]);

    // Panen Siklus Historis 2025: 8,1 ton @ Rp 4.200/kg -> Rp 34.020.000
    _harvests.add(HarvestModel(
      harvestId: 'hrv_hist_01',
      userId: uId,
      plantingId: plantingHist.plantingId,
      harvestDate: pHistActual,
      quantityKg: 8100,
      salePricePerKg: 4200,
      revenue: 34020000,
      notes: 'Hasil panen aktual musim tanam 2025.',
    ));

    // Aktivitas Budidaya Demo
    _activities.addAll([
      ActivityModel(
        activityId: 'act_demo_01',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 2, 18),
        type: 'Pestisida',
        description: 'Penyemprotan pencegahan hama ulat daun',
        notes: 'Penyemprotan pagi hari saat kondisi angin tenang.',
      ),
      ActivityModel(
        activityId: 'act_demo_02',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 1, 20),
        type: 'Pemupukan',
        description: 'Pemupukan pertama NPK Phonska dan Urea',
        notes: 'Diberikan di samping lubang tanam sedalam 5 cm.',
      ),
      ActivityModel(
        activityId: 'act_demo_03',
        userId: uId,
        plantingId: planting1.plantingId,
        date: DateTime(2026, 1, 12),
        type: 'Penanaman',
        description: 'Penanaman benih jagung Bisi 18 serempak',
        notes: 'Jarak tanam 70 x 20 cm, 1 biji per lubang.',
      ),
    ]);

    // Pengingat Demo
    _reminders.addAll([
      ReminderModel(
        reminderId: 'rem_demo_01',
        userId: uId,
        plantingId: planting1.plantingId,
        title: 'Pemupukan Kedua',
        scheduledDate: DateTime.now().add(const Duration(days: 3)),
        description: 'Aplikasi pupuk susulan pada umur 35-40 HST.',
      ),
      ReminderModel(
        reminderId: 'rem_demo_02',
        userId: uId,
        plantingId: planting1.plantingId,
        title: 'Pencatatan Biaya Operasional',
        scheduledDate: DateTime.now().add(const Duration(days: 5)),
        description: 'Periksa nota pembelian dan upah tenaga kerja.',
      ),
      ReminderModel(
        reminderId: 'rem_demo_03',
        userId: uId,
        plantingId: planting1.plantingId,
        title: 'Perkiraan Panen (Estimasi)',
        scheduledDate: planting1.estimatedHarvestDate,
        description: 'Periksa kesiapan tongkol jagung mengering sempurna.',
      ),
    ]);
  }
}
