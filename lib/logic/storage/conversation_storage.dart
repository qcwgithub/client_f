import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../conversation.dart';

class ConversationStorage {
  Database? _db;

  Future<void> open(int userId) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'conversations_$userId.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            room_id INTEGER PRIMARY KEY,
            target_user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            avatar_index INTEGER NOT NULL DEFAULT 0,
            last_message TEXT NOT NULL DEFAULT '',
            last_message_time INTEGER NOT NULL DEFAULT 0,
            read_seq INTEGER NOT NULL DEFAULT 0,
            max_seq INTEGER NOT NULL DEFAULT 0,
            type INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Database get _database {
    if (_db == null) throw StateError('ConversationStorage not opened');
    return _db!;
  }

  // ── 读取 ──

  /// 获取所有会话，按最后消息时间倒序
  Future<List<Conversation>> getAll() async {
    final rows = await _database.query(
      'conversations',
      orderBy: 'last_message_time DESC',
    );
    return rows.map(Conversation.fromMap).toList();
  }

  /// 根据 roomId 获取
  Future<Conversation?> get(int roomId) async {
    final rows = await _database.query(
      'conversations',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
    if (rows.isEmpty) return null;
    return Conversation.fromMap(rows.first);
  }

  // ── 写入 ──

  /// 新增或更新会话
  Future<void> upsert(Conversation conversation) async {
    await _database.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量新增或更新
  Future<void> upsertAll(List<Conversation> conversations) async {
    if (conversations.isEmpty) return;
    await _database.transaction((txn) async {
      for (final c in conversations) {
        await txn.insert(
          'conversations',
          c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> setReadSeqAndMaxSeq(int roomId, int readSeq, int maxSeq) async {
    await _database.update(
      'conversations',
      {
        'read_seq': readSeq,
        'max_seq': maxSeq,
      },
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  Future<void> setReadSeq(int roomId, int readSeq) async {
    await _database.update(
      'conversations',
      {
        'read_seq': readSeq
      },
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  Future<void> setMaxSeq(int roomId, int maxSeq) async {
    await _database.update(
      'conversations',
      {
        'max_seq': maxSeq
      },
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  // ── 删除 ──

  /// 删除会话
  Future<void> delete(int roomId) async {
    await _database.delete(
      'conversations',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// 删除全部
  Future<void> deleteAll() async {
    await _database.delete('conversations');
  }
}
