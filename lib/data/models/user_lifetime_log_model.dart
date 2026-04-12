import 'package:cloud_firestore/cloud_firestore.dart';

class UserLifetimeLogModel {
  final String logId;
  final String uid;
  final String eventType;
  final int lifetimePoints;
  final Map<String, dynamic> categories;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  UserLifetimeLogModel({
    required this.logId,
    required this.uid,
    required this.eventType,
    required this.lifetimePoints,
    required this.categories,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'uid': uid,
      'eventType': eventType,
      'lifetimePoints': lifetimePoints,
      'categories': categories,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }

  factory UserLifetimeLogModel.fromMap(Map<String, dynamic> map) {
    return UserLifetimeLogModel(
      logId: map['logId'] as String,
      uid: map['uid'] as String,
      eventType: map['eventType'] as String,
      lifetimePoints: map['lifetimePoints'] as int,
      categories: Map<String, dynamic>.from(map['categories'] as Map),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }
}
