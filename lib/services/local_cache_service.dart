import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/profile_model.dart';

class LocalCacheService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ProfileModelSchema],
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

  Future<void> deleteProfile(String uid) async {
    await isar.writeTxn(() async {
      await isar.profileModels.filter().uidEqualTo(uid).deleteFirst();
    });
  }

  Future<void> clearCache() async {
    await isar.writeTxn(() async {
      await isar.profileModels.clear();
    });
  }
}
