import 'dart:async';

import 'package:flutter/foundation.dart';
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

  List<Conversation>? _conversationList;
  final Map<int, Conversation> _conversationMap = {};

  Future<void> onFirstLogin() async {
    await _storage.open(sc.me.userId);

    _conversationList = await _storage.getAll();
    _conversationMap.clear();
    for (final conv in _conversationList!) {
      _conversationMap[conv.roomId] = conv;
    }
  }

  Future<void> onQuit() async {
    await _storage.close();
  }

  void init() {}

  /// 同步获取内存中的列表（已加载后使用）
  List<Conversation> getAll() {
    return _conversationList ?? [];
  }

  void delete(int roomId) async {
    _conversationList?.removeWhere((conv) => conv.roomId == roomId);
    _conversationMap.remove(roomId);
    _notifyListeners();
    await _storage.delete(roomId);
  }

  void clearUnread(int roomId) async {
    final conversation = _conversationMap[roomId];
    if (conversation != null) {
      conversation.unreadCount = 0;
      _notifyListeners();
      await _storage.clearUnread(roomId);
    }
  }

  void upsert(Conversation conv) {
    final index = _conversationList!.indexWhere((c) => c.roomId == conv.roomId);
    if (index != -1) {
      _conversationList![index] = conv;
    } else {
      _conversationList?.add(conv);
    }
    _conversationMap[conv.roomId] = conv;
    _notifyListeners();
    _storage.upsert(conv);
  }
}
