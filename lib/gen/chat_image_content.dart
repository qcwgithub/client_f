import 'package:scene_hub/i_to_msg_pack.dart';

class ChatImageContent implements IToMsgPack {
    // [0]
    String url;
    // [1]
    int width;
    // [2]
    int height;
    // [3]
    int size;

    ChatImageContent({
      required this.url,
      required this.width,
      required this.height,
      required this.size,
    });

    @override
    List toMsgPack() {
      return [
        url,
        width,
        height,
        size,
      ];
    }

    factory ChatImageContent.fromMsgPack(List list) {
      return ChatImageContent(
        url: list[0] as String,
        width: list[1] as int,
        height: list[2] as int,
        size: list[3] as int,
      );
    }
}