import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/network/network_status.dart';
import 'package:scene_hub/pages/login_page.dart';
import 'package:scene_hub/providers/enter_scene_provider.dart';
import 'package:scene_hub/providers/friend_chat_message_provider.dart';
import 'package:scene_hub/providers/friend_chat_messages_provider.dart';
import 'package:scene_hub/providers/scene_chat_message_provider.dart';
import 'package:scene_hub/providers/scene_chat_messages_provider.dart';
import 'package:scene_hub/providers/scene_list_provider.dart';
import 'package:scene_hub/providers/search_keyword_provider.dart';
import 'package:scene_hub/sc.dart';

class LifecycleManager {
  StreamSubscription<LoginEvent>? _loginSub;
  void init() {
    _loginSub = sc.eventBus.on<LoginEvent>().listen(_onLogin);
  }

  void _onLogin(LoginEvent event) async {
    if (event.count == 1) {
      await sc.chatMessageStorage.open();
      await sc.conversationManager.openStorage();
      await sc.conversationManager.initialLoad();
      sc.conversationManager.listenForFriendChatMessages();

      // bussiness
      await sc.friendChatMessageManager.requestReceiveFriendChatMessages();
    }
  }

  // 退出到登录页
  Future<void> quit(BuildContext context, WidgetRef ref) async {
    sc.server.stopRunningAndClose();
    while (sc.server.state != NetworkStatus.init) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    await sc.friendChatMessageManager.onQuit();

    await sc.conversationManager.onQuit();
    await sc.chatMessageStorage.onQuit();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );

    ref.invalidate(friendChatMessageProvider);
    ref.invalidate(friendChatMessagesProvider);
    ref.invalidate(sceneChatMessageProvider);
    ref.invalidate(sceneChatMessagesProvider);
    ref.invalidate(enterSceneProvider);
    ref.invalidate(sceneListProvider);
    ref.invalidate(searchKeywordProvider);
  }
}
