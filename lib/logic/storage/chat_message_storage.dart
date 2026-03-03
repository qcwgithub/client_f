import 'dart:convert';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/chat_message_image_content.dart';
import 'package:scene_hub/gen/chat_message_status.dart';
import 'package:scene_hub/gen/chat_message_type.dart';
import 'package:scene_hub/sc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class ChatMessageStorage {
  Database? _db;

  Future<void> open() async {
    final dbPath = await getDatabasesPath();
    int userId = sc.me.userId;
    final path = p.join(dbPath, 'messages_$userId.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS messages (
            seq INTEGER NOT NULL,
            room_id INTEGER NOT NULL,
            sender_id INTEGER NOT NULL,
            sender_name TEXT NOT NULL,
            sender_avatar TEXT NOT NULL,
            type INTEGER NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            reply_to INTEGER NOT NULL,
            sender_avatar_index INTEGER NOT NULL,
            client_message_id INTEGER NOT NULL,
            status INTEGER NOT NULL,
            image_content TEXT,
            PRIMARY KEY (room_id, seq)
          )
        ''');
      },
    );
  }

  Future<void> onQuit() async {
    await _db?.close();
    _db = null;
  }

  Database get _database {
    if (_db == null) throw StateError('MessageStorage not opened');
    return _db!;
  }

  // ── 写入 ──

  /// 插入或替换一条消息
  Future<void> upsertMessage(ChatMessage msg) async {
    await _database.insert(
      'messages',
      _toRow(msg),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入消息（在事务中执行）
  Future<void> upsertMessages(List<ChatMessage> messages) async {
    if (messages.isEmpty) return;
    final batch = _database.batch();
    for (final msg in messages) {
      batch.insert(
        'messages',
        _toRow(msg),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ── 读取 ──

  /// 获取某个房间最新的 [limit] 条消息
  Future<List<ChatMessage>> getMessages(int roomId, {int limit = 50}) async {
    final rows = await _database.query(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'seq DESC',
      limit: limit,
    );
    // 查询结果是倒序的，翻回正序
    return rows.reversed.map(_fromRow).toList();
  }

  /// 获取某个房间 seq < [beforeSeq] 的历史消息
  Future<List<ChatMessage>> getMessagesBefore(
    int roomId,
    int beforeSeq, {
    int limit = 50,
  }) async {
    final rows = await _database.query(
      'messages',
      where: 'room_id = ? AND seq < ?',
      whereArgs: [roomId, beforeSeq],
      orderBy: 'seq DESC',
      limit: limit,
    );
    return rows.reversed.map(_fromRow).toList();
  }

  /// 获取某个房间 seq > [afterSeq] 的新消息
  Future<List<ChatMessage>> getMessagesAfter(
    int roomId,
    int afterSeq, {
    int limit = 50,
  }) async {
    final rows = await _database.query(
      'messages',
      where: 'room_id = ? AND seq > ?',
      whereArgs: [roomId, afterSeq],
      orderBy: 'seq ASC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  /// 获取某个房间最大的 seq
  Future<int> getMaxSeq(int roomId) async {
    final result = await _database.rawQuery(
      'SELECT MAX(seq) as max_seq FROM messages WHERE room_id = ?',
      [roomId],
    );
    return (result.first['max_seq'] as int?) ?? 0;
  }

  /// 批量获取多个房间各自 max seq 对应的那条消息
  Future<Map<int, ChatMessage>> getLatestMessages(List<int> roomIds) async {
    if (roomIds.isEmpty) return {};
    final placeholders = roomIds.map((_) => '?').join(',');
    final rows = await _database.rawQuery('''
      SELECT m.* FROM messages m
      INNER JOIN (
        SELECT room_id, MAX(seq) as max_seq
        FROM messages
        WHERE room_id IN ($placeholders)
        GROUP BY room_id
      ) t ON m.room_id = t.room_id AND m.seq = t.max_seq
    ''', roomIds);
    final map = <int, ChatMessage>{};
    for (final row in rows) {
      final msg = _fromRow(row);
      map[msg.roomId] = msg;
    }
    return map;
  }

  // ── 删除 ──

  /// 删除某个房间的所有消息
  Future<void> deleteRoomMessages(int roomId) async {
    await _database.delete(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  /// 清空全部消息
  Future<void> deleteAll() async {
    await _database.delete('messages');
  }

  // ── 序列化 ──

  Map<String, Object?> _toRow(ChatMessage msg) {
    return {
      'seq': msg.seq,
      'room_id': msg.roomId,
      'sender_id': msg.senderId,
      'sender_name': msg.senderName,
      'sender_avatar': msg.senderAvatar,
      'type': msg.type.code,
      'content': msg.content,
      'timestamp': msg.timestamp,
      'reply_to': msg.replyTo,
      'sender_avatar_index': msg.senderAvatarIndex,
      'client_message_id': msg.clientSeq,
      'status': msg.status.code,
      'image_content': msg.imageContent != null
          ? jsonEncode({
              'url': msg.imageContent!.url,
              'width': msg.imageContent!.width,
              'height': msg.imageContent!.height,
              'size': msg.imageContent!.size,
              'thumbnailUrl': msg.imageContent!.thumbnailUrl,
            })
          : null,
    };
  }

  ChatMessage _fromRow(Map<String, Object?> row) {
    ChatMessageImageContent? imageContent;
    final imageJson = row['image_content'] as String?;
    if (imageJson != null) {
      final map = jsonDecode(imageJson) as Map<String, dynamic>;
      imageContent = ChatMessageImageContent(
        url: map['url'] as String,
        width: map['width'] as int,
        height: map['height'] as int,
        size: map['size'] as int,
        thumbnailUrl: map['thumbnailUrl'] as String,
      );
    }

    return ChatMessage(
      seq: row['seq'] as int,
      roomId: row['room_id'] as int,
      senderId: row['sender_id'] as int,
      senderName: row['sender_name'] as String,
      senderAvatar: row['sender_avatar'] as String,
      type: ChatMessageType.fromCode(row['type'] as int),
      content: row['content'] as String,
      timestamp: row['timestamp'] as int,
      replyTo: row['reply_to'] as int,
      senderAvatarIndex: row['sender_avatar_index'] as int,
      clientSeq: row['client_message_id'] as int,
      status: ChatMessageStatus.fromCode(row['status'] as int),
      imageContent: imageContent,
    );
  }
}
