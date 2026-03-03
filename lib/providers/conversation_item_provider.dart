import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/conversation.dart';
import 'package:scene_hub/providers/conversation_list_provider.dart';

/// 按 roomId 精准选取单条 Conversation
final conversationItemProvider =
    Provider.family<Conversation, int>((ref, roomId) {
      return ref.watch(
        conversationListProvider.select((model) {
          return model.getByRoomId(roomId)!;
        }),
      );
    });
