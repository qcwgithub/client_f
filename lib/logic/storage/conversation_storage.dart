import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

enum ConversationType { friend, scene }

class StorageConversation {
  ConversationType type;
  int roomId;
  // 也存一下，有时候上报到服务器失败了，就以本地为准，避免消息一直读
  int readSeq;

  StorageConversation({
    required this.type,
    required this.roomId,
    required this.readSeq,
  });

  Map<String, dynamic> toMap() {
    return {'type': type.index, 'room_id': roomId, 'read_seq': readSeq};
  }

  factory StorageConversation.fromMap(Map<String, dynamic> map) {
    return StorageConversation(
      type: ConversationType.values[map['type'] as int],
      roomId: map['room_id'] as int,
      readSeq: map['read_seq'] as int,
    );
  }
}

class ConversationStorage {
  Database? _db;

  Future<void> open(int userId) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'conversations_${userId}_3.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            type INTEGER NOT NULL,
            room_id INTEGER PRIMARY KEY,
            read_seq INTEGER NOT NULL DEFAULT 0
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
  Future<List<StorageConversation>> getAll() async {
    final rows = await _database.query('conversations');
    return rows.map(StorageConversation.fromMap).toList();
  }

  // ── 写入 ──

  /// 新增或更新会话
  Future<void> upsert(StorageConversation conversation) async {
    await _database.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量新增或更新
  Future<void> upsertMany(List<StorageConversation> conversations) async {
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

  // ── 删除 ──

  /// 删除会话
  Future<void> delete(int roomId) async {
    await _database.delete(
      'conversations',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// 批量删除会话
  Future<void> deleteMany(List<int> roomIds) async {
    if (roomIds.isEmpty) return;
    final placeholders = roomIds.map((_) => '?').join(',');
    await _database.delete(
      'conversations',
      where: 'room_id IN ($placeholders)',
      whereArgs: roomIds,
    );
  }
}
