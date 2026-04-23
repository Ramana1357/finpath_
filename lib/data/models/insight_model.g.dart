// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInsightModelCollection on Isar {
  IsarCollection<InsightModel> get insightModels => this.collection();
}

const InsightModelSchema = CollectionSchema(
  name: r'InsightModel',
  id: -423129788428064119,
  properties: {
    r'healthScore': PropertySchema(
      id: 0,
      name: r'healthScore',
      type: IsarType.long,
    ),
    r'monthId': PropertySchema(
      id: 1,
      name: r'monthId',
      type: IsarType.string,
    ),
    r'needsPct': PropertySchema(
      id: 2,
      name: r'needsPct',
      type: IsarType.double,
    ),
    r'needsTotal': PropertySchema(
      id: 3,
      name: r'needsTotal',
      type: IsarType.double,
    ),
    r'savingsPct': PropertySchema(
      id: 4,
      name: r'savingsPct',
      type: IsarType.double,
    ),
    r'savingsTotal': PropertySchema(
      id: 5,
      name: r'savingsTotal',
      type: IsarType.double,
    ),
    r'wantsPct': PropertySchema(
      id: 6,
      name: r'wantsPct',
      type: IsarType.double,
    ),
    r'wantsTotal': PropertySchema(
      id: 7,
      name: r'wantsTotal',
      type: IsarType.double,
    )
  },
  estimateSize: _insightModelEstimateSize,
  serialize: _insightModelSerialize,
  deserialize: _insightModelDeserialize,
  deserializeProp: _insightModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'monthId': IndexSchema(
      id: -6819003626786152132,
      name: r'monthId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'monthId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _insightModelGetId,
  getLinks: _insightModelGetLinks,
  attach: _insightModelAttach,
  version: '3.1.0+1',
);

int _insightModelEstimateSize(
  InsightModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.monthId.length * 3;
  return bytesCount;
}

void _insightModelSerialize(
  InsightModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.healthScore);
  writer.writeString(offsets[1], object.monthId);
  writer.writeDouble(offsets[2], object.needsPct);
  writer.writeDouble(offsets[3], object.needsTotal);
  writer.writeDouble(offsets[4], object.savingsPct);
  writer.writeDouble(offsets[5], object.savingsTotal);
  writer.writeDouble(offsets[6], object.wantsPct);
  writer.writeDouble(offsets[7], object.wantsTotal);
}

InsightModel _insightModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InsightModel(
    healthScore: reader.readLongOrNull(offsets[0]) ?? 0,
    monthId: reader.readString(offsets[1]),
    needsPct: reader.readDoubleOrNull(offsets[2]) ?? 0.0,
    needsTotal: reader.readDoubleOrNull(offsets[3]) ?? 0.0,
    savingsPct: reader.readDoubleOrNull(offsets[4]) ?? 0.0,
    savingsTotal: reader.readDoubleOrNull(offsets[5]) ?? 0.0,
    wantsPct: reader.readDoubleOrNull(offsets[6]) ?? 0.0,
    wantsTotal: reader.readDoubleOrNull(offsets[7]) ?? 0.0,
  );
  object.id = id;
  return object;
}

P _insightModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 3:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 5:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 6:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 7:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _insightModelGetId(InsightModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _insightModelGetLinks(InsightModel object) {
  return [];
}

void _insightModelAttach(
    IsarCollection<dynamic> col, Id id, InsightModel object) {
  object.id = id;
}

extension InsightModelByIndex on IsarCollection<InsightModel> {
  Future<InsightModel?> getByMonthId(String monthId) {
    return getByIndex(r'monthId', [monthId]);
  }

  InsightModel? getByMonthIdSync(String monthId) {
    return getByIndexSync(r'monthId', [monthId]);
  }

  Future<bool> deleteByMonthId(String monthId) {
    return deleteByIndex(r'monthId', [monthId]);
  }

  bool deleteByMonthIdSync(String monthId) {
    return deleteByIndexSync(r'monthId', [monthId]);
  }

  Future<List<InsightModel?>> getAllByMonthId(List<String> monthIdValues) {
    final values = monthIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'monthId', values);
  }

  List<InsightModel?> getAllByMonthIdSync(List<String> monthIdValues) {
    final values = monthIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'monthId', values);
  }

  Future<int> deleteAllByMonthId(List<String> monthIdValues) {
    final values = monthIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'monthId', values);
  }

  int deleteAllByMonthIdSync(List<String> monthIdValues) {
    final values = monthIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'monthId', values);
  }

  Future<Id> putByMonthId(InsightModel object) {
    return putByIndex(r'monthId', object);
  }

  Id putByMonthIdSync(InsightModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'monthId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMonthId(List<InsightModel> objects) {
    return putAllByIndex(r'monthId', objects);
  }

  List<Id> putAllByMonthIdSync(List<InsightModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'monthId', objects, saveLinks: saveLinks);
  }
}

