import 'dart:async';
import 'dart:math';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/logic/event.dart';
import 'package:scene_hub/sc.dart';

import '../storage/conversation_storage.dart';

class ConversationManager {
  final _storage = ConversationStorage();

  final Event conversationListChanged = Event();

  final List<Conversation> _list = [];
  final Map<int, Conversation> _map = {};

  Future<void> openStorage() async {
    await _storage.open(sc.me.userId);
  }

  void _sortList() {
    if (_list.isNotEmpty) {
      _list.sort(
        (a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp),
      );
    }
  }

  Future<void> initialLoad() async {
    _list.clear();
    _map.clear();

    final List<StorageConversation> list = await _storage.getAll();
    if (list.isEmpty) {
      return;
    }

    List<int>? deletes;

    final latestMessages = await sc.chatMessageStorage.getLatestMessages(
      list.map((conv) => conv.roomId).toList(),
    );

    for (final StorageConversation conv in list) {
      // 移除不是好友的
      final FriendInfo? friendInfo = sc.friendManager.getFriendByRoomId(
        conv.roomId,
      );
      if (friendInfo == null) {
        deletes ??= [];
        deletes.add(conv.roomId);
        continue;
      }

      // 移除没有任何消息的
      final latestMessage = latestMessages[conv.roomId];
      if (latestMessage == null) {
        deletes ??= [];
        deletes.add(conv.roomId);
        continue;
      }

      final ex = Conversation(
        roomId: conv.roomId,
        lastMessage: latestMessage,
        readSeq: max(conv.readSeq, friendInfo.readSeq),
      );
      _list.add(ex);
      _map[conv.roomId] = ex;
    }

    _sortList();
    conversationListChanged.emit();

    if (deletes != null) {
      await _storage.deleteMany(deletes);
    }
  }

  StreamSubscription<List<ChatMessage>>? _friendChatSub;
  void listenForFriendChatMessages() {
    _friendChatSub = sc.friendChatMessageManager.stream.listen(
      _onFriendChatMessage,
    );
  }

  Future<void> _onFriendChatMessage(List<ChatMessage> messages) async {
    bool needNotify = false;
    bool needSort = false;
    List<StorageConversation>? upserts;

    for (final message in messages) {
      Conversation? conv = _map[message.roomId];
      if (conv == null) {
        conv = Conversation(
          roomId: message.roomId,
          lastMessage: message,
          // 当出现新会话时，仅当前消息为未读
          readSeq: sc.me.isMe(message.senderId)
              ? message.seq
              : max(0, message.seq - 1),
        );

        _list.add(conv);
        _map[message.roomId] = conv;
        needSort = true;
        needNotify = true;

        upserts ??= [];
        upserts.add(
          StorageConversation(roomId: message.roomId, readSeq: conv.readSeq),
        );
      } else {
        if (message.seq > conv.lastMessage.seq) {
          conv.lastMessage = message;
          needSort = true;
          needNotify = true;

          // 自己发的消息，readSeq 跟进
          if (sc.me.isMe(message.senderId) && message.seq > conv.readSeq) {
            conv.readSeq = message.seq;
            upserts ??= [];
            upserts.add(
              StorageConversation(roomId: conv.roomId, readSeq: conv.readSeq),
            );
          }
        }
      }
    }

    if (needSort) {
      _sortList();
    }

    if (needNotify) {
      conversationListChanged.emit();
    }

    if (upserts != null) {
      await _storage.upsertMany(upserts);
    }
  }

  Future<void> tryUpdateReadSeq(int roomId, int seq) async {
    Conversation? conv = _map[roomId];
    if (conv != null && seq > conv.readSeq) {
      conv.readSeq = seq;
      conversationListChanged.emit();

      await _storage.upsert(
        StorageConversation(roomId: conv.roomId, readSeq: conv.readSeq),
      );
    }
  }

  Future<void> onQuit() async {
    _friendChatSub?.cancel();
    _friendChatSub = null;
    _list.clear();
    _map.clear();
    await _storage.close();
  }

  /// 同步获取内存中的列表（已加载后使用）
  List<Conversation> getAll() {
    return List.unmodifiable(_list);
  }

  Conversation? getByRoomId(int roomId) {
    return _map[roomId];
  }

  Future<void> delete(int roomId) async {
    _list.removeWhere((conv) => conv.roomId == roomId);
    _map.remove(roomId);
    conversationListChanged.emit();
    await _storage.delete(roomId);
  }
}
