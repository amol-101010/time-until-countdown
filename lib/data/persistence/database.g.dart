// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, EventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
  );
  static const VerificationMeta _granularityMeta = const VerificationMeta(
    'granularity',
  );
  @override
  late final GeneratedColumn<String> granularity = GeneratedColumn<String>(
    'granularity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shapeMeta = const VerificationMeta('shape');
  @override
  late final GeneratedColumn<String> shape = GeneratedColumn<String>(
    'shape',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceFrequencyMeta =
      const VerificationMeta('recurrenceFrequency');
  @override
  late final GeneratedColumn<String> recurrenceFrequency =
      GeneratedColumn<String>(
        'recurrence_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceDaysOfWeekMeta =
      const VerificationMeta('recurrenceDaysOfWeek');
  @override
  late final GeneratedColumn<String> recurrenceDaysOfWeek =
      GeneratedColumn<String>(
        'recurrence_days_of_week',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceCycleStartMinutesMeta =
      const VerificationMeta('recurrenceCycleStartMinutes');
  @override
  late final GeneratedColumn<int> recurrenceCycleStartMinutes =
      GeneratedColumn<int>(
        'recurrence_cycle_start_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurrenceCycleEndMinutesMeta =
      const VerificationMeta('recurrenceCycleEndMinutes');
  @override
  late final GeneratedColumn<int> recurrenceCycleEndMinutes =
      GeneratedColumn<int>(
        'recurrence_cycle_end_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderTimeMinutesMeta =
      const VerificationMeta('reminderTimeMinutes');
  @override
  late final GeneratedColumn<int> reminderTimeMinutes = GeneratedColumn<int>(
    'reminder_time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderDateTimeMeta = const VerificationMeta(
    'reminderDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> reminderDateTime =
      GeneratedColumn<DateTime>(
        'reminder_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderRepeatFrequencyMeta =
      const VerificationMeta('reminderRepeatFrequency');
  @override
  late final GeneratedColumn<String> reminderRepeatFrequency =
      GeneratedColumn<String>(
        'reminder_repeat_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    colorValue,
    iconCodePoint,
    isBuiltIn,
    isRecurring,
    granularity,
    shape,
    recurrenceFrequency,
    recurrenceDaysOfWeek,
    recurrenceCycleStartMinutes,
    recurrenceCycleEndMinutes,
    startDate,
    endDate,
    updatedAt,
    deletedAt,
    remindersEnabled,
    reminderTimeMinutes,
    reminderDateTime,
    reminderRepeatFrequency,
    tag,
    groupName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isRecurringMeta);
    }
    if (data.containsKey('granularity')) {
      context.handle(
        _granularityMeta,
        granularity.isAcceptableOrUnknown(
          data['granularity']!,
          _granularityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_granularityMeta);
    }
    if (data.containsKey('shape')) {
      context.handle(
        _shapeMeta,
        shape.isAcceptableOrUnknown(data['shape']!, _shapeMeta),
      );
    } else if (isInserting) {
      context.missing(_shapeMeta);
    }
    if (data.containsKey('recurrence_frequency')) {
      context.handle(
        _recurrenceFrequencyMeta,
        recurrenceFrequency.isAcceptableOrUnknown(
          data['recurrence_frequency']!,
          _recurrenceFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_days_of_week')) {
      context.handle(
        _recurrenceDaysOfWeekMeta,
        recurrenceDaysOfWeek.isAcceptableOrUnknown(
          data['recurrence_days_of_week']!,
          _recurrenceDaysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_cycle_start_minutes')) {
      context.handle(
        _recurrenceCycleStartMinutesMeta,
        recurrenceCycleStartMinutes.isAcceptableOrUnknown(
          data['recurrence_cycle_start_minutes']!,
          _recurrenceCycleStartMinutesMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_cycle_end_minutes')) {
      context.handle(
        _recurrenceCycleEndMinutesMeta,
        recurrenceCycleEndMinutes.isAcceptableOrUnknown(
          data['recurrence_cycle_end_minutes']!,
          _recurrenceCycleEndMinutesMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time_minutes')) {
      context.handle(
        _reminderTimeMinutesMeta,
        reminderTimeMinutes.isAcceptableOrUnknown(
          data['reminder_time_minutes']!,
          _reminderTimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reminder_date_time')) {
      context.handle(
        _reminderDateTimeMeta,
        reminderDateTime.isAcceptableOrUnknown(
          data['reminder_date_time']!,
          _reminderDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_repeat_frequency')) {
      context.handle(
        _reminderRepeatFrequencyMeta,
        reminderRepeatFrequency.isAcceptableOrUnknown(
          data['reminder_repeat_frequency']!,
          _reminderRepeatFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      ),
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      granularity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}granularity'],
      )!,
      shape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shape'],
      )!,
      recurrenceFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_frequency'],
      ),
      recurrenceDaysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_days_of_week'],
      ),
      recurrenceCycleStartMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_cycle_start_minutes'],
      ),
      recurrenceCycleEndMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_cycle_end_minutes'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      reminderTimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time_minutes'],
      ),
      reminderDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_date_time'],
      ),
      reminderRepeatFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_repeat_frequency'],
      ),
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      ),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class EventRow extends DataClass implements Insertable<EventRow> {
  final String id;
  final String title;
  final int colorValue;
  final int? iconCodePoint;
  final bool isBuiltIn;
  final bool isRecurring;
  final String granularity;
  final String shape;
  final String? recurrenceFrequency;
  final String? recurrenceDaysOfWeek;
  final int? recurrenceCycleStartMinutes;
  final int? recurrenceCycleEndMinutes;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool remindersEnabled;
  final int? reminderTimeMinutes;
  final DateTime? reminderDateTime;
  final String? reminderRepeatFrequency;
  final String? tag;
  final String? groupName;
  const EventRow({
    required this.id,
    required this.title,
    required this.colorValue,
    this.iconCodePoint,
    required this.isBuiltIn,
    required this.isRecurring,
    required this.granularity,
    required this.shape,
    this.recurrenceFrequency,
    this.recurrenceDaysOfWeek,
    this.recurrenceCycleStartMinutes,
    this.recurrenceCycleEndMinutes,
    this.startDate,
    this.endDate,
    required this.updatedAt,
    this.deletedAt,
    required this.remindersEnabled,
    this.reminderTimeMinutes,
    this.reminderDateTime,
    this.reminderRepeatFrequency,
    this.tag,
    this.groupName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['color_value'] = Variable<int>(colorValue);
    if (!nullToAbsent || iconCodePoint != null) {
      map['icon_code_point'] = Variable<int>(iconCodePoint);
    }
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['is_recurring'] = Variable<bool>(isRecurring);
    map['granularity'] = Variable<String>(granularity);
    map['shape'] = Variable<String>(shape);
    if (!nullToAbsent || recurrenceFrequency != null) {
      map['recurrence_frequency'] = Variable<String>(recurrenceFrequency);
    }
    if (!nullToAbsent || recurrenceDaysOfWeek != null) {
      map['recurrence_days_of_week'] = Variable<String>(recurrenceDaysOfWeek);
    }
    if (!nullToAbsent || recurrenceCycleStartMinutes != null) {
      map['recurrence_cycle_start_minutes'] = Variable<int>(
        recurrenceCycleStartMinutes,
      );
    }
    if (!nullToAbsent || recurrenceCycleEndMinutes != null) {
      map['recurrence_cycle_end_minutes'] = Variable<int>(
        recurrenceCycleEndMinutes,
      );
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    if (!nullToAbsent || reminderTimeMinutes != null) {
      map['reminder_time_minutes'] = Variable<int>(reminderTimeMinutes);
    }
    if (!nullToAbsent || reminderDateTime != null) {
      map['reminder_date_time'] = Variable<DateTime>(reminderDateTime);
    }
    if (!nullToAbsent || reminderRepeatFrequency != null) {
      map['reminder_repeat_frequency'] = Variable<String>(
        reminderRepeatFrequency,
      );
    }
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      colorValue: Value(colorValue),
      iconCodePoint: iconCodePoint == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCodePoint),
      isBuiltIn: Value(isBuiltIn),
      isRecurring: Value(isRecurring),
      granularity: Value(granularity),
      shape: Value(shape),
      recurrenceFrequency: recurrenceFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceFrequency),
      recurrenceDaysOfWeek: recurrenceDaysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceDaysOfWeek),
      recurrenceCycleStartMinutes:
          recurrenceCycleStartMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceCycleStartMinutes),
      recurrenceCycleEndMinutes:
          recurrenceCycleEndMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceCycleEndMinutes),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      remindersEnabled: Value(remindersEnabled),
      reminderTimeMinutes: reminderTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTimeMinutes),
      reminderDateTime: reminderDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderDateTime),
      reminderRepeatFrequency: reminderRepeatFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderRepeatFrequency),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
    );
  }

  factory EventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconCodePoint: serializer.fromJson<int?>(json['iconCodePoint']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      granularity: serializer.fromJson<String>(json['granularity']),
      shape: serializer.fromJson<String>(json['shape']),
      recurrenceFrequency: serializer.fromJson<String?>(
        json['recurrenceFrequency'],
      ),
      recurrenceDaysOfWeek: serializer.fromJson<String?>(
        json['recurrenceDaysOfWeek'],
      ),
      recurrenceCycleStartMinutes: serializer.fromJson<int?>(
        json['recurrenceCycleStartMinutes'],
      ),
      recurrenceCycleEndMinutes: serializer.fromJson<int?>(
        json['recurrenceCycleEndMinutes'],
      ),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      reminderTimeMinutes: serializer.fromJson<int?>(
        json['reminderTimeMinutes'],
      ),
      reminderDateTime: serializer.fromJson<DateTime?>(
        json['reminderDateTime'],
      ),
      reminderRepeatFrequency: serializer.fromJson<String?>(
        json['reminderRepeatFrequency'],
      ),
      tag: serializer.fromJson<String?>(json['tag']),
      groupName: serializer.fromJson<String?>(json['groupName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconCodePoint': serializer.toJson<int?>(iconCodePoint),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'granularity': serializer.toJson<String>(granularity),
      'shape': serializer.toJson<String>(shape),
      'recurrenceFrequency': serializer.toJson<String?>(recurrenceFrequency),
      'recurrenceDaysOfWeek': serializer.toJson<String?>(recurrenceDaysOfWeek),
      'recurrenceCycleStartMinutes': serializer.toJson<int?>(
        recurrenceCycleStartMinutes,
      ),
      'recurrenceCycleEndMinutes': serializer.toJson<int?>(
        recurrenceCycleEndMinutes,
      ),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'reminderTimeMinutes': serializer.toJson<int?>(reminderTimeMinutes),
      'reminderDateTime': serializer.toJson<DateTime?>(reminderDateTime),
      'reminderRepeatFrequency': serializer.toJson<String?>(
        reminderRepeatFrequency,
      ),
      'tag': serializer.toJson<String?>(tag),
      'groupName': serializer.toJson<String?>(groupName),
    };
  }

  EventRow copyWith({
    String? id,
    String? title,
    int? colorValue,
    Value<int?> iconCodePoint = const Value.absent(),
    bool? isBuiltIn,
    bool? isRecurring,
    String? granularity,
    String? shape,
    Value<String?> recurrenceFrequency = const Value.absent(),
    Value<String?> recurrenceDaysOfWeek = const Value.absent(),
    Value<int?> recurrenceCycleStartMinutes = const Value.absent(),
    Value<int?> recurrenceCycleEndMinutes = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? remindersEnabled,
    Value<int?> reminderTimeMinutes = const Value.absent(),
    Value<DateTime?> reminderDateTime = const Value.absent(),
    Value<String?> reminderRepeatFrequency = const Value.absent(),
    Value<String?> tag = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
  }) => EventRow(
    id: id ?? this.id,
    title: title ?? this.title,
    colorValue: colorValue ?? this.colorValue,
    iconCodePoint: iconCodePoint.present
        ? iconCodePoint.value
        : this.iconCodePoint,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    isRecurring: isRecurring ?? this.isRecurring,
    granularity: granularity ?? this.granularity,
    shape: shape ?? this.shape,
    recurrenceFrequency: recurrenceFrequency.present
        ? recurrenceFrequency.value
        : this.recurrenceFrequency,
    recurrenceDaysOfWeek: recurrenceDaysOfWeek.present
        ? recurrenceDaysOfWeek.value
        : this.recurrenceDaysOfWeek,
    recurrenceCycleStartMinutes: recurrenceCycleStartMinutes.present
        ? recurrenceCycleStartMinutes.value
        : this.recurrenceCycleStartMinutes,
    recurrenceCycleEndMinutes: recurrenceCycleEndMinutes.present
        ? recurrenceCycleEndMinutes.value
        : this.recurrenceCycleEndMinutes,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    reminderTimeMinutes: reminderTimeMinutes.present
        ? reminderTimeMinutes.value
        : this.reminderTimeMinutes,
    reminderDateTime: reminderDateTime.present
        ? reminderDateTime.value
        : this.reminderDateTime,
    reminderRepeatFrequency: reminderRepeatFrequency.present
        ? reminderRepeatFrequency.value
        : this.reminderRepeatFrequency,
    tag: tag.present ? tag.value : this.tag,
    groupName: groupName.present ? groupName.value : this.groupName,
  );
  EventRow copyWithCompanion(EventsCompanion data) {
    return EventRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      granularity: data.granularity.present
          ? data.granularity.value
          : this.granularity,
      shape: data.shape.present ? data.shape.value : this.shape,
      recurrenceFrequency: data.recurrenceFrequency.present
          ? data.recurrenceFrequency.value
          : this.recurrenceFrequency,
      recurrenceDaysOfWeek: data.recurrenceDaysOfWeek.present
          ? data.recurrenceDaysOfWeek.value
          : this.recurrenceDaysOfWeek,
      recurrenceCycleStartMinutes: data.recurrenceCycleStartMinutes.present
          ? data.recurrenceCycleStartMinutes.value
          : this.recurrenceCycleStartMinutes,
      recurrenceCycleEndMinutes: data.recurrenceCycleEndMinutes.present
          ? data.recurrenceCycleEndMinutes.value
          : this.recurrenceCycleEndMinutes,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      reminderTimeMinutes: data.reminderTimeMinutes.present
          ? data.reminderTimeMinutes.value
          : this.reminderTimeMinutes,
      reminderDateTime: data.reminderDateTime.present
          ? data.reminderDateTime.value
          : this.reminderDateTime,
      reminderRepeatFrequency: data.reminderRepeatFrequency.present
          ? data.reminderRepeatFrequency.value
          : this.reminderRepeatFrequency,
      tag: data.tag.present ? data.tag.value : this.tag,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('granularity: $granularity, ')
          ..write('shape: $shape, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('recurrenceDaysOfWeek: $recurrenceDaysOfWeek, ')
          ..write('recurrenceCycleStartMinutes: $recurrenceCycleStartMinutes, ')
          ..write('recurrenceCycleEndMinutes: $recurrenceCycleEndMinutes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderTimeMinutes: $reminderTimeMinutes, ')
          ..write('reminderDateTime: $reminderDateTime, ')
          ..write('reminderRepeatFrequency: $reminderRepeatFrequency, ')
          ..write('tag: $tag, ')
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    colorValue,
    iconCodePoint,
    isBuiltIn,
    isRecurring,
    granularity,
    shape,
    recurrenceFrequency,
    recurrenceDaysOfWeek,
    recurrenceCycleStartMinutes,
    recurrenceCycleEndMinutes,
    startDate,
    endDate,
    updatedAt,
    deletedAt,
    remindersEnabled,
    reminderTimeMinutes,
    reminderDateTime,
    reminderRepeatFrequency,
    tag,
    groupName,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.colorValue == this.colorValue &&
          other.iconCodePoint == this.iconCodePoint &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isRecurring == this.isRecurring &&
          other.granularity == this.granularity &&
          other.shape == this.shape &&
          other.recurrenceFrequency == this.recurrenceFrequency &&
          other.recurrenceDaysOfWeek == this.recurrenceDaysOfWeek &&
          other.recurrenceCycleStartMinutes ==
              this.recurrenceCycleStartMinutes &&
          other.recurrenceCycleEndMinutes == this.recurrenceCycleEndMinutes &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.remindersEnabled == this.remindersEnabled &&
          other.reminderTimeMinutes == this.reminderTimeMinutes &&
          other.reminderDateTime == this.reminderDateTime &&
          other.reminderRepeatFrequency == this.reminderRepeatFrequency &&
          other.tag == this.tag &&
          other.groupName == this.groupName);
}

class EventsCompanion extends UpdateCompanion<EventRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> colorValue;
  final Value<int?> iconCodePoint;
  final Value<bool> isBuiltIn;
  final Value<bool> isRecurring;
  final Value<String> granularity;
  final Value<String> shape;
  final Value<String?> recurrenceFrequency;
  final Value<String?> recurrenceDaysOfWeek;
  final Value<int?> recurrenceCycleStartMinutes;
  final Value<int?> recurrenceCycleEndMinutes;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> remindersEnabled;
  final Value<int?> reminderTimeMinutes;
  final Value<DateTime?> reminderDateTime;
  final Value<String?> reminderRepeatFrequency;
  final Value<String?> tag;
  final Value<String?> groupName;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.granularity = const Value.absent(),
    this.shape = const Value.absent(),
    this.recurrenceFrequency = const Value.absent(),
    this.recurrenceDaysOfWeek = const Value.absent(),
    this.recurrenceCycleStartMinutes = const Value.absent(),
    this.recurrenceCycleEndMinutes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderTimeMinutes = const Value.absent(),
    this.reminderDateTime = const Value.absent(),
    this.reminderRepeatFrequency = const Value.absent(),
    this.tag = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String title,
    required int colorValue,
    this.iconCodePoint = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    required bool isRecurring,
    required String granularity,
    required String shape,
    this.recurrenceFrequency = const Value.absent(),
    this.recurrenceDaysOfWeek = const Value.absent(),
    this.recurrenceCycleStartMinutes = const Value.absent(),
    this.recurrenceCycleEndMinutes = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderTimeMinutes = const Value.absent(),
    this.reminderDateTime = const Value.absent(),
    this.reminderRepeatFrequency = const Value.absent(),
    this.tag = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       colorValue = Value(colorValue),
       isRecurring = Value(isRecurring),
       granularity = Value(granularity),
       shape = Value(shape);
  static Insertable<EventRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? colorValue,
    Expression<int>? iconCodePoint,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isRecurring,
    Expression<String>? granularity,
    Expression<String>? shape,
    Expression<String>? recurrenceFrequency,
    Expression<String>? recurrenceDaysOfWeek,
    Expression<int>? recurrenceCycleStartMinutes,
    Expression<int>? recurrenceCycleEndMinutes,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? remindersEnabled,
    Expression<int>? reminderTimeMinutes,
    Expression<DateTime>? reminderDateTime,
    Expression<String>? reminderRepeatFrequency,
    Expression<String>? tag,
    Expression<String>? groupName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (colorValue != null) 'color_value': colorValue,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (granularity != null) 'granularity': granularity,
      if (shape != null) 'shape': shape,
      if (recurrenceFrequency != null)
        'recurrence_frequency': recurrenceFrequency,
      if (recurrenceDaysOfWeek != null)
        'recurrence_days_of_week': recurrenceDaysOfWeek,
      if (recurrenceCycleStartMinutes != null)
        'recurrence_cycle_start_minutes': recurrenceCycleStartMinutes,
      if (recurrenceCycleEndMinutes != null)
        'recurrence_cycle_end_minutes': recurrenceCycleEndMinutes,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (reminderTimeMinutes != null)
        'reminder_time_minutes': reminderTimeMinutes,
      if (reminderDateTime != null) 'reminder_date_time': reminderDateTime,
      if (reminderRepeatFrequency != null)
        'reminder_repeat_frequency': reminderRepeatFrequency,
      if (tag != null) 'tag': tag,
      if (groupName != null) 'group_name': groupName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? colorValue,
    Value<int?>? iconCodePoint,
    Value<bool>? isBuiltIn,
    Value<bool>? isRecurring,
    Value<String>? granularity,
    Value<String>? shape,
    Value<String?>? recurrenceFrequency,
    Value<String?>? recurrenceDaysOfWeek,
    Value<int?>? recurrenceCycleStartMinutes,
    Value<int?>? recurrenceCycleEndMinutes,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? remindersEnabled,
    Value<int?>? reminderTimeMinutes,
    Value<DateTime?>? reminderDateTime,
    Value<String?>? reminderRepeatFrequency,
    Value<String?>? tag,
    Value<String?>? groupName,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isRecurring: isRecurring ?? this.isRecurring,
      granularity: granularity ?? this.granularity,
      shape: shape ?? this.shape,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      recurrenceDaysOfWeek: recurrenceDaysOfWeek ?? this.recurrenceDaysOfWeek,
      recurrenceCycleStartMinutes:
          recurrenceCycleStartMinutes ?? this.recurrenceCycleStartMinutes,
      recurrenceCycleEndMinutes:
          recurrenceCycleEndMinutes ?? this.recurrenceCycleEndMinutes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      reminderRepeatFrequency:
          reminderRepeatFrequency ?? this.reminderRepeatFrequency,
      tag: tag ?? this.tag,
      groupName: groupName ?? this.groupName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (granularity.present) {
      map['granularity'] = Variable<String>(granularity.value);
    }
    if (shape.present) {
      map['shape'] = Variable<String>(shape.value);
    }
    if (recurrenceFrequency.present) {
      map['recurrence_frequency'] = Variable<String>(recurrenceFrequency.value);
    }
    if (recurrenceDaysOfWeek.present) {
      map['recurrence_days_of_week'] = Variable<String>(
        recurrenceDaysOfWeek.value,
      );
    }
    if (recurrenceCycleStartMinutes.present) {
      map['recurrence_cycle_start_minutes'] = Variable<int>(
        recurrenceCycleStartMinutes.value,
      );
    }
    if (recurrenceCycleEndMinutes.present) {
      map['recurrence_cycle_end_minutes'] = Variable<int>(
        recurrenceCycleEndMinutes.value,
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (reminderTimeMinutes.present) {
      map['reminder_time_minutes'] = Variable<int>(reminderTimeMinutes.value);
    }
    if (reminderDateTime.present) {
      map['reminder_date_time'] = Variable<DateTime>(reminderDateTime.value);
    }
    if (reminderRepeatFrequency.present) {
      map['reminder_repeat_frequency'] = Variable<String>(
        reminderRepeatFrequency.value,
      );
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('granularity: $granularity, ')
          ..write('shape: $shape, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('recurrenceDaysOfWeek: $recurrenceDaysOfWeek, ')
          ..write('recurrenceCycleStartMinutes: $recurrenceCycleStartMinutes, ')
          ..write('recurrenceCycleEndMinutes: $recurrenceCycleEndMinutes, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderTimeMinutes: $reminderTimeMinutes, ')
          ..write('reminderDateTime: $reminderDateTime, ')
          ..write('reminderRepeatFrequency: $reminderRepeatFrequency, ')
          ..write('tag: $tag, ')
          ..write('groupName: $groupName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    iconCodePoint,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  GroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class GroupRow extends DataClass implements Insertable<GroupRow> {
  final String name;
  final int? iconCodePoint;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const GroupRow({
    required this.name,
    this.iconCodePoint,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconCodePoint != null) {
      map['icon_code_point'] = Variable<int>(iconCodePoint);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      name: Value(name),
      iconCodePoint: iconCodePoint == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCodePoint),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory GroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRow(
      name: serializer.fromJson<String>(json['name']),
      iconCodePoint: serializer.fromJson<int?>(json['iconCodePoint']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'iconCodePoint': serializer.toJson<int?>(iconCodePoint),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  GroupRow copyWith({
    String? name,
    Value<int?> iconCodePoint = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => GroupRow(
    name: name ?? this.name,
    iconCodePoint: iconCodePoint.present
        ? iconCodePoint.value
        : this.iconCodePoint,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  GroupRow copyWithCompanion(GroupsCompanion data) {
    return GroupRow(
      name: data.name.present ? data.name.value : this.name,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRow(')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, iconCodePoint, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRow &&
          other.name == this.name &&
          other.iconCodePoint == this.iconCodePoint &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GroupsCompanion extends UpdateCompanion<GroupRow> {
  final Value<String> name;
  final Value<int?> iconCodePoint;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.name = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String name,
    this.iconCodePoint = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<GroupRow> custom({
    Expression<String>? name,
    Expression<int>? iconCodePoint,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? name,
    Value<int?>? iconCodePoint,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [events, groups];
}

typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String title,
      required int colorValue,
      Value<int?> iconCodePoint,
      Value<bool> isBuiltIn,
      required bool isRecurring,
      required String granularity,
      required String shape,
      Value<String?> recurrenceFrequency,
      Value<String?> recurrenceDaysOfWeek,
      Value<int?> recurrenceCycleStartMinutes,
      Value<int?> recurrenceCycleEndMinutes,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> remindersEnabled,
      Value<int?> reminderTimeMinutes,
      Value<DateTime?> reminderDateTime,
      Value<String?> reminderRepeatFrequency,
      Value<String?> tag,
      Value<String?> groupName,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> colorValue,
      Value<int?> iconCodePoint,
      Value<bool> isBuiltIn,
      Value<bool> isRecurring,
      Value<String> granularity,
      Value<String> shape,
      Value<String?> recurrenceFrequency,
      Value<String?> recurrenceDaysOfWeek,
      Value<int?> recurrenceCycleStartMinutes,
      Value<int?> recurrenceCycleEndMinutes,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> remindersEnabled,
      Value<int?> reminderTimeMinutes,
      Value<DateTime?> reminderDateTime,
      Value<String?> reminderRepeatFrequency,
      Value<String?> tag,
      Value<String?> groupName,
      Value<int> rowid,
    });

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get granularity => $composableBuilder(
    column: $table.granularity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceDaysOfWeek => $composableBuilder(
    column: $table.recurrenceDaysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceCycleStartMinutes => $composableBuilder(
    column: $table.recurrenceCycleStartMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurrenceCycleEndMinutes => $composableBuilder(
    column: $table.recurrenceCycleEndMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderDateTime => $composableBuilder(
    column: $table.reminderDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderRepeatFrequency => $composableBuilder(
    column: $table.reminderRepeatFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get granularity => $composableBuilder(
    column: $table.granularity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceDaysOfWeek => $composableBuilder(
    column: $table.recurrenceDaysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceCycleStartMinutes => $composableBuilder(
    column: $table.recurrenceCycleStartMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceCycleEndMinutes => $composableBuilder(
    column: $table.recurrenceCycleEndMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderDateTime => $composableBuilder(
    column: $table.reminderDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderRepeatFrequency => $composableBuilder(
    column: $table.reminderRepeatFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get granularity => $composableBuilder(
    column: $table.granularity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shape =>
      $composableBuilder(column: $table.shape, builder: (column) => column);

  GeneratedColumn<String> get recurrenceFrequency => $composableBuilder(
    column: $table.recurrenceFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceDaysOfWeek => $composableBuilder(
    column: $table.recurrenceDaysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceCycleStartMinutes => $composableBuilder(
    column: $table.recurrenceCycleStartMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurrenceCycleEndMinutes => $composableBuilder(
    column: $table.recurrenceCycleEndMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTimeMinutes => $composableBuilder(
    column: $table.reminderTimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderDateTime => $composableBuilder(
    column: $table.reminderDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderRepeatFrequency => $composableBuilder(
    column: $table.reminderRepeatFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          EventRow,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
          EventRow,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int?> iconCodePoint = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String> granularity = const Value.absent(),
                Value<String> shape = const Value.absent(),
                Value<String?> recurrenceFrequency = const Value.absent(),
                Value<String?> recurrenceDaysOfWeek = const Value.absent(),
                Value<int?> recurrenceCycleStartMinutes = const Value.absent(),
                Value<int?> recurrenceCycleEndMinutes = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int?> reminderTimeMinutes = const Value.absent(),
                Value<DateTime?> reminderDateTime = const Value.absent(),
                Value<String?> reminderRepeatFrequency = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                title: title,
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
                isBuiltIn: isBuiltIn,
                isRecurring: isRecurring,
                granularity: granularity,
                shape: shape,
                recurrenceFrequency: recurrenceFrequency,
                recurrenceDaysOfWeek: recurrenceDaysOfWeek,
                recurrenceCycleStartMinutes: recurrenceCycleStartMinutes,
                recurrenceCycleEndMinutes: recurrenceCycleEndMinutes,
                startDate: startDate,
                endDate: endDate,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                remindersEnabled: remindersEnabled,
                reminderTimeMinutes: reminderTimeMinutes,
                reminderDateTime: reminderDateTime,
                reminderRepeatFrequency: reminderRepeatFrequency,
                tag: tag,
                groupName: groupName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int colorValue,
                Value<int?> iconCodePoint = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                required bool isRecurring,
                required String granularity,
                required String shape,
                Value<String?> recurrenceFrequency = const Value.absent(),
                Value<String?> recurrenceDaysOfWeek = const Value.absent(),
                Value<int?> recurrenceCycleStartMinutes = const Value.absent(),
                Value<int?> recurrenceCycleEndMinutes = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int?> reminderTimeMinutes = const Value.absent(),
                Value<DateTime?> reminderDateTime = const Value.absent(),
                Value<String?> reminderRepeatFrequency = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                title: title,
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
                isBuiltIn: isBuiltIn,
                isRecurring: isRecurring,
                granularity: granularity,
                shape: shape,
                recurrenceFrequency: recurrenceFrequency,
                recurrenceDaysOfWeek: recurrenceDaysOfWeek,
                recurrenceCycleStartMinutes: recurrenceCycleStartMinutes,
                recurrenceCycleEndMinutes: recurrenceCycleEndMinutes,
                startDate: startDate,
                endDate: endDate,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                remindersEnabled: remindersEnabled,
                reminderTimeMinutes: reminderTimeMinutes,
                reminderDateTime: reminderDateTime,
                reminderRepeatFrequency: reminderRepeatFrequency,
                tag: tag,
                groupName: groupName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      EventRow,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (EventRow, BaseReferences<_$AppDatabase, $EventsTable, EventRow>),
      EventRow,
      PrefetchHooks Function()
    >;
typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      required String name,
      Value<int?> iconCodePoint,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      Value<String> name,
      Value<int?> iconCodePoint,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          GroupRow,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (GroupRow, BaseReferences<_$AppDatabase, $GroupsTable, GroupRow>),
          GroupRow,
          PrefetchHooks Function()
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int?> iconCodePoint = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                name: name,
                iconCodePoint: iconCodePoint,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<int?> iconCodePoint = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                name: name,
                iconCodePoint: iconCodePoint,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      GroupRow,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (GroupRow, BaseReferences<_$AppDatabase, $GroupsTable, GroupRow>),
      GroupRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
}
