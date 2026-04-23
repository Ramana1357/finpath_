import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type, Query;
import 'package:isar/isar.dart';

part 'profile_model.g.dart';

@collection
class ProfileModel {
  Id id = Isar.autoIncrement;

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
  final double needsTarget;
  final double wantsTarget;
  final double savingsTarget;
  final double monthlyAllowance;
  final bool biometricEnabled;
  final int lifetimePoints;
  
  // formatted as 'YYYY-MM-DD'
  final String? lastQuizDate; 
  
  final String quizStatus; // "new", "completed", "pending"
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final double totalLockedSavings;
  final double totalVaultSavings;
  final bool smsTrackingEnabled;
  final bool hasSeenInitialSync;
  final double dailyLimit;
  final double monthlyLimit;
  final bool isCrisisMode;
  final String? profilePictureUrl;
  final String? envelopeLimitsJson; // Stores category limits as a JSON map

  ProfileModel({
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
    this.needsTarget = 50.0,
    this.wantsTarget = 30.0,
    this.savingsTarget = 20.0,
    this.monthlyAllowance = 30000.0,
    this.biometricEnabled = false,
    this.lifetimePoints = 0,
    this.lastQuizDate,
    this.quizStatus = "new",
    required this.createdAt,
    required this.updatedAt,
    this.totalLockedSavings = 0.0,
    this.totalVaultSavings = 0.0,
    this.smsTrackingEnabled = true,
    this.hasSeenInitialSync = false,
    this.dailyLimit = 1000.0,
    this.monthlyLimit = 30000.0,
    this.isCrisisMode = false,
    this.profilePictureUrl,
    this.envelopeLimitsJson,
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
      'needsTarget': needsTarget,
      'wantsTarget': wantsTarget,
      'savingsTarget': savingsTarget,
      'monthlyAllowance': monthlyAllowance,
      'biometricEnabled': biometricEnabled,
      'lifetimePoints': lifetimePoints,
      'lastQuizDate': lastQuizDate,
      'quizStatus': quizStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'totalLockedSavings': totalLockedSavings,
      'totalVaultSavings': totalVaultSavings,
      'smsTrackingEnabled': smsTrackingEnabled,
      'hasSeenInitialSync': hasSeenInitialSync,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
      'isCrisisMode': isCrisisMode,
      'profilePictureUrl': profilePictureUrl,
      'envelopeLimitsJson': envelopeLimitsJson,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
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
      needsTarget: (map['needsTarget'] as num?)?.toDouble() ?? 50.0,
      wantsTarget: (map['wantsTarget'] as num?)?.toDouble() ?? 30.0,
      savingsTarget: (map['savingsTarget'] as num?)?.toDouble() ?? 20.0,
      monthlyAllowance: (map['monthlyAllowance'] as num?)?.toDouble() ?? 30000.0,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      lifetimePoints: map['lifetimePoints'] as int? ?? 0,
      lastQuizDate: map['lastQuizDate'] as String?,
      quizStatus: map['quizStatus'] as String? ?? "new",
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      totalLockedSavings: (map['totalLockedSavings'] as num?)?.toDouble() ?? 0.0,
      totalVaultSavings: (map['totalVaultSavings'] as num?)?.toDouble() ?? 0.0,
      smsTrackingEnabled: map['smsTrackingEnabled'] as bool? ?? true,
      hasSeenInitialSync: map['hasSeenInitialSync'] as bool? ?? false,
      dailyLimit: (map['dailyLimit'] as num?)?.toDouble() ?? 1000.0,
      monthlyLimit: (map['monthlyLimit'] as num?)?.toDouble() ?? 30000.0,
      isCrisisMode: map['isCrisisMode'] as bool? ?? false,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      envelopeLimitsJson: map['envelopeLimitsJson'] as String?,
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
    double? needsTarget,
    double? wantsTarget,
    double? savingsTarget,
    double? monthlyAllowance,
    bool? biometricEnabled,
    int? lifetimePoints,
    String? lastQuizDate,
    String? quizStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalLockedSavings,
    double? totalVaultSavings,
    bool? smsTrackingEnabled,
    bool? hasSeenInitialSync,
    double? dailyLimit,
    double? monthlyLimit,
    bool? isCrisisMode,
    String? profilePictureUrl,
    String? envelopeLimitsJson,
  }) {
    return ProfileModel(
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
      needsTarget: needsTarget ?? this.needsTarget,
      wantsTarget: wantsTarget ?? this.wantsTarget,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      monthlyAllowance: monthlyAllowance ?? this.monthlyAllowance,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      quizStatus: quizStatus ?? this.quizStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalLockedSavings: totalLockedSavings ?? this.totalLockedSavings,
      totalVaultSavings: totalVaultSavings ?? this.totalVaultSavings,
      smsTrackingEnabled: smsTrackingEnabled ?? this.smsTrackingEnabled,
      hasSeenInitialSync: hasSeenInitialSync ?? this.hasSeenInitialSync,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      isCrisisMode: isCrisisMode ?? this.isCrisisMode,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      envelopeLimitsJson: envelopeLimitsJson ?? this.envelopeLimitsJson,
    )..id = id ?? this.id;
  }
}
