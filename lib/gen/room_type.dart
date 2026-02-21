enum RoomType {
  scene(0), // default for dart
  private(1),
  count(2);

  static RoomType fromCode(int code) {
    switch (code) {
      case 0:
        return RoomType.scene;
      case 1:
        return RoomType.private;
      case 2:
        return RoomType.count;
      default:
        return RoomType.scene;
    }
  }

  final int code;
  const RoomType(this.code);
}