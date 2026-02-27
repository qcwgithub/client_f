import 'package:scene_hub/logic/image_selector.dart';
import 'package:scene_hub/logic/image_uploader.dart';
import 'package:scene_hub/logic/managers/friend_chat_message_manager.dart';
import 'package:scene_hub/logic/message_storage.dart';
import 'package:scene_hub/logic/managers/friend_manager.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/network/server.dart';

class Sc {
  final Server server;
  final Me me;
  final ImageUploader imageUploader;
  final ImageSelector imageSelector;
  final MessageStorage messageStorage;
  final FriendManager friendManager;
  final FriendChatMessageManager friendChatMessageManager;

  Sc({
    required this.server,
    required this.me,
    required this.imageUploader,
    required this.imageSelector,
    required this.messageStorage,
    required this.friendManager,
    required this.friendChatMessageManager,
  }) {
    friendChatMessageManager.init();
  }
}

Sc createSc() {
  final server = Server();
  final me = Me();
  final imageUploader = ImageUploader();
  final imageSelector = ImageSelector();
  final messageStorage = MessageStorage();
  final friendManager = FriendManager(me: me);
  final messageManager = FriendChatMessageManager(me: me);

  return Sc(
    server: server,
    me: me,
    imageUploader: imageUploader,
    imageSelector: imageSelector,
    messageStorage: messageStorage,
    friendManager: friendManager,
    friendChatMessageManager: messageManager,
  );
}

Sc sc = createSc();
