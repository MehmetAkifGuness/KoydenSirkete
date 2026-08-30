import 'dart:collection';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'player_state_store.dart';

class SqliteSaveSupport {
  SqliteSaveSupport(this._database);

  static const _tableName = 'player_state';
  static const _metadataTable = 'save_metadata';
  static const _minimumSlot = 1;
  static const _maximumSlot = 3;
  static const _backupOffset = 100;

  final Future<Database> Function() _database;
  int _activeSlot = 1;
  bool _metadataLoaded = false;

  int get activeSlot => _activeSlot;

  Future<Map<String, Object?>?> readActiveRow() async {
    await _loadMetadata();
    final database = await _database();
    final rows = await database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [_activeSlot],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    var row = rows.first;
    if (!_isHealthyRow(row)) {
      final backups = await database.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [_backupId(_activeSlot)],
        limit: 1,
      );
      if (backups.isEmpty || !_isHealthyRow(backups.first)) {
        throw const SaveDataException(
          'Kayıt bütünlüğü doğrulanamadı ve sağlam yedek bulunamadı.',
        );
      }
      row = Map<String, Object?>.from(backups.first)..['id'] = _activeSlot;
      await database.insert(
        _tableName,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return row;
  }

  Future<void> saveActiveRow(Map<String, Object?> source) async {
    await _loadMetadata();
    final database = await _database();
    await database.transaction((transaction) async {
      final previous = await transaction.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [_activeSlot],
        limit: 1,
      );
      if (previous.isNotEmpty && _isHealthyRow(previous.first)) {
        final backup = Map<String, Object?>.from(previous.first)
          ..['id'] = _backupId(_activeSlot);
        await transaction.insert(
          _tableName,
          backup,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      final revision = previous.isEmpty
          ? 1
          : (previous.first['save_revision'] as int? ?? 0) + 1;
      final row = Map<String, Object?>.from(source)
        ..['id'] = _activeSlot
        ..['save_revision'] = revision
        ..['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      row['data_checksum'] = _checksum(row);
      await transaction.insert(
        _tableName,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<SaveSlotInfo>> listSlots() async {
    await _loadMetadata();
    final rows = await (await _database()).query(
      _tableName,
      where: 'id BETWEEN ? AND ?',
      whereArgs: [_minimumSlot, _maximumSlot],
    );
    final byId = {for (final row in rows) row['id'] as int: row};
    return [
      for (var slot = _minimumSlot; slot <= _maximumSlot; slot++)
        SaveSlotInfo(
          slot: slot,
          hasSave: byId.containsKey(slot),
          isHealthy: byId[slot] == null || _isHealthyRow(byId[slot]!),
          day: byId[slot]?['day'] as int?,
          money: byId[slot]?['money'] as int?,
          updatedAt: _dateTimeFromMillis(byId[slot]?['updated_at'] as int?),
        ),
    ];
  }

  Future<void> switchSlot(int slot) async {
    _requireSlot(slot);
    await (await _database()).insert(_metadataTable, {
      'key': 'active_slot',
      'value': '$slot',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _activeSlot = slot;
    _metadataLoaded = true;
  }

  Future<String> exportSlot(int slot) async {
    _requireSlot(slot);
    final rows = await (await _database()).query(
      _tableName,
      where: 'id = ?',
      whereArgs: [slot],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const SaveDataException('Bu yuvada dışa aktarılacak kayıt yok.');
    }
    if (!_isHealthyRow(rows.first)) {
      throw const SaveDataException('Bozuk kayıt dışa aktarılamaz.');
    }
    final payload = Map<String, Object?>.from(rows.first)..['id'] = 1;
    return jsonEncode({
      'format': 'mudur-save',
      'format_version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'payload': payload,
    });
  }

  Future<void> importSlot(String data, {required int slot}) async {
    _requireSlot(slot);
    final Object? decoded;
    try {
      decoded = jsonDecode(data.trim());
    } on FormatException {
      throw const SaveDataException('İçe aktarma metni geçerli JSON değil.');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'mudur-save' ||
        decoded['format_version'] != 1 ||
        decoded['payload'] is! Map<String, dynamic>) {
      throw const SaveDataException('Desteklenmeyen veya eksik kayıt biçimi.');
    }
    final database = await _database();
    final columns = (await database.rawQuery(
      'PRAGMA table_info($_tableName)',
    )).map((row) => row['name'] as String).toSet();
    final source = decoded['payload'] as Map<String, dynamic>;
    final row = <String, Object?>{
      for (final entry in source.entries)
        if (columns.contains(entry.key)) entry.key: entry.value,
    }..['id'] = slot;
    _validateImportedRow(row);
    if (!_isHealthyRow(row)) {
      throw const SaveDataException('Kayıt bütünlük kontrolünden geçemedi.');
    }
    await database.transaction((transaction) async {
      final previous = await transaction.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [slot],
        limit: 1,
      );
      if (previous.isNotEmpty && _isHealthyRow(previous.first)) {
        final backup = Map<String, Object?>.from(previous.first)
          ..['id'] = _backupId(slot);
        await transaction.insert(
          _tableName,
          backup,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await transaction.insert(
        _tableName,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.insert(_metadataTable, {
        'key': 'active_slot',
        'value': '$slot',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
    _activeSlot = slot;
    _metadataLoaded = true;
  }

  Future<void> _loadMetadata() async {
    if (_metadataLoaded) return;
    final rows = await (await _database()).query(
      _metadataTable,
      where: 'key = ?',
      whereArgs: ['active_slot'],
      limit: 1,
    );
    final value = rows.isEmpty
        ? null
        : int.tryParse(rows.first['value'] as String);
    _activeSlot = _isValidSlot(value) ? value! : 1;
    _metadataLoaded = true;
  }

  static DateTime? _dateTimeFromMillis(int? value) =>
      value == null || value <= 0
      ? null
      : DateTime.fromMillisecondsSinceEpoch(value);

  static int _backupId(int slot) => slot + _backupOffset;

  static bool _isValidSlot(int? slot) =>
      slot != null && slot >= _minimumSlot && slot <= _maximumSlot;

  static void _requireSlot(int slot) {
    if (!_isValidSlot(slot)) {
      throw RangeError.range(slot, _minimumSlot, _maximumSlot, 'slot');
    }
  }

  static bool _isHealthyRow(Map<String, Object?> row) {
    final expected = row['data_checksum'];
    return expected == null || expected == _checksum(row);
  }

  static String _checksum(Map<String, Object?> row) {
    final canonical = SplayTreeMap<String, Object?>.from(
      Map<String, Object?>.from(row)
        ..remove('id')
        ..remove('data_checksum'),
    );
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(jsonEncode(canonical))) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static void _validateImportedRow(Map<String, Object?> row) {
    const requiredIntegers = [
      'schema_version',
      'money',
      'energy',
      'knowledge',
      'experience',
      'day',
      'hour',
      'earning_sessions_today',
    ];
    for (final key in requiredIntegers) {
      if (row[key] is! int) {
        throw SaveDataException('Kayıtta zorunlu “$key” alanı eksik.');
      }
    }
    const limit = 0x7fffffff;
    for (final entry in row.entries.where(
      (entry) =>
          entry.value is int &&
          entry.key != 'energy_recovery_at' &&
          entry.key != 'updated_at',
    )) {
      final value = entry.value! as int;
      if (value < -limit || value > limit) {
        throw SaveDataException(
          '“${entry.key}” değeri güvenli sınırları aşıyor.',
        );
      }
    }
    if ((row['day'] as int) < 1 ||
        (row['hour'] as int) < 0 ||
        (row['hour'] as int) > 23 ||
        (row['energy'] as int) < 0) {
      throw const SaveDataException('Kayıttaki sayı değerleri geçersiz.');
    }
  }
}
