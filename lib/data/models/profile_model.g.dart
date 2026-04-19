// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProfileModelCollection on Isar {
  IsarCollection<ProfileModel> get profileModels => this.collection();
}

const ProfileModelSchema = CollectionSchema(
  name: r'ProfileModel',
  id: 7663001939508120177,
  properties: {
    r'age': PropertySchema(
      id: 0,
      name: r'age',
      type: IsarType.long,
    ),
    r'allowancePercent': PropertySchema(
      id: 1,
      name: r'allowancePercent',
      type: IsarType.long,
    ),
    r'biometricEnabled': PropertySchema(
      id: 2,
      name: r'biometricEnabled',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyLimit': PropertySchema(
      id: 4,
      name: r'dailyLimit',
      type: IsarType.double,
    ),
    r'dreamVaultPercent': PropertySchema(
      id: 5,
      name: r'dreamVaultPercent',
      type: IsarType.long,
    ),
    r'email': PropertySchema(
      id: 6,
      name: r'email',
      type: IsarType.string,
    ),
    r'emergencyPercent': PropertySchema(
      id: 7,
      name: r'emergencyPercent',
      type: IsarType.long,
    ),
    r'financialDetails': PropertySchema(
      id: 8,
      name: r'financialDetails',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 9,
      name: r'gender',
      type: IsarType.string,
    ),
    r'hasSeenInitialSync': PropertySchema(
      id: 10,
      name: r'hasSeenInitialSync',
      type: IsarType.bool,
    ),
    r'lastQuizDate': PropertySchema(
      id: 11,
      name: r'lastQuizDate',
      type: IsarType.string,
    ),
    r'lifetimePoints': PropertySchema(
      id: 12,
      name: r'lifetimePoints',
      type: IsarType.long,
    ),
    r'monthlyLimit': PropertySchema(
      id: 13,
      name: r'monthlyLimit',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'phoneNo': PropertySchema(
      id: 15,
      name: r'phoneNo',
      type: IsarType.string,
    ),
    r'qualification': PropertySchema(
      id: 16,
      name: r'qualification',
      type: IsarType.string,
    ),
    r'quizStatus': PropertySchema(
      id: 17,
      name: r'quizStatus',
      type: IsarType.string,
    ),
    r'smsTrackingEnabled': PropertySchema(
      id: 18,
      name: r'smsTrackingEnabled',
      type: IsarType.bool,
    ),
    r'totalLockedSavings': PropertySchema(
      id: 19,
      name: r'totalLockedSavings',
      type: IsarType.double,
    ),
    r'uid': PropertySchema(
      id: 20,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _profileModelEstimateSize,
  serialize: _profileModelSerialize,
  deserialize: _profileModelDeserialize,
  deserializeProp: _profileModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _profileModelGetId,
  getLinks: _profileModelGetLinks,
  attach: _profileModelAttach,
  version: '3.1.0+1',
);

int _profileModelEstimateSize(
  ProfileModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.financialDetails.length * 3;
  bytesCount += 3 + object.gender.length * 3;
  {
    final value = object.lastQuizDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.phoneNo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.qualification.length * 3;
  bytesCount += 3 + object.quizStatus.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _profileModelSerialize(
  ProfileModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.age);
  writer.writeLong(offsets[1], object.allowancePercent);
  writer.writeBool(offsets[2], object.biometricEnabled);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDouble(offsets[4], object.dailyLimit);
  writer.writeLong(offsets[5], object.dreamVaultPercent);
  writer.writeString(offsets[6], object.email);
  writer.writeLong(offsets[7], object.emergencyPercent);
  writer.writeString(offsets[8], object.financialDetails);
  writer.writeString(offsets[9], object.gender);
  writer.writeBool(offsets[10], object.hasSeenInitialSync);
  writer.writeString(offsets[11], object.lastQuizDate);
  writer.writeLong(offsets[12], object.lifetimePoints);
  writer.writeDouble(offsets[13], object.monthlyLimit);
  writer.writeString(offsets[14], object.name);
  writer.writeString(offsets[15], object.phoneNo);
  writer.writeString(offsets[16], object.qualification);
  writer.writeString(offsets[17], object.quizStatus);
  writer.writeBool(offsets[18], object.smsTrackingEnabled);
  writer.writeDouble(offsets[19], object.totalLockedSavings);
  writer.writeString(offsets[20], object.uid);
  writer.writeDateTime(offsets[21], object.updatedAt);
}

ProfileModel _profileModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProfileModel(
    age: reader.readLong(offsets[0]),
    allowancePercent: reader.readLongOrNull(offsets[1]) ?? 50,
    biometricEnabled: reader.readBoolOrNull(offsets[2]) ?? false,
    createdAt: reader.readDateTime(offsets[3]),
    dailyLimit: reader.readDoubleOrNull(offsets[4]) ?? 1000.0,
    dreamVaultPercent: reader.readLongOrNull(offsets[5]) ?? 30,
    email: reader.readStringOrNull(offsets[6]),
    emergencyPercent: reader.readLongOrNull(offsets[7]) ?? 20,
    financialDetails: reader.readString(offsets[8]),
    gender: reader.readString(offsets[9]),
    hasSeenInitialSync: reader.readBoolOrNull(offsets[10]) ?? false,
    lastQuizDate: reader.readStringOrNull(offsets[11]),
    lifetimePoints: reader.readLongOrNull(offsets[12]) ?? 0,
    monthlyLimit: reader.readDoubleOrNull(offsets[13]) ?? 30000.0,
    name: reader.readString(offsets[14]),
    phoneNo: reader.readStringOrNull(offsets[15]),
    qualification: reader.readString(offsets[16]),
    quizStatus: reader.readStringOrNull(offsets[17]) ?? "new",
    smsTrackingEnabled: reader.readBoolOrNull(offsets[18]) ?? true,
    totalLockedSavings: reader.readDoubleOrNull(offsets[19]) ?? 0.0,
    uid: reader.readString(offsets[20]),
    updatedAt: reader.readDateTime(offsets[21]),
  );
  object.id = id;
  return object;
}

P _profileModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 50) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 1000.0) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 30) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 20) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 13:
      return (reader.readDoubleOrNull(offset) ?? 30000.0) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset) ?? "new") as P;
    case 18:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 19:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _profileModelGetId(ProfileModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _profileModelGetLinks(ProfileModel object) {
  return [];
}

void _profileModelAttach(
    IsarCollection<dynamic> col, Id id, ProfileModel object) {
  object.id = id;
}

extension ProfileModelByIndex on IsarCollection<ProfileModel> {
  Future<ProfileModel?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  ProfileModel? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<ProfileModel?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<ProfileModel?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(ProfileModel object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(ProfileModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<ProfileModel> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<ProfileModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension ProfileModelQueryWhereSort
    on QueryBuilder<ProfileModel, ProfileModel, QWhere> {
  QueryBuilder<ProfileModel, ProfileModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProfileModelQueryWhere
    on QueryBuilder<ProfileModel, ProfileModel, QWhereClause> {
  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> uidEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterWhereClause> uidNotEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProfileModelQueryFilter
    on QueryBuilder<ProfileModel, ProfileModel, QFilterCondition> {
  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> ageEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      ageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> ageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> ageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'age',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      allowancePercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowancePercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      allowancePercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allowancePercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      allowancePercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allowancePercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      allowancePercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allowancePercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      biometricEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'biometricEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dailyLimitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dailyLimitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dailyLimitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dailyLimitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dreamVaultPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dreamVaultPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dreamVaultPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dreamVaultPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dreamVaultPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dreamVaultPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      dreamVaultPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dreamVaultPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emergencyPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emergencyPercentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emergencyPercentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyPercent',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      emergencyPercentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'financialDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'financialDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'financialDetails',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'financialDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'financialDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'financialDetails',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'financialDetails',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'financialDetails',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      financialDetailsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'financialDetails',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> genderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> genderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> genderMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      hasSeenInitialSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasSeenInitialSync',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastQuizDate',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastQuizDate',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastQuizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastQuizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastQuizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastQuizDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastQuizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastQuizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastQuizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastQuizDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastQuizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lastQuizDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastQuizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lifetimePointsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lifetimePoints',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lifetimePointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lifetimePoints',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lifetimePointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lifetimePoints',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      lifetimePointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lifetimePoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      monthlyLimitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthlyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      monthlyLimitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthlyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      monthlyLimitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthlyLimit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      monthlyLimitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthlyLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phoneNo',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phoneNo',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phoneNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phoneNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phoneNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phoneNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phoneNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phoneNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phoneNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNo',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      phoneNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phoneNo',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qualification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qualification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qualification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qualification',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'qualification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'qualification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'qualification',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'qualification',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qualification',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      qualificationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'qualification',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quizStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quizStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quizStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quizStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quizStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quizStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quizStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quizStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quizStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      quizStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quizStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      smsTrackingEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'smsTrackingEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      totalLockedSavingsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalLockedSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      totalLockedSavingsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalLockedSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      totalLockedSavingsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalLockedSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      totalLockedSavingsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalLockedSavings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProfileModelQueryObject
    on QueryBuilder<ProfileModel, ProfileModel, QFilterCondition> {}

extension ProfileModelQueryLinks
    on QueryBuilder<ProfileModel, ProfileModel, QFilterCondition> {}

extension ProfileModelQuerySortBy
    on QueryBuilder<ProfileModel, ProfileModel, QSortBy> {
  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByAllowancePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowancePercent', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByAllowancePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowancePercent', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByDailyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimit', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByDailyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimit', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByDreamVaultPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dreamVaultPercent', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByDreamVaultPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dreamVaultPercent', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByEmergencyPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPercent', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByEmergencyPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPercent', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByFinancialDetails() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialDetails', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByFinancialDetailsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialDetails', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByHasSeenInitialSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeenInitialSync', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByHasSeenInitialSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeenInitialSync', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByLastQuizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuizDate', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByLastQuizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuizDate', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByLifetimePoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePoints', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByLifetimePointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePoints', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByMonthlyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByPhoneNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNo', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByPhoneNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNo', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByQualification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualification', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByQualificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualification', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByQuizStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizStatus', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByQuizStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizStatus', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortBySmsTrackingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsTrackingEnabled', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortBySmsTrackingEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsTrackingEnabled', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByTotalLockedSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalLockedSavings', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      sortByTotalLockedSavingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalLockedSavings', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProfileModelQuerySortThenBy
    on QueryBuilder<ProfileModel, ProfileModel, QSortThenBy> {
  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByAllowancePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowancePercent', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByAllowancePercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowancePercent', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByDailyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimit', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByDailyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimit', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByDreamVaultPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dreamVaultPercent', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByDreamVaultPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dreamVaultPercent', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByEmergencyPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPercent', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByEmergencyPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyPercent', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByFinancialDetails() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialDetails', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByFinancialDetailsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'financialDetails', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByHasSeenInitialSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeenInitialSync', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByHasSeenInitialSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeenInitialSync', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByLastQuizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuizDate', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByLastQuizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuizDate', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByLifetimePoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePoints', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByLifetimePointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lifetimePoints', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByMonthlyLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyLimit', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByPhoneNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNo', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByPhoneNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNo', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByQualification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualification', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByQualificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qualification', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByQuizStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizStatus', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByQuizStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quizStatus', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenBySmsTrackingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsTrackingEnabled', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenBySmsTrackingEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smsTrackingEnabled', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByTotalLockedSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalLockedSavings', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy>
      thenByTotalLockedSavingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalLockedSavings', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProfileModelQueryWhereDistinct
    on QueryBuilder<ProfileModel, ProfileModel, QDistinct> {
  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByAllowancePercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowancePercent');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biometricEnabled');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByDailyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyLimit');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByDreamVaultPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dreamVaultPercent');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByEmergencyPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyPercent');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByFinancialDetails({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'financialDetails',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByGender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByHasSeenInitialSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasSeenInitialSync');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByLastQuizDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastQuizDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByLifetimePoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lifetimePoints');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByMonthlyLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyLimit');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByPhoneNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneNo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByQualification(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qualification',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByQuizStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quizStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctBySmsTrackingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smsTrackingEnabled');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct>
      distinctByTotalLockedSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalLockedSavings');
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProfileModel, ProfileModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ProfileModelQueryProperty
    on QueryBuilder<ProfileModel, ProfileModel, QQueryProperty> {
  QueryBuilder<ProfileModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProfileModel, int, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<ProfileModel, int, QQueryOperations> allowancePercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowancePercent');
    });
  }

  QueryBuilder<ProfileModel, bool, QQueryOperations>
      biometricEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biometricEnabled');
    });
  }

  QueryBuilder<ProfileModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProfileModel, double, QQueryOperations> dailyLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyLimit');
    });
  }

  QueryBuilder<ProfileModel, int, QQueryOperations>
      dreamVaultPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dreamVaultPercent');
    });
  }

  QueryBuilder<ProfileModel, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<ProfileModel, int, QQueryOperations> emergencyPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyPercent');
    });
  }

  QueryBuilder<ProfileModel, String, QQueryOperations>
      financialDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'financialDetails');
    });
  }

  QueryBuilder<ProfileModel, String, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<ProfileModel, bool, QQueryOperations>
      hasSeenInitialSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasSeenInitialSync');
    });
  }

  QueryBuilder<ProfileModel, String?, QQueryOperations> lastQuizDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastQuizDate');
    });
  }

  QueryBuilder<ProfileModel, int, QQueryOperations> lifetimePointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lifetimePoints');
    });
  }

  QueryBuilder<ProfileModel, double, QQueryOperations> monthlyLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyLimit');
    });
  }

  QueryBuilder<ProfileModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ProfileModel, String?, QQueryOperations> phoneNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneNo');
    });
  }

  QueryBuilder<ProfileModel, String, QQueryOperations> qualificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qualification');
    });
  }

  QueryBuilder<ProfileModel, String, QQueryOperations> quizStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quizStatus');
    });
  }

  QueryBuilder<ProfileModel, bool, QQueryOperations>
      smsTrackingEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smsTrackingEnabled');
    });
  }

  QueryBuilder<ProfileModel, double, QQueryOperations>
      totalLockedSavingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalLockedSavings');
    });
  }

  QueryBuilder<ProfileModel, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<ProfileModel, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
