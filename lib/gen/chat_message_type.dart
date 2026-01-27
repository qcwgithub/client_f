enum ChatMessageType {
  unknown(0), // default for dart
  text(1),
  image(2),
  system(3),
  count(4);

  static ChatMessageType fromCode(int code) {
    switch (code) {
      case 0:
        return ChatMessageType.unknown;
      case 1:
        return ChatMessageType.text;
      case 2:
        return ChatMessageType.image;
      case 3:
        return ChatMessageType.system;
      case 4:
        return ChatMessageType.count;
      default:
        return ChatMessageType.unknown;
    }
  }

  final int code;
  const ChatMessageType(this.code);
}