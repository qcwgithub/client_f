import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/sc.dart';

class ConversationListModel {
  final List<Conversation> conversations;

  ConversationListModel({required this.conversations});

  factory ConversationListModel.initial() {
    return ConversationListModel(conversations: []);
  }

  Conversation getAt(int index) => conversations[index];

  Conversation? getByRoomId(int roomId) {
    for (final c in conversations) {
      if (c.roomId == roomId) return c;
    }
    return null;
  }
}

class ConversationListNotifier extends StateNotifier<ConversationListModel> {
  ConversationListNotifier() : super(ConversationListModel.initial()) {
    sc.conversationManager.addListener(_onChanged);
    _load();
  }

  void _load() {
    final list = sc.conversationManager.getAll();
    state = ConversationListModel(conversations: list);
  }

  void _onChanged() {
    _load();
  }

  @override
  void dispose() {
    sc.conversationManager.removeListener(_onChanged);
    super.dispose();
  }

  void delete(int roomId) {
    sc.conversationManager.delete(roomId);
  }
}

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListModel>((
      ref,
    ) {
      return ConversationListNotifier();
    });
