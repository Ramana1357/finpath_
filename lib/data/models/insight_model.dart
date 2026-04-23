import 'package:isar/isar.dart';

part 'insight_model.g.dart';

@collection
class InsightModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String monthId; // Format: "YYYY-MM"

  late double needsTotal;
  late double wantsTotal;
  late double savingsTotal;

  late double needsPct;
  late double wantsPct;
  late double savingsPct;

  late int healthScore;

  InsightModel({
    required this.monthId,
    this.needsTotal = 0.0,
    this.wantsTotal = 0.0,
    this.savingsTotal = 0.0,
    this.needsPct = 0.0,
    this.wantsPct = 0.0,
    this.savingsPct = 0.0,
    this.healthScore = 0,
  });
}