extension InsightModelQueryWhereSort
    on QueryBuilder<InsightModel, InsightModel, QWhere> {
  QueryBuilder<InsightModel, InsightModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InsightModelQueryWhere
    on QueryBuilder<InsightModel, InsightModel, QWhereClause> {
  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> monthIdEqualTo(
      String monthId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'monthId',
        value: [monthId],
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterWhereClause> monthIdNotEqualTo(
      String monthId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthId',
              lower: [],
              upper: [monthId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthId',
              lower: [monthId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthId',
              lower: [monthId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthId',
              lower: [],
              upper: [monthId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InsightModelQueryFilter
    on QueryBuilder<InsightModel, InsightModel, QFilterCondition> {
  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      healthScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthScore',
        value: value,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      healthScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthScore',
        value: value,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      healthScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthScore',
        value: value,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      healthScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monthId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monthId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monthId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monthId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthId',
        value: '',
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      monthIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monthId',
        value: '',
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsPctEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsPctGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'needsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsPctLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'needsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsPctBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'needsPct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'needsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'needsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      needsTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'needsTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsPctEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savingsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsPctGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savingsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsPctLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savingsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsPctBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savingsPct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savingsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savingsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savingsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      savingsTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savingsTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsPctEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wantsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsPctGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wantsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsPctLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wantsPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsPctBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wantsPct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wantsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wantsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wantsTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterFilterCondition>
      wantsTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wantsTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension InsightModelQueryObject
    on QueryBuilder<InsightModel, InsightModel, QFilterCondition> {}

extension InsightModelQueryLinks
    on QueryBuilder<InsightModel, InsightModel, QFilterCondition> {}

extension InsightModelQuerySortBy
    on QueryBuilder<InsightModel, InsightModel, QSortBy> {
  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      sortByHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByMonthId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthId', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByMonthIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthId', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByNeedsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPct', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByNeedsPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPct', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByNeedsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsTotal', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      sortByNeedsTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsTotal', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortBySavingsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsPct', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      sortBySavingsPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsPct', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortBySavingsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsTotal', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      sortBySavingsTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsTotal', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByWantsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsPct', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByWantsPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsPct', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> sortByWantsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsTotal', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      sortByWantsTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsTotal', Sort.desc);
    });
  }
}

extension InsightModelQuerySortThenBy
    on QueryBuilder<InsightModel, InsightModel, QSortThenBy> {
  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      thenByHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByMonthId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthId', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByMonthIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthId', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByNeedsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPct', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByNeedsPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPct', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByNeedsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsTotal', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      thenByNeedsTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsTotal', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenBySavingsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsPct', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      thenBySavingsPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsPct', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenBySavingsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsTotal', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      thenBySavingsTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savingsTotal', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByWantsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsPct', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByWantsPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsPct', Sort.desc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy> thenByWantsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsTotal', Sort.asc);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QAfterSortBy>
      thenByWantsTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wantsTotal', Sort.desc);
    });
  }
}

extension InsightModelQueryWhereDistinct
    on QueryBuilder<InsightModel, InsightModel, QDistinct> {
  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctByHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthScore');
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctByMonthId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctByNeedsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsPct');
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctByNeedsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsTotal');
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctBySavingsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savingsPct');
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctBySavingsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savingsTotal');
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctByWantsPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wantsPct');
    });
  }

  QueryBuilder<InsightModel, InsightModel, QDistinct> distinctByWantsTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wantsTotal');
    });
  }
}

extension InsightModelQueryProperty
    on QueryBuilder<InsightModel, InsightModel, QQueryProperty> {
  QueryBuilder<InsightModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InsightModel, int, QQueryOperations> healthScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthScore');
    });
  }

  QueryBuilder<InsightModel, String, QQueryOperations> monthIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthId');
    });
  }

  QueryBuilder<InsightModel, double, QQueryOperations> needsPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsPct');
    });
  }

  QueryBuilder<InsightModel, double, QQueryOperations> needsTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsTotal');
    });
  }

  QueryBuilder<InsightModel, double, QQueryOperations> savingsPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savingsPct');
    });
  }

  QueryBuilder<InsightModel, double, QQueryOperations> savingsTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savingsTotal');
    });
  }

  QueryBuilder<InsightModel, double, QQueryOperations> wantsPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wantsPct');
    });
  }

  QueryBuilder<InsightModel, double, QQueryOperations> wantsTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wantsTotal');
    });
  }
}
