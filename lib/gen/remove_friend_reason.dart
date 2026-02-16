enum RemoveFriendReason {
  otherRemoveYou(0); // default for dart

  static RemoveFriendReason fromCode(int code) {
    switch (code) {
      case 0:
        return RemoveFriendReason.otherRemoveYou;
      default:
        return RemoveFriendReason.otherRemoveYou;
    }
  }

  final int code;
  const RemoveFriendReason(this.code);
}