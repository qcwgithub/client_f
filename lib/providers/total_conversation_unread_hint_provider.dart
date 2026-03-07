import 'package:flutter_riverpod/legacy.dart';
import 'package:scene_hub/sc.dart';

class TotalConversationUnreadHintNotifier extends StateNotifier<int> {
  TotalConversationUnreadHintNotifier() : super(0) {
    state = sc.conversationManager.getTotalUnreadCount();

    sc.conversationManager.totalUnreadCountChanged.on(
      _onTotalUnreadCountChanged,
    );
  }

  void _onTotalUnreadCountChanged(int totalUnreadCount) {
    state = totalUnreadCount;
  }

  @override
  void dispose() {
    sc.conversationManager.totalUnreadCountChanged.off(
      _onTotalUnreadCountChanged,
    );
    super.dispose();
  }
}

final totalConversationUnreadHintProvider =
    StateNotifierProvider<TotalConversationUnreadHintNotifier, int>(
      (ref) => TotalConversationUnreadHintNotifier(),
    );
