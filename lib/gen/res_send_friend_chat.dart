import 'package:scene_hub/i_to_msg_pack.dart';

class ResSendFriendChat implements IToMsgPack {
    ResSendFriendChat();

    @override
    List toMsgPack() {
      return [
      ];
    }

    factory ResSendFriendChat.fromMsgPack(List list) {
      return ResSendFriendChat(
      );
    }
}