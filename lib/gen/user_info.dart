import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/gen/friend_info.dart';
import 'package:scene_hub/gen/outgoing_friend_request.dart';
import 'package:scene_hub/gen/incoming_friend_request.dart';
import 'package:scene_hub/gen/blocked_user.dart';

class UserInfo implements IToMsgPack {
    // [0]
    int userId;
    // [1]
    String userName;
    // [2]
    int createTimeS;
    // [3]
    int lastLoginTimeS;
    // [4]
    int lastSetNameTimeS;
    // [5]
    int avatarIndex;
    // [6]
    int lastSetAvatarIndexTimeS;
    // [7]
    List<FriendInfo> friends;
    // [8]
    List<OutgoingFriendRequest> outgoingFriendRequests;
    // [9]
    List<IncomingFriendRequest> incomingFriendRequests;
    // [10]
    List<BlockedUser> blockedUsers;
    // [11]
    List<FriendInfo> removedFriends;

    UserInfo({
      required this.userId,
      required this.userName,
      required this.createTimeS,
      required this.lastLoginTimeS,
      required this.lastSetNameTimeS,
      required this.avatarIndex,
      required this.lastSetAvatarIndexTimeS,
      required this.friends,
      required this.outgoingFriendRequests,
      required this.incomingFriendRequests,
      required this.blockedUsers,
      required this.removedFriends,
    });

    @override
    List toMsgPack() {
      return [
        userId,
        userName,
        createTimeS,
        lastLoginTimeS,
        lastSetNameTimeS,
        avatarIndex,
        lastSetAvatarIndexTimeS,
        friends.map((e) => e.toMsgPack()).toList(growable: false),
        outgoingFriendRequests.map((e) => e.toMsgPack()).toList(growable: false),
        incomingFriendRequests.map((e) => e.toMsgPack()).toList(growable: false),
        blockedUsers.map((e) => e.toMsgPack()).toList(growable: false),
        removedFriends.map((e) => e.toMsgPack()).toList(growable: false),
      ];
    }

    factory UserInfo.fromMsgPack(List list) {
      return UserInfo(
        userId: list[0] as int,
        userName: list[1] as String,
        createTimeS: list[2] as int,
        lastLoginTimeS: list[3] as int,
        lastSetNameTimeS: list[4] as int,
        avatarIndex: list[5] as int,
        lastSetAvatarIndexTimeS: list[6] as int,
        friends: (list[7] as List)
          .map((e) => FriendInfo.fromMsgPack(e as List))
          .toList(growable: true),
        outgoingFriendRequests: (list[8] as List)
          .map((e) => OutgoingFriendRequest.fromMsgPack(e as List))
          .toList(growable: true),
        incomingFriendRequests: (list[9] as List)
          .map((e) => IncomingFriendRequest.fromMsgPack(e as List))
          .toList(growable: true),
        blockedUsers: (list[10] as List)
          .map((e) => BlockedUser.fromMsgPack(e as List))
          .toList(growable: true),
        removedFriends: (list[11] as List)
          .map((e) => FriendInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}