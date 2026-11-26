// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SyncJobsTable extends SyncJobs with TableInfo<$SyncJobsTable, SyncJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _featureMeta =
      const VerificationMeta('feature');
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
      'feature', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _screenMeta = const VerificationMeta('screen');
  @override
  late final GeneratedColumn<String> screen = GeneratedColumn<String>(
      'screen', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<JobStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<JobStatus>($SyncJobsTable.$converterstatus);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
      'meta', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, feature, screen, status, idempotencyKey, createdAt, updatedAt, meta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<SyncJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feature')) {
      context.handle(_featureMeta,
          feature.isAcceptableOrUnknown(data['feature']!, _featureMeta));
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('screen')) {
      context.handle(_screenMeta,
          screen.isAcceptableOrUnknown(data['screen']!, _screenMeta));
    } else if (isInserting) {
      context.missing(_screenMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('meta')) {
      context.handle(
          _metaMeta, meta.isAcceptableOrUnknown(data['meta']!, _metaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      feature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feature'])!,
      screen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}screen'])!,
      status: $SyncJobsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      meta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta']),
    );
  }

  @override
  $SyncJobsTable createAlias(String alias) {
    return $SyncJobsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobStatus, String, String> $converterstatus =
      const EnumNameConverter<JobStatus>(JobStatus.values);
}

class SyncJob extends DataClass implements Insertable<SyncJob> {
  final int id;

  /// Used to scope queries like "pending jobs for this screen/feature",
  /// so the UI can show e.g. "3 uploads pending" or cancel drafts.
  final String feature;
  final String screen;

  /// pending | running | success | failed | conflict | cancelled
  final JobStatus status;

  /// Sent as a header (e.g. Idempotency-Key) on every step's request so
  /// retries after partial failure don't create duplicate server-side
  /// records or files.
  final String idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Free-form json for whatever the UI wants to show (e.g. a label,
  /// a thumbnail path) without joining into step data.
  final String? meta;
  const SyncJob(
      {required this.id,
      required this.feature,
      required this.screen,
      required this.status,
      required this.idempotencyKey,
      required this.createdAt,
      required this.updatedAt,
      this.meta});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feature'] = Variable<String>(feature);
    map['screen'] = Variable<String>(screen);
    {
      map['status'] =
          Variable<String>($SyncJobsTable.$converterstatus.toSql(status));
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || meta != null) {
      map['meta'] = Variable<String>(meta);
    }
    return map;
  }

  SyncJobsCompanion toCompanion(bool nullToAbsent) {
    return SyncJobsCompanion(
      id: Value(id),
      feature: Value(feature),
      screen: Value(screen),
      status: Value(status),
      idempotencyKey: Value(idempotencyKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      meta: meta == null && nullToAbsent ? const Value.absent() : Value(meta),
    );
  }

  factory SyncJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncJob(
      id: serializer.fromJson<int>(json['id']),
      feature: serializer.fromJson<String>(json['feature']),
      screen: serializer.fromJson<String>(json['screen']),
      status: $SyncJobsTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      meta: serializer.fromJson<String?>(json['meta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feature': serializer.toJson<String>(feature),
      'screen': serializer.toJson<String>(screen),
      'status': serializer
          .toJson<String>($SyncJobsTable.$converterstatus.toJson(status)),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'meta': serializer.toJson<String?>(meta),
    };
  }

  SyncJob copyWith(
          {int? id,
          String? feature,
          String? screen,
          JobStatus? status,
          String? idempotencyKey,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> meta = const Value.absent()}) =>
      SyncJob(
        id: id ?? this.id,
        feature: feature ?? this.feature,
        screen: screen ?? this.screen,
        status: status ?? this.status,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        meta: meta.present ? meta.value : this.meta,
      );
  SyncJob copyWithCompanion(SyncJobsCompanion data) {
    return SyncJob(
      id: data.id.present ? data.id.value : this.id,
      feature: data.feature.present ? data.feature.value : this.feature,
      screen: data.screen.present ? data.screen.value : this.screen,
      status: data.status.present ? data.status.value : this.status,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      meta: data.meta.present ? data.meta.value : this.meta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncJob(')
          ..write('id: $id, ')
          ..write('feature: $feature, ')
          ..write('screen: $screen, ')
          ..write('status: $status, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, feature, screen, status, idempotencyKey, createdAt, updatedAt, meta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncJob &&
          other.id == this.id &&
          other.feature == this.feature &&
          other.screen == this.screen &&
          other.status == this.status &&
          other.idempotencyKey == this.idempotencyKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.meta == this.meta);
}

class SyncJobsCompanion extends UpdateCompanion<SyncJob> {
  final Value<int> id;
  final Value<String> feature;
  final Value<String> screen;
  final Value<JobStatus> status;
  final Value<String> idempotencyKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> meta;
  const SyncJobsCompanion({
    this.id = const Value.absent(),
    this.feature = const Value.absent(),
    this.screen = const Value.absent(),
    this.status = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.meta = const Value.absent(),
  });
  SyncJobsCompanion.insert({
    this.id = const Value.absent(),
    required String feature,
    required String screen,
    required JobStatus status,
    required String idempotencyKey,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.meta = const Value.absent(),
  })  : feature = Value(feature),
        screen = Value(screen),
        status = Value(status),
        idempotencyKey = Value(idempotencyKey);
  static Insertable<SyncJob> custom({
    Expression<int>? id,
    Expression<String>? feature,
    Expression<String>? screen,
    Expression<String>? status,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? meta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feature != null) 'feature': feature,
      if (screen != null) 'screen': screen,
      if (status != null) 'status': status,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (meta != null) 'meta': meta,
    });
  }

  SyncJobsCompanion copyWith(
      {Value<int>? id,
      Value<String>? feature,
      Value<String>? screen,
      Value<JobStatus>? status,
      Value<String>? idempotencyKey,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? meta}) {
    return SyncJobsCompanion(
      id: id ?? this.id,
      feature: feature ?? this.feature,
      screen: screen ?? this.screen,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      meta: meta ?? this.meta,
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
    if (screen.present) {
      map['screen'] = Variable<String>(screen.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($SyncJobsTable.$converterstatus.toSql(status.value));
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncJobsCompanion(')
          ..write('id: $id, ')
          ..write('feature: $feature, ')
          ..write('screen: $screen, ')
          ..write('status: $status, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }
}

class $SyncStepsTable extends SyncSteps
    with TableInfo<$SyncStepsTable, SyncStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
      'job_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sync_jobs (id)'));
  static const VerificationMeta _stepKeyMeta =
      const VerificationMeta('stepKey');
  @override
  late final GeneratedColumn<String> stepKey = GeneratedColumn<String>(
      'step_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskTypeMeta =
      const VerificationMeta('taskType');
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
      'task_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dependsOnMeta =
      const VerificationMeta('dependsOn');
  @override
  late final GeneratedColumn<String> dependsOn = GeneratedColumn<String>(
      'depends_on', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _externalDependsOnMeta =
      const VerificationMeta('externalDependsOn');
  @override
  late final GeneratedColumn<String> externalDependsOn =
      GeneratedColumn<String>('external_depends_on', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _inputMeta = const VerificationMeta('input');
  @override
  late final GeneratedColumn<String> input = GeneratedColumn<String>(
      'input', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _outputMeta = const VerificationMeta('output');
  @override
  late final GeneratedColumn<String> output = GeneratedColumn<String>(
      'output', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<StepStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<StepStatus>($SyncStepsTable.$converterstatus);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _conflictDataMeta =
      const VerificationMeta('conflictData');
  @override
  late final GeneratedColumn<String> conflictData = GeneratedColumn<String>(
      'conflict_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attemptMeta =
      const VerificationMeta('attempt');
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
      'attempt', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sortIndexMeta =
      const VerificationMeta('sortIndex');
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
      'sort_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        jobId,
        stepKey,
        taskType,
        dependsOn,
        externalDependsOn,
        input,
        output,
        status,
        lastError,
        conflictData,
        attempt,
        nextRetryAt,
        completedAt,
        sortIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_steps';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStep> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
          _jobIdMeta, jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta));
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('step_key')) {
      context.handle(_stepKeyMeta,
          stepKey.isAcceptableOrUnknown(data['step_key']!, _stepKeyMeta));
    } else if (isInserting) {
      context.missing(_stepKeyMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(_taskTypeMeta,
          taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta));
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('depends_on')) {
      context.handle(_dependsOnMeta,
          dependsOn.isAcceptableOrUnknown(data['depends_on']!, _dependsOnMeta));
    }
    if (data.containsKey('external_depends_on')) {
      context.handle(
          _externalDependsOnMeta,
          externalDependsOn.isAcceptableOrUnknown(
              data['external_depends_on']!, _externalDependsOnMeta));
    }
    if (data.containsKey('input')) {
      context.handle(
          _inputMeta, input.isAcceptableOrUnknown(data['input']!, _inputMeta));
    } else if (isInserting) {
      context.missing(_inputMeta);
    }
    if (data.containsKey('output')) {
      context.handle(_outputMeta,
          output.isAcceptableOrUnknown(data['output']!, _outputMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('conflict_data')) {
      context.handle(
          _conflictDataMeta,
          conflictData.isAcceptableOrUnknown(
              data['conflict_data']!, _conflictDataMeta));
    }
    if (data.containsKey('attempt')) {
      context.handle(_attemptMeta,
          attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('sort_index')) {
      context.handle(_sortIndexMeta,
          sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStep(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jobId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}job_id'])!,
      stepKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}step_key'])!,
      taskType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_type'])!,
      dependsOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}depends_on'])!,
      externalDependsOn: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}external_depends_on'])!,
      input: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input'])!,
      output: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}output']),
      status: $SyncStepsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      conflictData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conflict_data']),
      attempt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      sortIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_index'])!,
    );
  }

  @override
  $SyncStepsTable createAlias(String alias) {
    return $SyncStepsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StepStatus, String, String> $converterstatus =
      const EnumNameConverter<StepStatus>(StepStatus.values);
}

class SyncStep extends DataClass implements Insertable<SyncStep> {
  final int id;
  final int jobId;

  /// Unique within the job, e.g. "uploadImage". Referenced by dependsOn
  /// and used by downstream steps to look up this step's output.
  final String stepKey;

  /// Registry key mapping to a registered [SyncTaskHandler].
  final String taskType;

  /// JSON array of stepKeys this step depends on within the same job. Empty
  /// array = runnable immediately once cross-job deps are satisfied.
  final String dependsOn;

  /// JSON array of [CrossJobDependency] objects — steps in other jobs/screens
  /// that must succeed first and whose outputs are mapped into this step's input.
  final String externalDependsOn;

  /// JSON: static input known at enqueue time (form fields, file paths...).
  final String input;

  /// JSON: handler's result, populated after a successful run. Consumed by
  /// downstream steps via SyncContext.dependencyOutput(stepKey).
  final String? output;

  /// pending | running | success | failed | conflict | cancelled
  final StepStatus status;
  final String? lastError;

  /// Present only when status == conflict; raw server state for the
  /// resolution UI to inspect.
  final String? conflictData;
  final int attempt;
  final DateTime? nextRetryAt;
  final DateTime? completedAt;

  /// Order hint for stable UI display / tie-breaking when multiple steps
  /// are simultaneously ready. Not used for correctness.
  final int sortIndex;
  const SyncStep(
      {required this.id,
      required this.jobId,
      required this.stepKey,
      required this.taskType,
      required this.dependsOn,
      required this.externalDependsOn,
      required this.input,
      this.output,
      required this.status,
      this.lastError,
      this.conflictData,
      required this.attempt,
      this.nextRetryAt,
      this.completedAt,
      required this.sortIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    map['step_key'] = Variable<String>(stepKey);
    map['task_type'] = Variable<String>(taskType);
    map['depends_on'] = Variable<String>(dependsOn);
    map['external_depends_on'] = Variable<String>(externalDependsOn);
    map['input'] = Variable<String>(input);
    if (!nullToAbsent || output != null) {
      map['output'] = Variable<String>(output);
    }
    {
      map['status'] =
          Variable<String>($SyncStepsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || conflictData != null) {
      map['conflict_data'] = Variable<String>(conflictData);
    }
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  SyncStepsCompanion toCompanion(bool nullToAbsent) {
    return SyncStepsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      stepKey: Value(stepKey),
      taskType: Value(taskType),
      dependsOn: Value(dependsOn),
      externalDependsOn: Value(externalDependsOn),
      input: Value(input),
      output:
          output == null && nullToAbsent ? const Value.absent() : Value(output),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      conflictData: conflictData == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictData),
      attempt: Value(attempt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sortIndex: Value(sortIndex),
    );
  }

  factory SyncStep.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStep(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      stepKey: serializer.fromJson<String>(json['stepKey']),
      taskType: serializer.fromJson<String>(json['taskType']),
      dependsOn: serializer.fromJson<String>(json['dependsOn']),
      externalDependsOn: serializer.fromJson<String>(json['externalDependsOn']),
      input: serializer.fromJson<String>(json['input']),
      output: serializer.fromJson<String?>(json['output']),
      status: $SyncStepsTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      lastError: serializer.fromJson<String?>(json['lastError']),
      conflictData: serializer.fromJson<String?>(json['conflictData']),
      attempt: serializer.fromJson<int>(json['attempt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'stepKey': serializer.toJson<String>(stepKey),
      'taskType': serializer.toJson<String>(taskType),
      'dependsOn': serializer.toJson<String>(dependsOn),
      'externalDependsOn': serializer.toJson<String>(externalDependsOn),
      'input': serializer.toJson<String>(input),
      'output': serializer.toJson<String?>(output),
      'status': serializer
          .toJson<String>($SyncStepsTable.$converterstatus.toJson(status)),
      'lastError': serializer.toJson<String?>(lastError),
      'conflictData': serializer.toJson<String?>(conflictData),
      'attempt': serializer.toJson<int>(attempt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  SyncStep copyWith(
          {int? id,
          int? jobId,
          String? stepKey,
          String? taskType,
          String? dependsOn,
          String? externalDependsOn,
          String? input,
          Value<String?> output = const Value.absent(),
          StepStatus? status,
          Value<String?> lastError = const Value.absent(),
          Value<String?> conflictData = const Value.absent(),
          int? attempt,
          Value<DateTime?> nextRetryAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          int? sortIndex}) =>
      SyncStep(
        id: id ?? this.id,
        jobId: jobId ?? this.jobId,
        stepKey: stepKey ?? this.stepKey,
        taskType: taskType ?? this.taskType,
        dependsOn: dependsOn ?? this.dependsOn,
        externalDependsOn: externalDependsOn ?? this.externalDependsOn,
        input: input ?? this.input,
        output: output.present ? output.value : this.output,
        status: status ?? this.status,
        lastError: lastError.present ? lastError.value : this.lastError,
        conflictData:
            conflictData.present ? conflictData.value : this.conflictData,
        attempt: attempt ?? this.attempt,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        sortIndex: sortIndex ?? this.sortIndex,
      );
  SyncStep copyWithCompanion(SyncStepsCompanion data) {
    return SyncStep(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      stepKey: data.stepKey.present ? data.stepKey.value : this.stepKey,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      dependsOn: data.dependsOn.present ? data.dependsOn.value : this.dependsOn,
      externalDependsOn: data.externalDependsOn.present
          ? data.externalDependsOn.value
          : this.externalDependsOn,
      input: data.input.present ? data.input.value : this.input,
      output: data.output.present ? data.output.value : this.output,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      conflictData: data.conflictData.present
          ? data.conflictData.value
          : this.conflictData,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStep(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('stepKey: $stepKey, ')
          ..write('taskType: $taskType, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('externalDependsOn: $externalDependsOn, ')
          ..write('input: $input, ')
          ..write('output: $output, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('conflictData: $conflictData, ')
          ..write('attempt: $attempt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      jobId,
      stepKey,
      taskType,
      dependsOn,
      externalDependsOn,
      input,
      output,
      status,
      lastError,
      conflictData,
      attempt,
      nextRetryAt,
      completedAt,
      sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStep &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.stepKey == this.stepKey &&
          other.taskType == this.taskType &&
          other.dependsOn == this.dependsOn &&
          other.externalDependsOn == this.externalDependsOn &&
          other.input == this.input &&
          other.output == this.output &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.conflictData == this.conflictData &&
          other.attempt == this.attempt &&
          other.nextRetryAt == this.nextRetryAt &&
          other.completedAt == this.completedAt &&
          other.sortIndex == this.sortIndex);
}

class SyncStepsCompanion extends UpdateCompanion<SyncStep> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<String> stepKey;
  final Value<String> taskType;
  final Value<String> dependsOn;
  final Value<String> externalDependsOn;
  final Value<String> input;
  final Value<String?> output;
  final Value<StepStatus> status;
  final Value<String?> lastError;
  final Value<String?> conflictData;
  final Value<int> attempt;
  final Value<DateTime?> nextRetryAt;
  final Value<DateTime?> completedAt;
  final Value<int> sortIndex;
  const SyncStepsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.stepKey = const Value.absent(),
    this.taskType = const Value.absent(),
    this.dependsOn = const Value.absent(),
    this.externalDependsOn = const Value.absent(),
    this.input = const Value.absent(),
    this.output = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.conflictData = const Value.absent(),
    this.attempt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortIndex = const Value.absent(),
  });
  SyncStepsCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required String stepKey,
    required String taskType,
    this.dependsOn = const Value.absent(),
    this.externalDependsOn = const Value.absent(),
    required String input,
    this.output = const Value.absent(),
    required StepStatus status,
    this.lastError = const Value.absent(),
    this.conflictData = const Value.absent(),
    this.attempt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortIndex = const Value.absent(),
  })  : jobId = Value(jobId),
        stepKey = Value(stepKey),
        taskType = Value(taskType),
        input = Value(input),
        status = Value(status);
  static Insertable<SyncStep> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<String>? stepKey,
    Expression<String>? taskType,
    Expression<String>? dependsOn,
    Expression<String>? externalDependsOn,
    Expression<String>? input,
    Expression<String>? output,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<String>? conflictData,
    Expression<int>? attempt,
    Expression<DateTime>? nextRetryAt,
    Expression<DateTime>? completedAt,
    Expression<int>? sortIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (stepKey != null) 'step_key': stepKey,
      if (taskType != null) 'task_type': taskType,
      if (dependsOn != null) 'depends_on': dependsOn,
      if (externalDependsOn != null) 'external_depends_on': externalDependsOn,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (conflictData != null) 'conflict_data': conflictData,
      if (attempt != null) 'attempt': attempt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (sortIndex != null) 'sort_index': sortIndex,
    });
  }

  SyncStepsCompanion copyWith(
      {Value<int>? id,
      Value<int>? jobId,
      Value<String>? stepKey,
      Value<String>? taskType,
      Value<String>? dependsOn,
      Value<String>? externalDependsOn,
      Value<String>? input,
      Value<String?>? output,
      Value<StepStatus>? status,
      Value<String?>? lastError,
      Value<String?>? conflictData,
      Value<int>? attempt,
      Value<DateTime?>? nextRetryAt,
      Value<DateTime?>? completedAt,
      Value<int>? sortIndex}) {
    return SyncStepsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      stepKey: stepKey ?? this.stepKey,
      taskType: taskType ?? this.taskType,
      dependsOn: dependsOn ?? this.dependsOn,
      externalDependsOn: externalDependsOn ?? this.externalDependsOn,
      input: input ?? this.input,
      output: output ?? this.output,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      conflictData: conflictData ?? this.conflictData,
      attempt: attempt ?? this.attempt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      completedAt: completedAt ?? this.completedAt,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (stepKey.present) {
      map['step_key'] = Variable<String>(stepKey.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (dependsOn.present) {
      map['depends_on'] = Variable<String>(dependsOn.value);
    }
    if (externalDependsOn.present) {
      map['external_depends_on'] = Variable<String>(externalDependsOn.value);
    }
    if (input.present) {
      map['input'] = Variable<String>(input.value);
    }
    if (output.present) {
      map['output'] = Variable<String>(output.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $SyncStepsTable.$converterstatus.toSql(status.value));
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (conflictData.present) {
      map['conflict_data'] = Variable<String>(conflictData.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStepsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('stepKey: $stepKey, ')
          ..write('taskType: $taskType, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('externalDependsOn: $externalDependsOn, ')
          ..write('input: $input, ')
          ..write('output: $output, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('conflictData: $conflictData, ')
          ..write('attempt: $attempt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }
}

abstract class _$SyncDatabase extends GeneratedDatabase {
  _$SyncDatabase(QueryExecutor e) : super(e);
  $SyncDatabaseManager get managers => $SyncDatabaseManager(this);
  late final $SyncJobsTable syncJobs = $SyncJobsTable(this);
  late final $SyncStepsTable syncSteps = $SyncStepsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [syncJobs, syncSteps];
}

typedef $$SyncJobsTableCreateCompanionBuilder = SyncJobsCompanion Function({
  Value<int> id,
  required String feature,
  required String screen,
  required JobStatus status,
  required String idempotencyKey,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> meta,
});
typedef $$SyncJobsTableUpdateCompanionBuilder = SyncJobsCompanion Function({
  Value<int> id,
  Value<String> feature,
  Value<String> screen,
  Value<JobStatus> status,
  Value<String> idempotencyKey,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> meta,
});

final class $$SyncJobsTableReferences
    extends BaseReferences<_$SyncDatabase, $SyncJobsTable, SyncJob> {
  $$SyncJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SyncStepsTable, List<SyncStep>>
      _syncStepsRefsTable(_$SyncDatabase db) =>
          MultiTypedResultKey.fromTable(db.syncSteps,
              aliasName: 'sync_jobs__id__sync_steps__job_id');

  $$SyncStepsTableProcessedTableManager get syncStepsRefs {
    final manager = $$SyncStepsTableTableManager($_db, $_db.syncSteps)
        .filter((f) => f.jobId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncStepsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SyncJobsTableFilterComposer
    extends Composer<_$SyncDatabase, $SyncJobsTable> {
  $$SyncJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get screen => $composableBuilder(
      column: $table.screen, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<JobStatus, JobStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meta => $composableBuilder(
      column: $table.meta, builder: (column) => ColumnFilters(column));

  Expression<bool> syncStepsRefs(
      Expression<bool> Function($$SyncStepsTableFilterComposer f) f) {
    final $$SyncStepsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncSteps,
        getReferencedColumn: (t) => t.jobId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncStepsTableFilterComposer(
              $db: $db,
              $table: $db.syncSteps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncJobsTableOrderingComposer
    extends Composer<_$SyncDatabase, $SyncJobsTable> {
  $$SyncJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get screen => $composableBuilder(
      column: $table.screen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meta => $composableBuilder(
      column: $table.meta, builder: (column) => ColumnOrderings(column));
}

class $$SyncJobsTableAnnotationComposer
    extends Composer<_$SyncDatabase, $SyncJobsTable> {
  $$SyncJobsTableAnnotationComposer({
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

  GeneratedColumn<String> get screen =>
      $composableBuilder(column: $table.screen, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  Expression<T> syncStepsRefs<T extends Object>(
      Expression<T> Function($$SyncStepsTableAnnotationComposer a) f) {
    final $$SyncStepsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.syncSteps,
        getReferencedColumn: (t) => t.jobId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncStepsTableAnnotationComposer(
              $db: $db,
              $table: $db.syncSteps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SyncJobsTableTableManager extends RootTableManager<
    _$SyncDatabase,
    $SyncJobsTable,
    SyncJob,
    $$SyncJobsTableFilterComposer,
    $$SyncJobsTableOrderingComposer,
    $$SyncJobsTableAnnotationComposer,
    $$SyncJobsTableCreateCompanionBuilder,
    $$SyncJobsTableUpdateCompanionBuilder,
    (SyncJob, $$SyncJobsTableReferences),
    SyncJob,
    PrefetchHooks Function({bool syncStepsRefs})> {
  $$SyncJobsTableTableManager(_$SyncDatabase db, $SyncJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> feature = const Value.absent(),
            Value<String> screen = const Value.absent(),
            Value<JobStatus> status = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> meta = const Value.absent(),
          }) =>
              SyncJobsCompanion(
            id: id,
            feature: feature,
            screen: screen,
            status: status,
            idempotencyKey: idempotencyKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            meta: meta,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String feature,
            required String screen,
            required JobStatus status,
            required String idempotencyKey,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> meta = const Value.absent(),
          }) =>
              SyncJobsCompanion.insert(
            id: id,
            feature: feature,
            screen: screen,
            status: status,
            idempotencyKey: idempotencyKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            meta: meta,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SyncJobsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({syncStepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (syncStepsRefs) db.syncSteps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (syncStepsRefs)
                    await $_getPrefetchedData<SyncJob, $SyncJobsTable,
                            SyncStep>(
                        currentTable: table,
                        referencedTable:
                            $$SyncJobsTableReferences._syncStepsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SyncJobsTableReferences(db, table, p0)
                                .syncStepsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.jobId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SyncJobsTableProcessedTableManager = ProcessedTableManager<
    _$SyncDatabase,
    $SyncJobsTable,
    SyncJob,
    $$SyncJobsTableFilterComposer,
    $$SyncJobsTableOrderingComposer,
    $$SyncJobsTableAnnotationComposer,
    $$SyncJobsTableCreateCompanionBuilder,
    $$SyncJobsTableUpdateCompanionBuilder,
    (SyncJob, $$SyncJobsTableReferences),
    SyncJob,
    PrefetchHooks Function({bool syncStepsRefs})>;
typedef $$SyncStepsTableCreateCompanionBuilder = SyncStepsCompanion Function({
  Value<int> id,
  required int jobId,
  required String stepKey,
  required String taskType,
  Value<String> dependsOn,
  Value<String> externalDependsOn,
  required String input,
  Value<String?> output,
  required StepStatus status,
  Value<String?> lastError,
  Value<String?> conflictData,
  Value<int> attempt,
  Value<DateTime?> nextRetryAt,
  Value<DateTime?> completedAt,
  Value<int> sortIndex,
});
typedef $$SyncStepsTableUpdateCompanionBuilder = SyncStepsCompanion Function({
  Value<int> id,
  Value<int> jobId,
  Value<String> stepKey,
  Value<String> taskType,
  Value<String> dependsOn,
  Value<String> externalDependsOn,
  Value<String> input,
  Value<String?> output,
  Value<StepStatus> status,
  Value<String?> lastError,
  Value<String?> conflictData,
  Value<int> attempt,
  Value<DateTime?> nextRetryAt,
  Value<DateTime?> completedAt,
  Value<int> sortIndex,
});

final class $$SyncStepsTableReferences
    extends BaseReferences<_$SyncDatabase, $SyncStepsTable, SyncStep> {
  $$SyncStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SyncJobsTable _jobIdTable(_$SyncDatabase db) =>
      db.syncJobs.createAlias('sync_steps__job_id__sync_jobs__id');

  $$SyncJobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<int>('job_id')!;

    final manager = $$SyncJobsTableTableManager($_db, $_db.syncJobs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SyncStepsTableFilterComposer
    extends Composer<_$SyncDatabase, $SyncStepsTable> {
  $$SyncStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stepKey => $composableBuilder(
      column: $table.stepKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskType => $composableBuilder(
      column: $table.taskType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependsOn => $composableBuilder(
      column: $table.dependsOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalDependsOn => $composableBuilder(
      column: $table.externalDependsOn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get input => $composableBuilder(
      column: $table.input, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get output => $composableBuilder(
      column: $table.output, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<StepStatus, StepStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conflictData => $composableBuilder(
      column: $table.conflictData, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortIndex => $composableBuilder(
      column: $table.sortIndex, builder: (column) => ColumnFilters(column));

  $$SyncJobsTableFilterComposer get jobId {
    final $$SyncJobsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.jobId,
        referencedTable: $db.syncJobs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncJobsTableFilterComposer(
              $db: $db,
              $table: $db.syncJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncStepsTableOrderingComposer
    extends Composer<_$SyncDatabase, $SyncStepsTable> {
  $$SyncStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stepKey => $composableBuilder(
      column: $table.stepKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskType => $composableBuilder(
      column: $table.taskType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependsOn => $composableBuilder(
      column: $table.dependsOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalDependsOn => $composableBuilder(
      column: $table.externalDependsOn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get input => $composableBuilder(
      column: $table.input, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get output => $composableBuilder(
      column: $table.output, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conflictData => $composableBuilder(
      column: $table.conflictData,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortIndex => $composableBuilder(
      column: $table.sortIndex, builder: (column) => ColumnOrderings(column));

  $$SyncJobsTableOrderingComposer get jobId {
    final $$SyncJobsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.jobId,
        referencedTable: $db.syncJobs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncJobsTableOrderingComposer(
              $db: $db,
              $table: $db.syncJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncStepsTableAnnotationComposer
    extends Composer<_$SyncDatabase, $SyncStepsTable> {
  $$SyncStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stepKey =>
      $composableBuilder(column: $table.stepKey, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get dependsOn =>
      $composableBuilder(column: $table.dependsOn, builder: (column) => column);

  GeneratedColumn<String> get externalDependsOn => $composableBuilder(
      column: $table.externalDependsOn, builder: (column) => column);

  GeneratedColumn<String> get input =>
      $composableBuilder(column: $table.input, builder: (column) => column);

  GeneratedColumn<String> get output =>
      $composableBuilder(column: $table.output, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StepStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get conflictData => $composableBuilder(
      column: $table.conflictData, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$SyncJobsTableAnnotationComposer get jobId {
    final $$SyncJobsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.jobId,
        referencedTable: $db.syncJobs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SyncJobsTableAnnotationComposer(
              $db: $db,
              $table: $db.syncJobs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SyncStepsTableTableManager extends RootTableManager<
    _$SyncDatabase,
    $SyncStepsTable,
    SyncStep,
    $$SyncStepsTableFilterComposer,
    $$SyncStepsTableOrderingComposer,
    $$SyncStepsTableAnnotationComposer,
    $$SyncStepsTableCreateCompanionBuilder,
    $$SyncStepsTableUpdateCompanionBuilder,
    (SyncStep, $$SyncStepsTableReferences),
    SyncStep,
    PrefetchHooks Function({bool jobId})> {
  $$SyncStepsTableTableManager(_$SyncDatabase db, $SyncStepsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> jobId = const Value.absent(),
            Value<String> stepKey = const Value.absent(),
            Value<String> taskType = const Value.absent(),
            Value<String> dependsOn = const Value.absent(),
            Value<String> externalDependsOn = const Value.absent(),
            Value<String> input = const Value.absent(),
            Value<String?> output = const Value.absent(),
            Value<StepStatus> status = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String?> conflictData = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> sortIndex = const Value.absent(),
          }) =>
              SyncStepsCompanion(
            id: id,
            jobId: jobId,
            stepKey: stepKey,
            taskType: taskType,
            dependsOn: dependsOn,
            externalDependsOn: externalDependsOn,
            input: input,
            output: output,
            status: status,
            lastError: lastError,
            conflictData: conflictData,
            attempt: attempt,
            nextRetryAt: nextRetryAt,
            completedAt: completedAt,
            sortIndex: sortIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int jobId,
            required String stepKey,
            required String taskType,
            Value<String> dependsOn = const Value.absent(),
            Value<String> externalDependsOn = const Value.absent(),
            required String input,
            Value<String?> output = const Value.absent(),
            required StepStatus status,
            Value<String?> lastError = const Value.absent(),
            Value<String?> conflictData = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> sortIndex = const Value.absent(),
          }) =>
              SyncStepsCompanion.insert(
            id: id,
            jobId: jobId,
            stepKey: stepKey,
            taskType: taskType,
            dependsOn: dependsOn,
            externalDependsOn: externalDependsOn,
            input: input,
            output: output,
            status: status,
            lastError: lastError,
            conflictData: conflictData,
            attempt: attempt,
            nextRetryAt: nextRetryAt,
            completedAt: completedAt,
            sortIndex: sortIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SyncStepsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (jobId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.jobId,
                    referencedTable: $$SyncStepsTableReferences._jobIdTable(db),
                    referencedColumn:
                        $$SyncStepsTableReferences._jobIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SyncStepsTableProcessedTableManager = ProcessedTableManager<
    _$SyncDatabase,
    $SyncStepsTable,
    SyncStep,
    $$SyncStepsTableFilterComposer,
    $$SyncStepsTableOrderingComposer,
    $$SyncStepsTableAnnotationComposer,
    $$SyncStepsTableCreateCompanionBuilder,
    $$SyncStepsTableUpdateCompanionBuilder,
    (SyncStep, $$SyncStepsTableReferences),
    SyncStep,
    PrefetchHooks Function({bool jobId})>;

class $SyncDatabaseManager {
  final _$SyncDatabase _db;
  $SyncDatabaseManager(this._db);
  $$SyncJobsTableTableManager get syncJobs =>
      $$SyncJobsTableTableManager(_db, _db.syncJobs);
  $$SyncStepsTableTableManager get syncSteps =>
      $$SyncStepsTableTableManager(_db, _db.syncSteps);
}
