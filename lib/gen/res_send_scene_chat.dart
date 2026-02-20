import 'package:scene_hub/i_to_msg_pack.dart';

class ResSendSceneChat implements IToMsgPack {
    ResSendSceneChat();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResSendSceneChat.fromMsgPack(List list) {
      return ResSendSceneChat(
      );
    }
}