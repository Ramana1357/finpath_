import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../data/models/profile_model.dart';
import '../data/models/vault_model.dart';

class LocalCacheService extends ChangeNotifier {
  late Isar isar;
  bool _isInitialized = false;

  LocalCacheService() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ExpenseTransactionSchema, ProfileModelSchema, VaultModelSchema],
      directory: dir.path,
    );
    _isInitialized = true;
    notifyListeners();
  }

  // Exposed for main.dart
  Future<void> init() async {
    await _init();
  }

  // Helper for deterministic Isar IDs
  int _fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit;
      hash *= 0x100000001b3;
    }
    return hash.toSigned(64);
  }

  // --- PROFILE METHODS ---
  Future<void> saveProfile(ProfileModel profile) async {
    final hashedId = _fastHash(profile.uid);
    final profileWithId = profile.copyWith(id: hashedId);
    
    await isar.writeTxn(() async {
      await isar.profileModels.put(profileWithId);
    });
    notifyListeners();
  }

  Future<ProfileModel?> getProfile(String uid) async {
    final hashedId = _fastHash(uid);
    return await isar.profileModels.get(hashedId);
  }

  Stream<ProfileModel?> watchProfile(String uid) {
    final hashedId = _fastHash(uid);
    return isar.profileModels.watchObject(hashedId, fireImmediately: true);
  }

  // --- TRANSACTION METHODS ---
  Future<void> saveTransaction(ExpenseTransaction transaction) async {
    try {
      await isar.writeTxn(() async {
        if (transaction.isExpense) {
          final profile = await isar.profileModels.where().findFirst();
          if (profile != null && profile.isCrisisMode) {
            final allTxs = await isar.expenseTransactions.where().findAll();
            double totalInflow = 0;
            double totalOutflow = 0;
            for (var tx in allTxs) {
              if (tx.isExpense) totalOutflow += tx.amount;
              else totalInflow += tx.amount;
            }

            final double currentAllowance = totalInflow - totalOutflow - profile.totalLockedSavings - profile.totalVaultSavings;

            if (currentAllowance < 0) {
              final double deficit = currentAllowance.abs();
              final double amountToTake = deficit > profile.totalLockedSavings ? profile.totalLockedSavings : deficit;

              if (amountToTake > 0) {
                final updatedProfile = profile.copyWith(
                  totalLockedSavings: (profile.totalLockedSavings - amountToTake).clamp(0.0, double.infinity),
                  updatedAt: DateTime.now(),
                );
                await isar.profileModels.put(updatedProfile);
              }
            }
          }
        }
        await isar.expenseTransactions.put(transaction);
      });
    } catch (e) {
      debugPrint("Error saving transaction: $e");
    }
    notifyListeners();
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

  Future<void> clearTransactions() async {
    await isar.writeTxn(() async {
      await isar.expenseTransactions.clear();
    });
    notifyListeners();
  }

  // --- VAULT METHODS ---
  Future<void> saveVault(VaultModel vault) async {
    await isar.writeTxn(() async {
      await isar.vaultModels.put(vault);
    });
    notifyListeners();
  }

  Future<void> deleteVault(int id) async {
    await isar.writeTxn(() async {
      await isar.vaultModels.delete(id);
    });
    notifyListeners();
  }

  Future<List<VaultModel>> getAllVaults() async {
    return await isar.vaultModels.where().findAll();
  }

  Stream<List<VaultModel>> watchVaults() {
    return isar.vaultModels.where().watch(fireImmediately: true);
  }

  // --- ATOMIC ALLOCATION ---
  Future<void> performIncomeAllocation(String uid, double incomeAmount) async {
    final hashedId = _fastHash(uid);
    await isar.writeTxn(() async {
      final profile = await isar.profileModels.get(hashedId);
      if (profile == null) return;

      double toEmergency = incomeAmount * 0.20;
      double toVaults = incomeAmount * 0.30;
      double updatedLocked = profile.totalLockedSavings + toEmergency;
      
      final vaults = await isar.vaultModels.where().findAll();
      double remainingVaultMoney = toVaults;

      for (var vault in vaults) {
        if (remainingVaultMoney <= 0) break;
        
        double needed = vault.targetAmount - vault.currentAmount;
        if (needed > 0) {
          double deposit = remainingVaultMoney > needed ? needed : remainingVaultMoney;
          final updatedVault = vault.copyWith(
            currentAmount: vault.currentAmount + deposit,
            updatedAt: DateTime.now(),
          );
          await isar.vaultModels.put(updatedVault);
          remainingVaultMoney -= deposit;
        }
      }

      if (remainingVaultMoney > 0) {
        updatedLocked += remainingVaultMoney;
      }

      final updatedProfile = profile.copyWith(
        totalLockedSavings: updatedLocked,
        totalVaultSavings: (profile.totalVaultSavings + (toVaults - remainingVaultMoney)),
        updatedAt: DateTime.now(),
      );
      await isar.profileModels.put(updatedProfile);
    });
    notifyListeners();
  }

  Future<void> clearCache() async {
    await isar.writeTxn(() async {
      await isar.expenseTransactions.clear();
      await isar.profileModels.clear();
      await isar.vaultModels.clear();
    });
    notifyListeners();
  }
}
