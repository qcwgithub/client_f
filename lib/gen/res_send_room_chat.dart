import 'package:scene_hub/i_to_msg_pack.dart';

class ResSendRoomChat implements IToMsgPack {
    ResSendRoomChat();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResSendRoomChat.fromMsgPack(List list) {
      return ResSendRoomChat(
      );
    }
}