enum FriendRequestResult {
  wait(0), // default for dart
  accepted(0),
  rejected(0);

  static FriendRequestResult fromCode(int code) {
    switch (code) {
      case 0:
        return FriendRequestResult.wait;
      case 0:
        return FriendRequestResult.accepted;
      case 0:
        return FriendRequestResult.rejected;
      default:
        return FriendRequestResult.wait;
    }
  }

  final int code;
  const FriendRequestResult(this.code);
}