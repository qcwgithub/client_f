import 'package:scene_hub/i_to_msg_pack.dart';

class ResSendPrivateChat implements IToMsgPack {
    ResSendPrivateChat();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResSendPrivateChat.fromMsgPack(List list) {
      return ResSendPrivateChat(
      );
    }
}