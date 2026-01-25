class ResSetName {
    // [0]
    String userName;

    ResSetName({
      required this.userName,
    });

    List toMsgPack() {
      return [
        userName,
      ];
    }

    factory ResSetName.fromMsgPack(List list) {
      return ResSetName(
        userName: list[0] as String,
      );
    }
}