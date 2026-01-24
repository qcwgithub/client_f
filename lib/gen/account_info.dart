import 'package:scene_hub/gen/user_info.dart';

class AccountInfo {
    int isPlaceholder;
    String platform;
    String channel;
    String channelUserId;
    List<int> userIds;
    int createTimeS;
    bool block;
    int unblockTime;
    String blockPrompt;
    String blockOrUnblockReason;
    int lastLoginUserId;
    List<UserInfo> testUserInfos;

    AccountInfo({
      required this.isPlaceholder,
      required this.platform,
      required this.channel,
      required this.channelUserId,
      required this.userIds,
      required this.createTimeS,
      required this.block,
      required this.unblockTime,
      required this.blockPrompt,
      required this.blockOrUnblockReason,
      required this.lastLoginUserId,
      required this.testUserInfos,
    });

    List toMsgPack() {
      return [
        isPlaceholder, // [0]
        platform, // [1]
        channel, // [2]
        channelUserId, // [3]
        userIds, // [4]
        createTimeS, // [5]
        block, // [6]
        unblockTime, // [7]
        blockPrompt, // [8]
        blockOrUnblockReason, // [9]
        lastLoginUserId, // [10]
        testUserInfos, // [11]
      ];
    }

    factory AccountInfo.fromMsgPack(List list) {
      return AccountInfo(
        isPlaceholder: list[0] as int,
        platform: list[1] as String,
        channel: list[2] as String,
        channelUserId: list[3] as String,
        userIds: List<int>.from(list[4], growable: true),
        createTimeS: list[5] as int,
        block: list[6] as bool,
        unblockTime: list[7] as int,
        blockPrompt: list[8] as String,
        blockOrUnblockReason: list[9] as String,
        lastLoginUserId: list[10] as int,
        testUserInfos: (list[11] as List)
          .map((e) => UserInfo.fromMsgPack(e as List))
          .toList(growable: true),
      );
    }
}