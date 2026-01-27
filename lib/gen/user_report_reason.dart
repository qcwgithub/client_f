enum UserReportReason {
  other(0), // default for dart
  spam(1),
  ads(2),
  harassment(3),
  inappropriateContent(4),
  count(5);

  static UserReportReason fromCode(int code) {
    switch (code) {
      case 0:
        return UserReportReason.other;
      case 1:
        return UserReportReason.spam;
      case 2:
        return UserReportReason.ads;
      case 3:
        return UserReportReason.harassment;
      case 4:
        return UserReportReason.inappropriateContent;
      case 5:
        return UserReportReason.count;
      default:
        return UserReportReason.other;
    }
  }

  final int code;
  const UserReportReason(this.code);
}