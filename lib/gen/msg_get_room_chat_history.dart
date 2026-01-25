class MsgGetRoomChatHistory {
    // [0]
    int roomId;
    // [1]
    int lastMessageId;

    MsgGetRoomChatHistory({
      required this.roomId,
      required this.lastMessageId,
    });

    List toMsgPack() {
      return [
        roomId,
        lastMessageId,
      ];
    }

    factory MsgGetRoomChatHistory.fromMsgPack(List list) {
      return MsgGetRoomChatHistory(
        roomId: list[0] as int,
        lastMessageId: list[1] as int,
      );
    }
}