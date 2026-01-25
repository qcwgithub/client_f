class MsgSetName {
    // [0]
    String userName;

    MsgSetName({
      required this.userName,
    });

    List toMsgPack() {
      return [
        userName,
      ];
    }

    factory MsgSetName.fromMsgPack(List list) {
      return MsgSetName(
        userName: list[0] as String,
      );
    }
}