import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Cross-platform persistence layer:
/// - On Android / iOS / macOS: uses native SQLite (`sqflite`) with normalized relational tables.
/// - On Web / Unit tests where native SQLite channel isn't mounted: uses `SharedPreferences` JSON store.
class LocalDatabase {
  static const String _prefsKey = 'ai_daily_helper_db_v1';
  Database? _db;
  bool _usePrefsFallback = false;

  Future<void> init() async {
    if (kIsWeb) {
      _usePrefsFallback = true;
      return;
    }

    try {
      final dbPath = await getDatabasesPath();
      final fullPath = p.join(dbPath, 'ai_daily_helper.db');
      _db = await openDatabase(
        fullPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE kv_store (
              bucket TEXT PRIMARY KEY,
              payload TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              subtitle TEXT NOT NULL,
              due_at TEXT,
              priority TEXT NOT NULL,
              completed INTEGER NOT NULL,
              section TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE reminders (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              display_time TEXT NOT NULL,
              remind_at TEXT NOT NULL,
              section TEXT NOT NULL,
              completed INTEGER NOT NULL,
              icon_kind TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE shopping_items (
              id TEXT PRIMARY KEY,
              item TEXT NOT NULL,
              category TEXT NOT NULL,
              completed INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE memories (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              subtitle TEXT NOT NULL,
              category TEXT NOT NULL,
              icon_kind TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (_) {
      _usePrefsFallback = true;
    }
  }

  Future<Map<String, dynamic>?> readSnapshot() async {
    if (!_usePrefsFallback && _db != null) {
      final rows = await _db!.query(
        'kv_store',
        where: 'bucket = ?',
        whereArgs: ['app_snapshot'],
      );
      if (rows.isNotEmpty) {
        final raw = rows.first['payload'] as String;
        return jsonDecode(raw) as Map<String, dynamic>;
      }
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeSnapshot(Map<String, dynamic> snapshot) async {
    final encoded = jsonEncode(snapshot);
    if (!_usePrefsFallback && _db != null) {
      await _db!.insert(
        'kv_store',
        {
          'bucket': 'app_snapshot',
          'payload': encoded,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _syncRelationalTables(snapshot);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> _syncRelationalTables(Map<String, dynamic> snapshot) async {
    if (_db == null) return;
    final batch = _db!.batch();

    batch.delete('tasks');
    for (final t in (snapshot['tasks'] as List? ?? const [])) {
      final map = Map<String, dynamic>.from(t as Map);
      batch.insert('tasks', {
        'id': map['id'],
        'title': map['title'],
        'subtitle': map['subtitle'] ?? '',
        'due_at': map['due_at'],
        'priority': map['priority'] ?? 'normal',
        'completed': (map['completed'] == true) ? 1 : 0,
        'section': map['section'] ?? 'today',
      });
    }

    batch.delete('reminders');
    for (final r in (snapshot['reminders'] as List? ?? const [])) {
      final map = Map<String, dynamic>.from(r as Map);
      batch.insert('reminders', {
        'id': map['id'],
        'title': map['title'],
        'display_time': map['display_time'] ?? '',
        'remind_at': map['remind_at'] ?? '',
        'section': map['section'] ?? 'tomorrow',
        'completed': (map['completed'] == true) ? 1 : 0,
        'icon_kind': map['icon_kind'] ?? 'bell',
      });
    }

    batch.delete('shopping_items');
    for (final s in (snapshot['shopping_items'] as List? ?? const [])) {
      final map = Map<String, dynamic>.from(s as Map);
      batch.insert('shopping_items', {
        'id': map['id'],
        'item': map['item'],
        'category': map['category'] ?? 'General',
        'completed': (map['completed'] == true) ? 1 : 0,
      });
    }

    batch.delete('memories');
    for (final m in (snapshot['memories'] as List? ?? const [])) {
      final map = Map<String, dynamic>.from(m as Map);
      batch.insert('memories', {
        'id': map['id'],
        'title': map['title'],
        'content': map['content'] ?? '',
        'subtitle': map['subtitle'] ?? '',
        'category': map['category'] ?? 'preferences',
        'icon_kind': map['icon_kind'] ?? 'note',
      });
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearAll() async {
    if (!_usePrefsFallback && _db != null) {
      await _db!.delete('kv_store');
      await _db!.delete('tasks');
      await _db!.delete('reminders');
      await _db!.delete('shopping_items');
      await _db!.delete('memories');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
