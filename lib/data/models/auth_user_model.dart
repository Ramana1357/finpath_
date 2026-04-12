import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthProvider { google, phone, emailPassword }

class AuthUserModel {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final AuthProvider authProvider;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String accountStatus;

  AuthUserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    required this.authProvider,
    required this.createdAt,
    required this.lastLoginAt,
    required this.accountStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'authProvider': authProvider.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'accountStatus': accountStatus,
    };
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      authProvider: AuthProvider.values.byName(map['authProvider'] as String),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp).toDate(),
      accountStatus: map['accountStatus'] as String,
    );
  }
}
