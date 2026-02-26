enum FriendRequestResult {
  wait(0), // default for dart
  accepted(1),
  rejected(2);

  static FriendRequestResult fromCode(int code) {
    switch (code) {
      case 0:
        return FriendRequestResult.wait;
      case 1:
        return FriendRequestResult.accepted;
      case 2:
        return FriendRequestResult.rejected;
      default:
        return FriendRequestResult.wait;
    }
  }

  final int code;
  const FriendRequestResult(this.code);
}