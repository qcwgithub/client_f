import 'dart:async';

import 'package:scene_hub/logic/events/login_event.dart';
import 'package:scene_hub/main.dart';
import 'package:scene_hub/network/network_status.dart';
import 'package:scene_hub/providers/nav_provider.dart';
import 'package:scene_hub/sc.dart';

class LifecycleManager {
  StreamSubscription<LoginEvent>? _loginSub;
  void init() {
    _loginSub = sc.eventBus.on<LoginEvent>().listen(_onLogin);
  }

  void _onLogin(LoginEvent event) async {
    if (event.count == 1) {
      await sc.chatMessageStorage.open();
      await sc.conversationManager.openStorageAndInitialLoad();

      // bussiness
      await sc.friendChatMessageManager.firstLoginReceive();

      // 都搞定了才进去
      globalContainer.read(navProvider.notifier).state = 1;
    }
  }

  Future<void> quit() async {
    _loginSub?.cancel();
    _loginSub = null;

    sc.server.stopRunningAndClose();
    while (sc.server.state != NetworkStatus.init) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    await sc.friendChatMessageManager.onQuit();

    await sc.conversationManager.onQuit();
    await sc.chatMessageStorage.onQuit();

    // TEMP
    globalContainer.read(navProvider.notifier).state = 0;
  }
}
