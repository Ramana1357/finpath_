import 'package:cloud_firestore/cloud_firestore.dart' hide Index;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.uid,
    required this.name,
    required this.age,
    this.email,
    this.phoneNo,
    required this.gender,
    required this.financialDetails,
    required this.qualification,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
