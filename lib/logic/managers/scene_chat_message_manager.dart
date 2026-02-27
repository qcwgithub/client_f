import 'dart:async';

import 'package:scene_hub/gen/chat_message.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/user_info.dart';
// import 'package:scene_hub/logic/event_bus.dart';
import 'package:scene_hub/sc.dart';

class SceneChatMessageManager {
  final _controller = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get stream => _controller.stream;

  UserInfo get userInfo => sc.me.userInfo;

  void init() {
  }

  void onMsgAChatMessage(MsgAChatMessage msg) async {
    _controller.add(msg.message);
  }
}
