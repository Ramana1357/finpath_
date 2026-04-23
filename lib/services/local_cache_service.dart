import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../data/models/profile_model.dart';
import '../data/models/vault_model.dart';

import '../data/models/insight_model.dart';

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
      [ExpenseTransactionSchema, ProfileModelSchema, VaultModelSchema, InsightModelSchema],
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
        await isar.expenseTransactions.put(transaction);

        // If it's an expense, we need to ensure our savings totals don't exceed our actual balance
        if (transaction.isExpense) {
          final profile = await isar.profileModels.where().findFirst();
          if (profile != null) {
            final allTxs = await isar.expenseTransactions.where().findAll();
            double totalNet = 0;
            for (var tx in allTxs) {
              totalNet += tx.isExpense ? -tx.amount : tx.amount;
            }

            double currentLocked = profile.totalLockedSavings;
            double currentVault = profile.totalVaultSavings;
            double totalSavings = currentLocked + currentVault;

            // If actual balance is less than what we claim to have in savings,
            // it means we've spent into our savings. We must reconcile.
            if (totalNet < totalSavings) {
              double reconciledSavings = totalNet.clamp(0.0, double.infinity);
              double deficit = totalSavings - reconciledSavings;

              double newLocked = currentLocked;
              double newVault = currentVault;

              if (deficit > 0) {
                // 1. Take from Locked Savings first
                double takeFromLocked = deficit > currentLocked ? currentLocked : deficit;
                newLocked -= takeFromLocked;
                double remainingDeficit = deficit - takeFromLocked;

                // 2. Take from Vault Savings if still in deficit
                if (remainingDeficit > 0) {
                  double takeFromVault = remainingDeficit > currentVault ? currentVault : remainingDeficit;
                  newVault -= takeFromVault;
                }
              }

              final updatedProfile = profile.copyWith(
                totalLockedSavings: newLocked,
                totalVaultSavings: newVault,
                updatedAt: DateTime.now(),
              );
              await isar.profileModels.put(updatedProfile);
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Error saving transaction: $e");
    }
    notifyListeners();
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    return await isar.expenseTransactions.where().sortByDateDesc().findAll();
  }

  Future<double> getTotalNetBalance() async {
    final allTxs = await isar.expenseTransactions.where().findAll();
    double totalNet = 0;
    for (var tx in allTxs) {
      totalNet += tx.isExpense ? -tx.amount : tx.amount;
    }
    return totalNet;
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

  // --- INSIGHT METHODS ---
  Future<void> saveInsight(InsightModel insight) async {
    await isar.writeTxn(() async {
      final existing = await isar.insightModels
          .filter()
          .monthIdEqualTo(insight.monthId)
          .findFirst();
      
      if (existing != null) {
        insight.id = existing.id;
      }
      await isar.insightModels.put(insight);
    });
    notifyListeners();
  }

  Stream<InsightModel?> watchInsightForMonth(String monthId) {
    return isar.insightModels
        .filter()
        .monthIdEqualTo(monthId)
        .watch(fireImmediately: true)
        .map((insights) => insights.isNotEmpty ? insights.first : null);
  }
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

      double toEmergency = incomeAmount * (profile.emergencyPercent / 100);
      double toVaults = incomeAmount * (profile.dreamVaultPercent / 100);
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

  Future<void> freshRestart(String uid) async {
    final hashedId = _fastHash(uid);
    await isar.writeTxn(() async {
      await isar.expenseTransactions.clear();
      await isar.vaultModels.clear();
      final profile = await isar.profileModels.get(hashedId);
      if (profile != null) {
        final updatedProfile = profile.copyWith(
          totalLockedSavings: 0.0,
          totalVaultSavings: 0.0,
          updatedAt: DateTime.now(),
        );
        await isar.profileModels.put(updatedProfile);
      }
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
