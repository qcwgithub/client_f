class MsgReportRoomMessage {
    // [0]
    int roomId;
    // [1]
    int messageId;
    // [2]
    RoomMessageReportReason reason;

    MsgReportRoomMessage({
      required this.roomId,
      required this.messageId,
      required this.reason,
    });

    List toMsgPack() {
      return [
        roomId,
        messageId,
        reason,
      ];
    }

    factory MsgReportRoomMessage.fromMsgPack(List list) {
      return MsgReportRoomMessage(
        roomId: list[0] as int,
        messageId: list[1] as int,
        reason: list[2] as RoomMessageReportReason,
      );
    }
}