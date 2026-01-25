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
      ];
    }

    factory AccountInfo.fromMsgPack(List list) {
      return AccountInfo(
        isPlaceholder: list[0] as int, // [0]
        platform: list[1] as String, // [1]
        channel: list[2] as String, // [2]
        channelUserId: list[3] as String, // [3]
        userIds: List<int>.from(list[4], growable: true), // [4]
        createTimeS: list[5] as int, // [5]
        block: list[6] as bool, // [6]
        unblockTime: list[7] as int, // [7]
        blockPrompt: list[8] as String, // [8]
        blockOrUnblockReason: list[9] as String, // [9]
        lastLoginUserId: list[10] as int, // [10]
      );
    }
}