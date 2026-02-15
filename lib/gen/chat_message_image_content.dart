import 'package:scene_hub/i_to_msg_pack.dart';

class ChatMessageImageContent implements IToMsgPack {
    // [0]
    String url;
    // [1]
    int width;
    // [2]
    int height;
    // [3]
    int size;
    // [4]
    String thumbnailUrl;

    ChatMessageImageContent({
      required this.url,
      required this.width,
      required this.height,
      required this.size,
      required this.thumbnailUrl,
    });

    @override
    List toMsgPack() {
      return [
        url,
        width,
        height,
        size,
        thumbnailUrl,
      ];
    }

    factory ChatMessageImageContent.fromMsgPack(List list) {
      return ChatMessageImageContent(
        url: list[0] as String,
        width: list[1] as int,
        height: list[2] as int,
        size: list[3] as int,
        thumbnailUrl: list[4] as String,
      );
    }
}