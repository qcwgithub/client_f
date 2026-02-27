import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/gen/msg_send_friend_request.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/outgoing_friend_request.dart';
import 'package:scene_hub/gen/res_send_friend_request.dart';
import 'package:scene_hub/gen/user_info.dart';
import 'package:collection/collection.dart';
import 'package:scene_hub/me.dart';
import 'package:scene_hub/sc.dart';

class FriendManager {
  final Me me;
  FriendManager({required this.me});

  UserInfo get userInfo => me.userInfo;

  bool isFriendChatRoomId(int roomId) {
    if (userInfo.friends.any((f) => f.roomId == roomId)) {
      return true;
    }

    if (userInfo.removedFriends.any((f) => f.roomId == roomId)) {
      return true;
    }

    return false;
  }

  bool isFriend(int userId) {
    return userInfo.friends.any((f) => f.userId == userId);
  }

  FriendInfo? getFriend(int friendUserId) {
    return userInfo.friends.firstWhereOrNull((f) => f.userId == friendUserId);
  }

  void addFriend(FriendInfo friendInfo) {
    int index = userInfo.friends.indexWhere(
      (f) => f.userId == friendInfo.userId,
    );
    if (index == -1) {
      userInfo.friends.add(friendInfo);
    } else {
      userInfo.friends[index] = friendInfo;
    }

    // 从 removedFriends 中移除对应 userId
    userInfo.removedFriends.removeWhere((f) => f.userId == friendInfo.userId);
  }

  void removeFriend(FriendInfo friendInfo) {
    int index = userInfo.removedFriends.indexWhere(
      (f) => f.userId == friendInfo.userId,
    );
    if (index == -1) {
      userInfo.removedFriends.add(friendInfo);
    } else {
      userInfo.removedFriends[index] = friendInfo;
    }

    userInfo.friends.removeWhere((f) => f.userId == friendInfo.userId);
  }

  void _addOutgoingFrendRequest(OutgoingFriendRequest req) {
    final index = userInfo.outgoingFriendRequests.indexWhere(
      (r) => r.toUserId == req.toUserId,
    );
    if (index == -1) {
      userInfo.outgoingFriendRequests.add(req);
    } else {
      userInfo.outgoingFriendRequests[index] = req;
    }
  }

  Future<ECode> sendFriendRequest(int toUserId) async {
    final r = await sc.server.request(
      MsgType.sendFriendRequest,
      MsgSendFriendRequest(toUserId: toUserId, say: ''),
    );

    if (r.e == ECode.success) {
      var res = ResSendFriendRequest.fromMsgPack(r.res!);
      _addOutgoingFrendRequest(res.req);
    }
    return r.e;
  }
}
