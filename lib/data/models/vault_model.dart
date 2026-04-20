import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type, Query;

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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'iconName': iconName,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'allocationPercent': allocationPercent,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory VaultModel.fromMap(Map<String, dynamic> map, {int? id}) {
    final v = VaultModel(
      title: map['title'] ?? '',
      iconName: map['iconName'] ?? '',
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      allocationPercent: (map['allocationPercent'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
    if (id != null) v.id = id;
    return v;
  }
}
