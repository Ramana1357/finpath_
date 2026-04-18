import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:isar/isar.dart';

part 'profile_model.g.dart';

@collection
class ProfileModel {
  Id id;

  @Index(unique: true, replace: true)
  final String uid;
  final String name;
  final int age;
  final String? email;
  final String? phoneNo;
  final String gender;
  final String financialDetails;
  final String qualification;
  final int allowancePercent;
  final int dreamVaultPercent;
  final int emergencyPercent;
  final double totalLockedSavings;
  final bool biometricEnabled;
  final bool smsTrackingEnabled;
  final int lifetimePoints;
  final DateTime? lastQuizDate;
  final String quizStatus; // "new", "completed", "pending"
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    this.id = Isar.autoIncrement,
    required this.uid,
    required this.name,
    required this.age,
    this.email,
    this.phoneNo,
    required this.gender,
    required this.financialDetails,
    required this.qualification,
    this.allowancePercent = 50,
    this.dreamVaultPercent = 30,
    this.emergencyPercent = 20,
    this.totalLockedSavings = 0.0,
    this.biometricEnabled = false,
    this.smsTrackingEnabled = true,
    this.lifetimePoints = 0,
    this.lastQuizDate,
    this.quizStatus = "new",
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'email': email,
      'phoneNo': phoneNo,
      'gender': gender,
      'financialDetails': financialDetails,
      'qualification': qualification,
      'allowancePercent': allowancePercent,
      'dreamVaultPercent': dreamVaultPercent,
      'emergencyPercent': emergencyPercent,
      'totalLockedSavings': totalLockedSavings,
      'biometricEnabled': biometricEnabled,
      'smsTrackingEnabled': smsTrackingEnabled,
      'lifetimePoints': lifetimePoints,
      'lastQuizDate': lastQuizDate != null ? Timestamp.fromDate(lastQuizDate!) : null,
      'quizStatus': quizStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map, {Id? isarId}) {
    return ProfileModel(
      id: isarId ?? Isar.autoIncrement,
      uid: map['uid'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      email: map['email'] as String?,
      phoneNo: map['phoneNo'] as String?,
      gender: map['gender'] as String,
      financialDetails: map['financialDetails'] as String,
      qualification: map['qualification'] as String,
      allowancePercent: map['allowancePercent'] as int? ?? 50,
      dreamVaultPercent: map['dreamVaultPercent'] as int? ?? 30,
      emergencyPercent: map['emergencyPercent'] as int? ?? 20,
      totalLockedSavings: (map['totalLockedSavings'] as num?)?.toDouble() ?? 0.0,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      smsTrackingEnabled: map['smsTrackingEnabled'] as bool? ?? true,
      lifetimePoints: map['lifetimePoints'] as int? ?? 0,
      lastQuizDate: map['lastQuizDate'] != null ? (map['lastQuizDate'] as Timestamp).toDate() : null,
      quizStatus: map['quizStatus'] as String? ?? "new",
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  ProfileModel copyWith({
    Id? id,
    String? uid,
    String? name,
    int? age,
    String? email,
    String? phoneNo,
    String? gender,
    String? financialDetails,
    String? qualification,
    int? allowancePercent,
    int? dreamVaultPercent,
    int? emergencyPercent,
    double? totalLockedSavings,
    bool? biometricEnabled,
    bool? smsTrackingEnabled,
    int? lifetimePoints,
    DateTime? lastQuizDate,
    String? quizStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      gender: gender ?? this.gender,
      financialDetails: financialDetails ?? this.financialDetails,
      qualification: qualification ?? this.qualification,
      allowancePercent: allowancePercent ?? this.allowancePercent,
      dreamVaultPercent: dreamVaultPercent ?? this.dreamVaultPercent,
      emergencyPercent: emergencyPercent ?? this.emergencyPercent,
      totalLockedSavings: totalLockedSavings ?? this.totalLockedSavings,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      smsTrackingEnabled: smsTrackingEnabled ?? this.smsTrackingEnabled,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      quizStatus: quizStatus ?? this.quizStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
