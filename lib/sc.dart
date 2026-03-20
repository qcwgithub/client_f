import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/web.dart';
import 'package:scene_hub/logic/event_bus.dart';
import 'package:scene_hub/logic/image_selector.dart';
import 'package:scene_hub/logic/image_uploader.dart';
import 'package:scene_hub/logic/managers/lifecycle_manager.dart';
import 'package:scene_hub/logic/managers/friend_chat_message_manager.dart';
import 'package:scene_hub/logic/storage/chat_message_storage.dart';
import 'package:scene_hub/logic/managers/friend_manager.dart';
import 'package:scene_hub/logic/managers/msg_handler.dart';
import 'package:scene_hub/logic/managers/scene_chat_message_manager.dart';
import 'package:scene_hub/logic/managers/conversation_manager.dart';
import 'package:scene_hub/logic/managers/post_frame_callback_manager.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/network/server.dart';

/// 通知 app 重建（切换 ProviderContainer）
final appRebuildNotifier = ValueNotifier<int>(0);

class Sc {
  final EventBus eventBus = EventBus();
  final Logger logger = Logger(
    filter: null,
    printer: PrettyPrinter(
      // methodCount: 8,
      // errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
  final Server server = Server();
  final Me me = Me();
  final LifecycleManager lifecycleManager = LifecycleManager();
  final MsgHandler msgHandler = MsgHandler();

  final ImageUploader imageUploader = ImageUploader();
  final ImageSelector imageSelector = ImageSelector();
  final ChatMessageStorage chatMessageStorage = ChatMessageStorage();
  final FriendManager friendManager = FriendManager();
  final FriendChatMessageManager friendChatMessageManager =
      FriendChatMessageManager();
  final SceneChatMessageManager sceneChatMessageManager =
      SceneChatMessageManager();
  final ConversationManager conversationManager = ConversationManager();
  final PostFrameCallbackManager postFrameCallbackManager =
      PostFrameCallbackManager();

  ProviderContainer container = ProviderContainer();

  /// 销毁所有 provider，创建新的空 container，通知 app 重建
  void resetProviders() {
    container.dispose();
    container = ProviderContainer();
    appRebuildNotifier.value++;
  }

  // 全局调用1次
  void init() {
    lifecycleManager.init();
    friendChatMessageManager.init();
    sceneChatMessageManager.init();
  }
}

final sc = Sc();
