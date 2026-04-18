import 'package:isar/isar.dart';

part 'vault_model.g.dart';

@collection
class VaultModel {
  Id id = Isar.autoIncrement;

  final String title;
  final String iconName; 
  final double currentAmount;
  final double targetAmount;
  final double allocationPercent; // Changed from fixedAllocation to percentage of the 30% pot
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultModel({
    required this.title,
    required this.iconName,
    this.currentAmount = 0.0,
    required this.targetAmount,
    this.allocationPercent = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get percentage => (currentAmount / targetAmount);

  VaultModel copyWith({
    Id? id,
    String? title,
    String? iconName,
    double? currentAmount,
    double? targetAmount,
    double? allocationPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final v = VaultModel(
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      allocationPercent: allocationPercent ?? this.allocationPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
    v.id = id ?? this.id;
    return v;
  }
}
