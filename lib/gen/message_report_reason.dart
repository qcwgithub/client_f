enum MessageReportReason {
  other(0), // default for dart
  spam(1),
  ads(2),
  harassment(3),
  inappropriateContent(4),
  count(5);

  static MessageReportReason fromCode(int code) {
    switch (code) {
      case 0:
        return MessageReportReason.other;
      case 1:
        return MessageReportReason.spam;
      case 2:
        return MessageReportReason.ads;
      case 3:
        return MessageReportReason.harassment;
      case 4:
        return MessageReportReason.inappropriateContent;
      case 5:
        return MessageReportReason.count;
      default:
        return MessageReportReason.other;
    }
  }

  final int code;
  const MessageReportReason(this.code);
}