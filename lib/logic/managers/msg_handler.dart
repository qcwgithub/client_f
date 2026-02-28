import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/gen/msg_a_chat_message.dart';
import 'package:scene_hub/gen/msg_a_other_accept_friend_request.dart';
import 'package:scene_hub/gen/msg_a_other_reject_friend_request.dart';
import 'package:scene_hub/gen/msg_a_receive_friend_request.dart';
import 'package:scene_hub/gen/msg_a_remove_friend.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/sc.dart';

class MsgHandler {
  void handle(MsgType msgType, List raw) {
    sc.logger.d("received $msgType");

    switch (msgType) {
      case MsgType.aChatMessage:
        {
          final msg = MsgAChatMessage.fromMsgPack(raw);
          FriendInfo? friendInfo = sc.friendManager.getFriendByRoomId(
            msg.message.roomId,
          );
          if (friendInfo != null) {
            sc.friendChatMessageManager.onMsgAChatMessage(msg, friendInfo);
          } else {
            sc.sceneChatMessageManager.onMsgAChatMessage(msg);
          }
        }
        break;

      case MsgType.aReceiveFriendRequest:
        {
          final msg = MsgAReceiveFriendRequest.fromMsgPack(raw);
          sc.friendManager.onMsgAReceiveFriendRequest(msg);
        }
        break;

      case MsgType.aOtherAcceptFriendRequest:
        {
          final msg = MsgAOtherAcceptFriendRequest.fromMsgPack(raw);
          sc.friendManager.onMsgAOtherAcceptFriendRequest(msg);
        }
        break;

      case MsgType.aOtherRejectFriendRequest:
        {
          final msg = MsgAOtherRejectFriendRequest.fromMsgPack(raw);
          sc.friendManager.onMsgAOtherRejectFriendRequest(msg);
        }
        break;

      case MsgType.aRemoveFriend:
        {
          final msg = MsgARemoveFriend.fromMsgPack(raw);
          sc.friendManager.onMsgARemoveFriend(msg);
        }
        break;

      default:
        sc.logger.e("unknown msg type: $msgType");
        break;
    }
  }
}
