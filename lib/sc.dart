import 'package:scene_hub/logic/friend_script.dart';
import 'package:scene_hub/logic/image_selector.dart';
import 'package:scene_hub/logic/image_uploader.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/network/server.dart';

class Sc {
  Server server;
  Me me;
  ImageUploader imageUploader;
  ImageSelector imageSelector;
  FriendScript friendScript;

  Sc() {
    server = Server();
    me = Me();
    imageUploader = ImageUploader();
    imageSelector = ImageSelector();
    friendScript = FriendScript();
  }
}

final sc = Sc();
