class MsgSearchRoom {
    // [0]
    String keyword;

    MsgSearchRoom({
      required this.keyword,
    });

    List toMsgPack() {
      return [
        keyword,
      ];
    }

    factory MsgSearchRoom.fromMsgPack(List list) {
      return MsgSearchRoom(
        keyword: list[0] as String,
      );
    }
}