import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/gen/msg_a_other_accept_friend_request.dart';
import 'package:scene_hub/gen/msg_a_other_reject_friend_request.dart';
import 'package:scene_hub/gen/msg_a_receive_friend_request.dart';
import 'package:scene_hub/gen/msg_a_remove_friend.dart';
import 'package:scene_hub/gen/msg_send_friend_request.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/outgoing_friend_request.dart';
import 'package:scene_hub/gen/res_send_friend_request.dart';
import 'package:scene_hub/gen/user_info.dart';
import 'package:collection/collection.dart';
import 'package:scene_hub/sc.dart';

class FriendManager {
  UserInfo get _userInfo => sc.me.userInfo;
  List<FriendInfo> get _friends => sc.me.userInfo.friends;
  List<FriendInfo> get _removedFriends => sc.me.userInfo.removedFriends;

  bool isFriend(int userId) {
    return _friends.any((f) => f.userId == userId);
  }

  FriendInfo? getFriendByRoomId(int roomId) {
    return _friends.firstWhereOrNull((f) => f.roomId == roomId);
  }

  FriendInfo? getFriend(int friendUserId) {
    return _friends.firstWhereOrNull((f) => f.userId == friendUserId);
  }

  void addFriend(FriendInfo friendInfo) {
    int index = _friends.indexWhere((f) => f.userId == friendInfo.userId);
    if (index == -1) {
      _friends.add(friendInfo);
    } else {
      _friends[index] = friendInfo;
    }

    // 从 removedFriends 中移除对应 userId
    _removedFriends.removeWhere((f) => f.userId == friendInfo.userId);
  }

  void removeFriend(FriendInfo friendInfo) {
    int index = _removedFriends.indexWhere(
      (f) => f.userId == friendInfo.userId,
    );
    if (index == -1) {
      _removedFriends.add(friendInfo);
    } else {
      _removedFriends[index] = friendInfo;
    }

    _friends.removeWhere((f) => f.userId == friendInfo.userId);
  }

  void _addOutgoingFrendRequest(OutgoingFriendRequest req) {
    final index = _userInfo.outgoingFriendRequests.indexWhere(
      (r) => r.toUserId == req.toUserId,
    );
    if (index == -1) {
      _userInfo.outgoingFriendRequests.add(req);
    } else {
      _userInfo.outgoingFriendRequests[index] = req;
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

  void onMsgAReceiveFriendRequest(MsgAReceiveFriendRequest msg) {}

  void onMsgAOtherAcceptFriendRequest(MsgAOtherAcceptFriendRequest msg) {}

  void onMsgAOtherRejectFriendRequest(MsgAOtherRejectFriendRequest msg) {}

  void onMsgARemoveFriend(MsgARemoveFriend msg) {}
}
