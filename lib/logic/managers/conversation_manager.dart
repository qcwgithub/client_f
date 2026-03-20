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
  final Event2<int, int> unreadCountChanged = Event2<int, int>();
  final Event1<int> totalUnreadCountChanged = Event1<int>();

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

  // 首次登录时调用
  Future<void> initialLoad() async {
    _list.clear();
    _map.clear();

    final List<StorageConversation> list = await _storage.getAll();
    if (list.isEmpty) {
      return;
    }

    List<int>? deletes;

    final lastMessages = await sc.chatMessageStorage.getLastMessages(
      list.map((conv) => conv.roomId).toList(),
    );

    for (final StorageConversation sconv in list) {
      switch (sconv.type) {
        case ConversationType.friend:
          {
            // 移除不是好友的
            final FriendInfo? friendInfo = sc.friendManager.getFriendByRoomId(
              sconv.roomId,
            );
            if (friendInfo == null) {
              deletes ??= [];
              deletes.add(sconv.roomId);
              continue;
            }

            if (friendInfo.readSeq > sconv.readSeq) {
              sconv.readSeq = friendInfo.readSeq;
            }
          }
          break;

        case ConversationType.scene:
          break;
      }

      // 移除没有任何消息的
      final lastMessage = lastMessages[sconv.roomId];
      if (lastMessage == null) {
        deletes ??= [];
        deletes.add(sconv.roomId);
        continue;
      }

      final ex = Conversation(sconv: sconv, lastMessage: lastMessage);
      _list.add(ex);
      _map[sconv.roomId] = ex;
    }

    _sortList();
    conversationListChanged.emit();

    if (deletes != null) {
      await _storage.deleteMany(deletes);
    }
  }

  // 首次登录时调用
  void listenForFriendChatMessages() {
    sc.friendChatMessageManager.messagesAdded.on(_onFriendChatMessage);
    sc.sceneChatMessageManager.onEnterSceneSuccess.on(_onEnterSceneSuccess);
  }

  Future<void> _onMessages(
    ConversationType type,
    List<ChatMessage> messages,
  ) async {
    bool needNotify = false;
    bool needSort = false;
    List<StorageConversation>? upserts;
    List<Conversation>? unreadCountChanges;

    int previousTotalUnreadCount = getTotalUnreadCount();

    for (final message in messages) {
      Conversation? conv = _map[message.roomId];
      if (conv == null) {
        final sconv = StorageConversation(
          type: type,
          roomId: message.roomId,
          // 当出现新会话时，仅当前消息为未读
          readSeq: sc.me.isMe(message.senderId)
              ? message.seq
              : max(0, message.seq - 1),
        );

        conv = Conversation(sconv: sconv, lastMessage: message);

        _list.add(conv);
        _map[message.roomId] = conv;
        needSort = true;
        needNotify = true;

        upserts ??= [];
        upserts.add(sconv);
      } else {
        if (message.seq > conv.lastMessage.seq) {
          int previousUnreadCount = conv.unreadCount;

          conv.lastMessage = message;
          needSort = true;
          needNotify = true;

          // 自己发的消息，readSeq 跟进
          if (sc.me.isMe(message.senderId) &&
              message.seq > conv.sconv.readSeq) {
            conv.sconv.readSeq = message.seq;
            upserts ??= [];
            upserts.add(conv.sconv);
          }

          if (conv.unreadCount != previousUnreadCount &&
              (unreadCountChanges == null ||
                  !unreadCountChanges.contains(conv))) {
            unreadCountChanges ??= [];
            unreadCountChanges.add(conv);
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

    if (unreadCountChanges != null) {
      for (final conv in unreadCountChanges) {
        unreadCountChanged.emit(conv.sconv.roomId, conv.unreadCount);
      }
    }

    int totalUnreadCount = getTotalUnreadCount();
    if (totalUnreadCount != previousTotalUnreadCount) {
      totalUnreadCountChanged.emit(totalUnreadCount);
    }

    if (upserts != null) {
      await _storage.upsertMany(upserts);
    }
  }

  Future<void> _onFriendChatMessage(List<ChatMessage> messages) async {
    await _onMessages(ConversationType.friend, messages);
  }

  Future<void> _onEnterSceneSuccess(
    int roomId,
    List<ChatMessage> messages,
  ) async {
    await _onMessages(ConversationType.scene, messages);
  }

  // 即将上报给服务器好友 readSeq 时调用
  Future<void> tryUpdateReadSeq(int roomId, int seq) async {
    Conversation? conv = _map[roomId];
    if (conv != null && seq > conv.sconv.readSeq) {
      conv.sconv.readSeq = seq;
      conversationListChanged.emit();
      unreadCountChanged.emit(conv.sconv.roomId, conv.unreadCount);
      totalUnreadCountChanged.emit(getTotalUnreadCount());

      await _storage.upsert(conv.sconv);
    }
  }

  Future<void> onQuit() async {
    sc.friendChatMessageManager.messagesAdded.off(_onFriendChatMessage);
    sc.sceneChatMessageManager.onEnterSceneSuccess.off(_onEnterSceneSuccess);
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

  int getTotalUnreadCount() {
    int total = 0;
    for (final conv in _list) {
      total += conv.unreadCount;
    }
    return total;
  }

  // 左滑删除
  Future<void> delete(int roomId) async {
    _list.removeWhere((conv) => conv.sconv.roomId == roomId);
    _map.remove(roomId);
    conversationListChanged.emit();
    await _storage.delete(roomId);
  }
}
