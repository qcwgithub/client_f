enum ChatMessageStatus {
  normal(0), // default for dart
  revoked(1);

  static ChatMessageStatus fromCode(int code) {
    switch (code) {
      case 0:
        return ChatMessageStatus.normal;
      case 1:
        return ChatMessageStatus.revoked;
      default:
        return ChatMessageStatus.normal;
    }
  }

  final int code;
  const ChatMessageStatus(this.code);
}