import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/profile_model.dart';
import '../models/transaction.dart';

class LocalCacheService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ProfileModelSchema, ExpenseTransactionSchema],
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
    });
  }

  Future<void> clearTransactions() async {
    await isar.writeTxn(() async {
      await isar.expenseTransactions.clear();
    });
  }
}
