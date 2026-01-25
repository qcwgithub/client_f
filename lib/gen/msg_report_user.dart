class MsgReportUser {
    // [0]
    int targetUserId;
    // [1]
    UserReportReason reason;

    MsgReportUser({
      required this.targetUserId,
      required this.reason,
    });

    List toMsgPack() {
      return [
        targetUserId,
        reason,
      ];
    }

    factory MsgReportUser.fromMsgPack(List list) {
      return MsgReportUser(
        targetUserId: list[0] as int,
        reason: list[1] as UserReportReason,
      );
    }
}