class MsgLeaveRoom {
    // [0]
    int roomId;

    MsgLeaveRoom({
      required this.roomId,
    });

    List toMsgPack() {
      return [
        roomId,
      ];
    }

    factory MsgLeaveRoom.fromMsgPack(List list) {
      return MsgLeaveRoom(
        roomId: list[0] as int,
      );
    }
}