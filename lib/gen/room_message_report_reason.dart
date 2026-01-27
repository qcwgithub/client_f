enum RoomMessageReportReason {
  other(0), // default for dart
  spam(1),
  ads(2),
  harassment(3),
  inappropriateContent(4),
  count(5);

  static RoomMessageReportReason fromCode(int code) {
    switch (code) {
      case 0:
        return RoomMessageReportReason.other;
      case 1:
        return RoomMessageReportReason.spam;
      case 2:
        return RoomMessageReportReason.ads;
      case 3:
        return RoomMessageReportReason.harassment;
      case 4:
        return RoomMessageReportReason.inappropriateContent;
      case 5:
        return RoomMessageReportReason.count;
      default:
        return RoomMessageReportReason.other;
    }
  }

  final int code;
  const RoomMessageReportReason(this.code);
}