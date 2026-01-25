class RoomInfo {
    int roomId;
    int createTimeS;
    String title;
    String desc;
    int messageId;

    RoomInfo({
      required this.roomId,
      required this.createTimeS,
      required this.title,
      required this.desc,
      required this.messageId,
    });

    List toMsgPack() {
      return [
        roomId, // [0]
        createTimeS, // [1]
        title, // [2]
        desc, // [3]
        messageId, // [4]
      ];
    }

    factory RoomInfo.fromMsgPack(List list) {
      return RoomInfo(
        roomId: list[0] as int, // [0]
        createTimeS: list[1] as int, // [1]
        title: list[2] as String, // [2]
        desc: list[3] as String, // [3]
        messageId: list[4] as int, // [4]
      );
    }
}