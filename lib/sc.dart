import 'package:scene_hub/logic/image_selector.dart';
import 'package:scene_hub/logic/image_uploader.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/network/server.dart';

class Sc {
  final Server server;
  final Me me;
  final ImageUploader imageUploader;
  final ImageSelector imageSelector;

  Sc()
      : server = Server(),
        me = Me(),
        imageUploader = ImageUploader(),
        imageSelector = ImageSelector();
}

final sc = Sc();
