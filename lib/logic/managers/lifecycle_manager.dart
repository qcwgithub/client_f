import 'dart:async';

import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/network/network_status.dart';
import 'package:scene_hub/sc.dart';

class LifecycleManager {
  void init() {
    sc.eventBus.on<LoginEvent>().listen(_onLogin);
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
  Future<void> quit() async {
    sc.server.stopRunningAndClose();
    while (sc.server.state != NetworkStatus.init) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    await sc.friendChatMessageManager.onQuit();
    await sc.conversationManager.onQuit();
    await sc.chatMessageStorage.onQuit();

    // 销毁所有 provider + 重建整个 app（回到 LoginPage）
    sc.resetProviders();
  }
}
