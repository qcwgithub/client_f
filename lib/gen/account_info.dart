import 'package:scene_hub/i_to_msg_pack.dart';

class AccountInfo implements IToMsgPack {
    // [0]
    int isPlaceholder;
    // [1]
    String platform;
    // [2]
    String channel;
    // [3]
    String channelUserId;
    // [4]
    List<int> userIds;
    // [5]
    int createTimeS;
    // [6]
    bool block;
    // [7]
    int unblockTime;
    // [8]
    String blockPrompt;
    // [9]
    String blockOrUnblockReason;
    // [10]
    int lastLoginUserId;

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
    });

    @override
    List toMsgPack() {
      return [
        isPlaceholder,
        platform,
        channel,
        channelUserId,
        userIds,
        createTimeS,
        block,
        unblockTime,
        blockPrompt,
        blockOrUnblockReason,
        lastLoginUserId,
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
      );
    }
}