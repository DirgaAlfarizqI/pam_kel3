import 'package:flutter_test/flutter_test.dart';
import 'package:jgung/core/utils/calculator.dart';
import 'package:jgung/models/app_models.dart';

void main() {
  group('TaniCalculator Unit Tests', () {
    test('1. Perhitungan perkiraan tanggal panen +4 bulan kalender', () {
      // Skenario wajib: 12 Januari 2026 -> 12 Mei 2026
      final plantingDate = DateTime(2026, 1, 12);
      final estimatedHarvest = TaniCalculator.calculateEstimatedHarvestDate(plantingDate);

      expect(estimatedHarvest.year, 2026);
      expect(estimatedHarvest.month, 5);
      expect(estimatedHarvest.day, 12);

      // Edge case penanganan hari kalender (misal 31 Oktober -> akhir Februari tahun berikutnya)
      final octDate = DateTime(2025, 10, 31);
      final febHarvest = TaniCalculator.calculateEstimatedHarvestDate(octDate);
      expect(febHarvest.year, 2026);
      expect(febHarvest.month, 2);
      expect(febHarvest.day, 28); // 2026 bukan tahun kabisat, max 28 Februari
    });

    test('2. Perhitungan biaya pupuk (manual quantity * price)', () {
      // Skenario wajib: Urea 25 kg @ Rp 6.000
      final cost = TaniCalculator.calculateFertilizerCost(25.0, 6000.0);
      expect(cost, 150000.0);
    });

    test('3. Konversi panen dari Ton ke Kg dan pendapatan', () {
      // Skenario wajib: 5,5 ton -> 5.500 kg @ Rp 4.000/kg = Rp 22.000.000
      final harvestKg = TaniCalculator.convertHarvestToKg(5.5, 'ton');
      expect(harvestKg, 5500.0);

      final revenue = TaniCalculator.calculateHarvestRevenue(harvestKg, 4000.0);
      expect(revenue, 22000000.0);
    });

    test('4. Skenario Penuh Wajib Siklus 1 & Isolasi Siklus 2', () {
      const userId = 'user_budi_01';
      const landId = 'land_utara_01';
      const areaHa = 1.0;

      // Siklus 1
      final planting1 = PlantingModel(
        plantingId: 'planting_cycle_01',
        userId: userId,
        landId: landId,
        name: 'Musim Tanam 1 - 2026',
        cornVariety: 'Bisi 18',
        plantingDate: DateTime(2026, 1, 12),
        estimatedHarvestDate: TaniCalculator.calculateEstimatedHarvestDate(DateTime(2026, 1, 12)),
        status: 'selesai',
      );

      expect(planting1.estimatedHarvestDate, DateTime(2026, 5, 12));

      // Pengeluaran Siklus 1
      final expensesCycle1 = [
        ExpenseModel(
          expenseId: 'exp_01',
          userId: userId,
          plantingId: planting1.plantingId,
          date: DateTime(2026, 1, 15),
          category: 'Pupuk',
          description: 'Pupuk Urea',
          quantity: 25.0,
          unit: 'kg',
          unitPrice: 6000.0,
          amount: TaniCalculator.calculateFertilizerCost(25.0, 6000.0), // 150.000
        ),
        ExpenseModel(
          expenseId: 'exp_02',
          userId: userId,
          plantingId: planting1.plantingId,
          date: DateTime(2026, 1, 12),
          category: 'Benih',
          description: 'Benih Bisi 18 (20 kg)',
          amount: 800000.0,
        ),
        ExpenseModel(
          expenseId: 'exp_03',
          userId: userId,
          plantingId: planting1.plantingId,
          date: DateTime(2026, 1, 10),
          category: 'Pengolahan Lahan',
          description: 'Bajak & Traktor',
          amount: 1200000.0,
        ),
        ExpenseModel(
          expenseId: 'exp_04',
          userId: userId,
          plantingId: planting1.plantingId,
          date: DateTime(2026, 2, 10),
          category: 'Tenaga Kerja',
          description: 'Penyiangan & Perawatan',
          amount: 1500000.0,
        ),
        ExpenseModel(
          expenseId: 'exp_05',
          userId: userId,
          plantingId: planting1.plantingId,
          date: DateTime(2026, 3, 1),
          category: 'Biaya Lain-lain',
          description: 'Pestisida & Bahan tambahan',
          amount: 350000.0,
        ),
      ];

      final totalExpenseCycle1 = TaniCalculator.calculateTotalExpenses(
        expensesCycle1.map((e) => e.amount),
      );
      // 150.000 + 800.000 + 1.200.000 + 1.500.000 + 350.000 = 4.000.000
      expect(totalExpenseCycle1, 4000000.0);

      // Panen Siklus 1
      final harvestKg = TaniCalculator.convertHarvestToKg(5.5, 'ton'); // 5500 kg
      final revenue = TaniCalculator.calculateHarvestRevenue(harvestKg, 4000.0); // 22.000.000
      final netProfit = TaniCalculator.calculateProfitLoss(revenue, totalExpenseCycle1);
      final status = TaniCalculator.determineProfitLossStatus(
        hasHarvestData: true,
        revenue: revenue,
        totalExpenses: totalExpenseCycle1,
      );
      final productivity = TaniCalculator.calculateProductivity(
        harvestKg: harvestKg,
        areaHa: areaHa,
      );

      expect(revenue, 22000000.0);
      expect(netProfit, 18000000.0);
      expect(status, 'UNTUNG');
      expect(productivity, 5.5); // 5,5 ton/ha

      // Siklus 2 di lahan yang sama dengan plantingId berbeda
      final planting2 = PlantingModel(
        plantingId: 'planting_cycle_02',
        userId: userId,
        landId: landId,
        name: 'Musim Tanam 2 - 2026',
        cornVariety: 'NK 212',
        plantingDate: DateTime(2026, 6, 1),
        estimatedHarvestDate: TaniCalculator.calculateEstimatedHarvestDate(DateTime(2026, 6, 1)),
        status: 'aktif',
      );

      expect(planting2.plantingId, isNot(planting1.plantingId));
      expect(planting2.estimatedHarvestDate, DateTime(2026, 10, 1));

      // Pengeluaran Siklus 2
      final expensesCycle2 = [
        ExpenseModel(
          expenseId: 'exp_06',
          userId: userId,
          plantingId: planting2.plantingId,
          date: DateTime(2026, 6, 2),
          category: 'Benih',
          description: 'Benih NK 212',
          amount: 850000.0,
        ),
      ];

      // Verifikasi isolasi pengeluaran siklus 1 dan 2
      final filterCycle1 = [...expensesCycle1, ...expensesCycle2]
          .where((e) => e.plantingId == planting1.plantingId)
          .map((e) => e.amount);
      final filterCycle2 = [...expensesCycle1, ...expensesCycle2]
          .where((e) => e.plantingId == planting2.plantingId)
          .map((e) => e.amount);

      expect(TaniCalculator.calculateTotalExpenses(filterCycle1), 4000000.0);
      expect(TaniCalculator.calculateTotalExpenses(filterCycle2), 850000.0);
    });
  });
}
