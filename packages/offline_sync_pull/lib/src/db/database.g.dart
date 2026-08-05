// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PullCheckpointsTable extends PullCheckpoints
    with TableInfo<$PullCheckpointsTable, PullCheckpoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PullCheckpointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _featureMeta = const VerificationMeta(
    'feature',
  );
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
    'feature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepKeyMeta = const VerificationMeta(
    'stepKey',
  );
  @override
  late final GeneratedColumn<String> stepKey = GeneratedColumn<String>(
    'step_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pageSizeMeta = const VerificationMeta(
    'pageSize',
  );
  @override
  late final GeneratedColumn<int> pageSize = GeneratedColumn<int>(
    'page_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PullStepStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PullStepStatus>($PullCheckpointsTable.$converterstatus);
  static const VerificationMeta _hasMoreMeta = const VerificationMeta(
    'hasMore',
  );
  @override
  late final GeneratedColumn<bool> hasMore = GeneratedColumn<bool>(
    'has_more',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_more" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastRunAtMeta = const VerificationMeta(
    'lastRunAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRunAt = GeneratedColumn<DateTime>(
    'last_run_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feature,
    stepKey,
    page,
    pageSize,
    status,
    hasMore,
    lastRunAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pull_checkpoints';
  @override
  VerificationContext validateIntegrity(
    Insertable<PullCheckpoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feature')) {
      context.handle(
        _featureMeta,
        feature.isAcceptableOrUnknown(data['feature']!, _featureMeta),
      );
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('step_key')) {
      context.handle(
        _stepKeyMeta,
        stepKey.isAcceptableOrUnknown(data['step_key']!, _stepKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stepKeyMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('page_size')) {
      context.handle(
        _pageSizeMeta,
        pageSize.isAcceptableOrUnknown(data['page_size']!, _pageSizeMeta),
      );
    }
    if (data.containsKey('has_more')) {
      context.handle(
        _hasMoreMeta,
        hasMore.isAcceptableOrUnknown(data['has_more']!, _hasMoreMeta),
      );
    }
    if (data.containsKey('last_run_at')) {
      context.handle(
        _lastRunAtMeta,
        lastRunAt.isAcceptableOrUnknown(data['last_run_at']!, _lastRunAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PullCheckpoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PullCheckpoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      feature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature'],
      )!,
      stepKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_key'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      pageSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_size'],
      )!,
      status: $PullCheckpointsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      hasMore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_more'],
      )!,
      lastRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_run_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PullCheckpointsTable createAlias(String alias) {
    return $PullCheckpointsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PullStepStatus, String, String> $converterstatus =
      const EnumNameConverter<PullStepStatus>(PullStepStatus.values);
}

class PullCheckpoint extends DataClass implements Insertable<PullCheckpoint> {
  final int id;
  final String feature;
  final String stepKey;
  final int page;
  final int pageSize;
  final PullStepStatus status;
  final bool hasMore;
  final DateTime? lastRunAt;
  final String? lastError;
  const PullCheckpoint({
    required this.id,
    required this.feature,
    required this.stepKey,
    required this.page,
    required this.pageSize,
    required this.status,
    required this.hasMore,
    this.lastRunAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feature'] = Variable<String>(feature);
    map['step_key'] = Variable<String>(stepKey);
    map['page'] = Variable<int>(page);
    map['page_size'] = Variable<int>(pageSize);
    {
      map['status'] = Variable<String>(
        $PullCheckpointsTable.$converterstatus.toSql(status),
      );
    }
    map['has_more'] = Variable<bool>(hasMore);
    if (!nullToAbsent || lastRunAt != null) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PullCheckpointsCompanion toCompanion(bool nullToAbsent) {
    return PullCheckpointsCompanion(
      id: Value(id),
      feature: Value(feature),
      stepKey: Value(stepKey),
      page: Value(page),
      pageSize: Value(pageSize),
      status: Value(status),
      hasMore: Value(hasMore),
      lastRunAt: lastRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRunAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PullCheckpoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PullCheckpoint(
      id: serializer.fromJson<int>(json['id']),
      feature: serializer.fromJson<String>(json['feature']),
      stepKey: serializer.fromJson<String>(json['stepKey']),
      page: serializer.fromJson<int>(json['page']),
      pageSize: serializer.fromJson<int>(json['pageSize']),
      status: $PullCheckpointsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      hasMore: serializer.fromJson<bool>(json['hasMore']),
      lastRunAt: serializer.fromJson<DateTime?>(json['lastRunAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feature': serializer.toJson<String>(feature),
      'stepKey': serializer.toJson<String>(stepKey),
      'page': serializer.toJson<int>(page),
      'pageSize': serializer.toJson<int>(pageSize),
      'status': serializer.toJson<String>(
        $PullCheckpointsTable.$converterstatus.toJson(status),
      ),
      'hasMore': serializer.toJson<bool>(hasMore),
      'lastRunAt': serializer.toJson<DateTime?>(lastRunAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PullCheckpoint copyWith({
    int? id,
    String? feature,
    String? stepKey,
    int? page,
    int? pageSize,
    PullStepStatus? status,
    bool? hasMore,
    Value<DateTime?> lastRunAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => PullCheckpoint(
    id: id ?? this.id,
    feature: feature ?? this.feature,
    stepKey: stepKey ?? this.stepKey,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    status: status ?? this.status,
    hasMore: hasMore ?? this.hasMore,
    lastRunAt: lastRunAt.present ? lastRunAt.value : this.lastRunAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PullCheckpoint copyWithCompanion(PullCheckpointsCompanion data) {
    return PullCheckpoint(
      id: data.id.present ? data.id.value : this.id,
      feature: data.feature.present ? data.feature.value : this.feature,
      stepKey: data.stepKey.present ? data.stepKey.value : this.stepKey,
      page: data.page.present ? data.page.value : this.page,
      pageSize: data.pageSize.present ? data.pageSize.value : this.pageSize,
      status: data.status.present ? data.status.value : this.status,
      hasMore: data.hasMore.present ? data.hasMore.value : this.hasMore,
      lastRunAt: data.lastRunAt.present ? data.lastRunAt.value : this.lastRunAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PullCheckpoint(')
          ..write('id: $id, ')
          ..write('feature: $feature, ')
          ..write('stepKey: $stepKey, ')
          ..write('page: $page, ')
          ..write('pageSize: $pageSize, ')
          ..write('status: $status, ')
          ..write('hasMore: $hasMore, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    feature,
    stepKey,
    page,
    pageSize,
    status,
    hasMore,
    lastRunAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PullCheckpoint &&
          other.id == this.id &&
          other.feature == this.feature &&
          other.stepKey == this.stepKey &&
          other.page == this.page &&
          other.pageSize == this.pageSize &&
          other.status == this.status &&
          other.hasMore == this.hasMore &&
          other.lastRunAt == this.lastRunAt &&
          other.lastError == this.lastError);
}

class PullCheckpointsCompanion extends UpdateCompanion<PullCheckpoint> {
  final Value<int> id;
  final Value<String> feature;
  final Value<String> stepKey;
  final Value<int> page;
  final Value<int> pageSize;
  final Value<PullStepStatus> status;
  final Value<bool> hasMore;
  final Value<DateTime?> lastRunAt;
  final Value<String?> lastError;
  const PullCheckpointsCompanion({
    this.id = const Value.absent(),
    this.feature = const Value.absent(),
    this.stepKey = const Value.absent(),
    this.page = const Value.absent(),
    this.pageSize = const Value.absent(),
    this.status = const Value.absent(),
    this.hasMore = const Value.absent(),
    this.lastRunAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PullCheckpointsCompanion.insert({
    this.id = const Value.absent(),
    required String feature,
    required String stepKey,
    this.page = const Value.absent(),
    this.pageSize = const Value.absent(),
    required PullStepStatus status,
    this.hasMore = const Value.absent(),
    this.lastRunAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : feature = Value(feature),
       stepKey = Value(stepKey),
       status = Value(status);
  static Insertable<PullCheckpoint> custom({
    Expression<int>? id,
    Expression<String>? feature,
    Expression<String>? stepKey,
    Expression<int>? page,
    Expression<int>? pageSize,
    Expression<String>? status,
    Expression<bool>? hasMore,
    Expression<DateTime>? lastRunAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feature != null) 'feature': feature,
      if (stepKey != null) 'step_key': stepKey,
      if (page != null) 'page': page,
      if (pageSize != null) 'page_size': pageSize,
      if (status != null) 'status': status,
      if (hasMore != null) 'has_more': hasMore,
      if (lastRunAt != null) 'last_run_at': lastRunAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PullCheckpointsCompanion copyWith({
    Value<int>? id,
    Value<String>? feature,
    Value<String>? stepKey,
    Value<int>? page,
    Value<int>? pageSize,
    Value<PullStepStatus>? status,
    Value<bool>? hasMore,
    Value<DateTime?>? lastRunAt,
    Value<String?>? lastError,
  }) {
    return PullCheckpointsCompanion(
      id: id ?? this.id,
      feature: feature ?? this.feature,
      stepKey: stepKey ?? this.stepKey,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (stepKey.present) {
      map['step_key'] = Variable<String>(stepKey.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (pageSize.present) {
      map['page_size'] = Variable<int>(pageSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PullCheckpointsTable.$converterstatus.toSql(status.value),
      );
    }
    if (hasMore.present) {
      map['has_more'] = Variable<bool>(hasMore.value);
    }
    if (lastRunAt.present) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PullCheckpointsCompanion(')
          ..write('id: $id, ')
          ..write('feature: $feature, ')
          ..write('stepKey: $stepKey, ')
          ..write('page: $page, ')
          ..write('pageSize: $pageSize, ')
          ..write('status: $status, ')
          ..write('hasMore: $hasMore, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$PullDatabase extends GeneratedDatabase {
  _$PullDatabase(QueryExecutor e) : super(e);
  $PullDatabaseManager get managers => $PullDatabaseManager(this);
  late final $PullCheckpointsTable pullCheckpoints = $PullCheckpointsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pullCheckpoints];
}

typedef $$PullCheckpointsTableCreateCompanionBuilder =
    PullCheckpointsCompanion Function({
      Value<int> id,
      required String feature,
      required String stepKey,
      Value<int> page,
      Value<int> pageSize,
      required PullStepStatus status,
      Value<bool> hasMore,
      Value<DateTime?> lastRunAt,
      Value<String?> lastError,
    });
typedef $$PullCheckpointsTableUpdateCompanionBuilder =
    PullCheckpointsCompanion Function({
      Value<int> id,
      Value<String> feature,
      Value<String> stepKey,
      Value<int> page,
      Value<int> pageSize,
      Value<PullStepStatus> status,
      Value<bool> hasMore,
      Value<DateTime?> lastRunAt,
      Value<String?> lastError,
    });

class $$PullCheckpointsTableFilterComposer
    extends Composer<_$PullDatabase, $PullCheckpointsTable> {
  $$PullCheckpointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepKey => $composableBuilder(
    column: $table.stepKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageSize => $composableBuilder(
    column: $table.pageSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PullStepStatus, PullStepStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get hasMore => $composableBuilder(
    column: $table.hasMore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PullCheckpointsTableOrderingComposer
    extends Composer<_$PullDatabase, $PullCheckpointsTable> {
  $$PullCheckpointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepKey => $composableBuilder(
    column: $table.stepKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageSize => $composableBuilder(
    column: $table.pageSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMore => $composableBuilder(
    column: $table.hasMore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PullCheckpointsTableAnnotationComposer
    extends Composer<_$PullDatabase, $PullCheckpointsTable> {
  $$PullCheckpointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<String> get stepKey =>
      $composableBuilder(column: $table.stepKey, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get pageSize =>
      $composableBuilder(column: $table.pageSize, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PullStepStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get hasMore =>
      $composableBuilder(column: $table.hasMore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRunAt =>
      $composableBuilder(column: $table.lastRunAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PullCheckpointsTableTableManager
    extends
        RootTableManager<
          _$PullDatabase,
          $PullCheckpointsTable,
          PullCheckpoint,
          $$PullCheckpointsTableFilterComposer,
          $$PullCheckpointsTableOrderingComposer,
          $$PullCheckpointsTableAnnotationComposer,
          $$PullCheckpointsTableCreateCompanionBuilder,
          $$PullCheckpointsTableUpdateCompanionBuilder,
          (
            PullCheckpoint,
            BaseReferences<
              _$PullDatabase,
              $PullCheckpointsTable,
              PullCheckpoint
            >,
          ),
          PullCheckpoint,
          PrefetchHooks Function()
        > {
  $$PullCheckpointsTableTableManager(
    _$PullDatabase db,
    $PullCheckpointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PullCheckpointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PullCheckpointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PullCheckpointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> feature = const Value.absent(),
                Value<String> stepKey = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> pageSize = const Value.absent(),
                Value<PullStepStatus> status = const Value.absent(),
                Value<bool> hasMore = const Value.absent(),
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PullCheckpointsCompanion(
                id: id,
                feature: feature,
                stepKey: stepKey,
                page: page,
                pageSize: pageSize,
                status: status,
                hasMore: hasMore,
                lastRunAt: lastRunAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String feature,
                required String stepKey,
                Value<int> page = const Value.absent(),
                Value<int> pageSize = const Value.absent(),
                required PullStepStatus status,
                Value<bool> hasMore = const Value.absent(),
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => PullCheckpointsCompanion.insert(
                id: id,
                feature: feature,
                stepKey: stepKey,
                page: page,
                pageSize: pageSize,
                status: status,
                hasMore: hasMore,
                lastRunAt: lastRunAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PullCheckpointsTableProcessedTableManager =
    ProcessedTableManager<
      _$PullDatabase,
      $PullCheckpointsTable,
      PullCheckpoint,
      $$PullCheckpointsTableFilterComposer,
      $$PullCheckpointsTableOrderingComposer,
      $$PullCheckpointsTableAnnotationComposer,
      $$PullCheckpointsTableCreateCompanionBuilder,
      $$PullCheckpointsTableUpdateCompanionBuilder,
      (
        PullCheckpoint,
        BaseReferences<_$PullDatabase, $PullCheckpointsTable, PullCheckpoint>,
      ),
      PullCheckpoint,
      PrefetchHooks Function()
    >;

class $PullDatabaseManager {
  final _$PullDatabase _db;
  $PullDatabaseManager(this._db);
  $$PullCheckpointsTableTableManager get pullCheckpoints =>
      $$PullCheckpointsTableTableManager(_db, _db.pullCheckpoints);
}
