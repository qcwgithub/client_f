import 'package:scene_hub/logic/image_selector.dart';
import 'package:scene_hub/logic/image_uploader.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/network/server.dart';

class sc {
  static final Server server = Server();
  static final Me me = Me();
  static final imageUploader = ImageUploader();
  static final imageSelector = ImageSelector();
}
