import 'dart:async';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/user_info.dart';
import 'package:scene_hub/logic/event_bus.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/sc.dart';

class FriendChatMessageManager {
  final Me me;
  final _controller = StreamController<ChatMessage>.broadcast();
  FriendChatMessageManager({required this.me});

  UserInfo get userInfo => me.userInfo;

  StreamSubscription<MsgAChatMessage>? _aChatSubscription;
  void init() {
    _aChatSubscription = eventBus.on<MsgAChatMessage>().listen(_onAChatMessage);
  }

  void _onAChatMessage(MsgAChatMessage aChatMessage) async {
    ChatMessage message = aChatMessage.message;
    if (!sc.friendManager.isFriendChatRoomId(message.roomId)) {
      return;
    }


  }
}
