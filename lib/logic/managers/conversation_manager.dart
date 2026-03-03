import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/sc.dart';

import '../storage/conversation_storage.dart';

class ConversationManager {
  final _storage = ConversationStorage();

  final List<VoidCallback> _listeners = [];
  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  final List<Conversation> _list = [];
  final Map<int, Conversation> _map = {};

  Future<void> openStorage() async {
    await _storage.open(sc.me.userId);
  }

  Future<void> initialLoad() async {
    _list.clear();
    _map.clear();

    final list = await _storage.getAll();
    if (list.isNotEmpty) {
      final roomIds = list.map((conv) => conv.roomId).toList();
      final latestMessages = await sc.chatMessageStorage.getLatestMessages(
        roomIds,
      );
      for (final conv in list) {
        final latestMessage = latestMessages[conv.roomId];
        if (latestMessage == null) {
          sc.logger.e(
            'ConversationManager: No messages found for roomId ${conv.roomId}',
          );
        } else {
          final ex = Conversation(
            roomId: conv.roomId,
            lastMessage: latestMessage,
            readSeq: 0,
          );
          _list.add(ex);
          _map[conv.roomId] = ex;
        }
      }
    }
  }

  void listenForFriendChatMessages() {
    sc.friendChatMessageManager.stream.listen(_onFriendChatMessage);
  }

  void _onFriendChatMessage(List<ChatMessage> messages) {
    for (final message in messages) {
      Conversation? conv = _map[message.roomId];
      if (conv == null) {
        conv = Conversation(
          roomId: message.roomId,
          lastMessage: message,
          readSeq: 0,
        );

        _list.add(conv);
        _map[message.roomId] = conv;
      } else {
        if (message.seq > conv.lastMessage.seq) {
          conv.lastMessage = message;
        }
      }
    }
  }

  void tryUpdateReadSeq(int roomId, int seq) {
    Conversation? conv = _map[roomId];
    if (conv != null && seq > conv.readSeq) {
      conv.readSeq = seq;
      _notifyListeners();
    }
  }

  Future<void> onQuit() async {
    await _storage.close();
  }

  void init() {}

  /// 同步获取内存中的列表（已加载后使用）
  List<Conversation> getAll() {
    return _list;
  }

  Future<void> delete(int roomId) async {
    _list.removeWhere((conv) => conv.roomId == roomId);
    _map.remove(roomId);
    _notifyListeners();
    await _storage.delete(roomId);
  }
}
