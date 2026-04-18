import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/profile_model.dart';
import '../models/transaction.dart';
import '../data/models/vault_model.dart';

class LocalCacheService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ProfileModelSchema, ExpenseTransactionSchema, VaultModelSchema],
      directory: dir.path,
    );
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await isar.writeTxn(() async {
      await isar.profileModels.put(profile);
    });
  }

  Future<ProfileModel?> getProfile(String uid) async {
    return await isar.profileModels.filter().uidEqualTo(uid).findFirst();
  }

  Future<void> saveTransaction(ExpenseTransaction transaction) async {
    await isar.writeTxn(() async {
      await isar.expenseTransactions.put(transaction);
    });
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    return await isar.expenseTransactions.where().sortByDateDesc().findAll();
  }

  Stream<List<ExpenseTransaction>> watchTransactions() {
    return isar.expenseTransactions.where().sortByDateDesc().watch(fireImmediately: true);
  }

  Future<List<ExpenseTransaction>> getTransactionsForLastSixMonths() async {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return await isar.expenseTransactions
        .filter()
        .dateGreaterThan(sixMonthsAgo)
        .sortByDateDesc()
        .findAll();
  }

  Future<void> cleanupOldTransactions() async {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    await isar.writeTxn(() async {
      await isar.expenseTransactions
          .filter()
          .dateLessThan(sixMonthsAgo)
          .deleteAll();
    });
  }

  Future<void> deleteProfile(String uid) async {
    await isar.writeTxn(() async {
      await isar.profileModels.filter().uidEqualTo(uid).deleteFirst();
    });
  }

  Future<void> clearCache() async {
    await isar.writeTxn(() async {
      await isar.profileModels.clear();
      await isar.expenseTransactions.clear();
      await isar.vaultModels.clear();
    });
  }

  Future<void> clearTransactions() async {
    await isar.writeTxn(() async {
      await isar.expenseTransactions.clear();
    });
  }

  // --- VAULT METHODS ---
  Future<void> saveVault(VaultModel vault) async {
    await isar.writeTxn(() async {
      await isar.vaultModels.put(vault);
    });
  }

  Future<List<VaultModel>> getAllVaults() async {
    return await isar.vaultModels.where().findAll();
  }

  Stream<List<VaultModel>> watchVaults() {
    return isar.vaultModels.where().watch(fireImmediately: true);
  }

  Future<void> deleteVault(int id) async {
    await isar.writeTxn(() async {
      await isar.vaultModels.delete(id);
    });
  }

  // --- ATOMIC INCOME ALLOCATION ---
  Future<void> performIncomeAllocation(String uid, double incomeAmount) async {
    await isar.writeTxn(() async {
      // 1. Fetch profile
      final profile = await isar.profileModels.filter().uidEqualTo(uid).findFirst();
      if (profile == null) return;

      // 2. Calculate initial pots
      final double emergencyBase = (incomeAmount * profile.emergencyPercent) / 100;
      final double dreamPot = (incomeAmount * profile.dreamVaultPercent) / 100;
      
      double remainingDreamPot = dreamPot;

      // 3. Allocate to all vaults in this same transaction
      final vaults = await isar.vaultModels.where().findAll();
      for (var vault in vaults) {
        double takeAmount = (dreamPot * vault.allocationPercent) / 100;
        
        // Don't over-allocate if pot is running low
        if (takeAmount > remainingDreamPot) takeAmount = remainingDreamPot;

        if (takeAmount > 0) {
          final updatedVault = vault.copyWith(
            currentAmount: vault.currentAmount + takeAmount,
            updatedAt: DateTime.now(),
          );
          await isar.vaultModels.put(updatedVault);
          remainingDreamPot -= takeAmount;
        }
      }

      // 4. Any leftover from 30% goes to the 20% Emergency fund
      final double finalEmergencyDeposit = emergencyBase + remainingDreamPot;
      
      final updatedProfile = profile.copyWith(
        totalLockedSavings: profile.totalLockedSavings + finalEmergencyDeposit,
        updatedAt: DateTime.now(),
      );
      
      // 5. Save updated profile
      await isar.profileModels.put(updatedProfile);
    });
  }
}
