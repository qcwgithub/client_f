class MsgSetAvatarIndex {
    // [0]
    int avatarIndex;

    MsgSetAvatarIndex({
      required this.avatarIndex,
    });

    List toMsgPack() {
      return [
        avatarIndex,
      ];
    }

    factory MsgSetAvatarIndex.fromMsgPack(List list) {
      return MsgSetAvatarIndex(
        avatarIndex: list[0] as int,
      );
    }
}