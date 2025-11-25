class Me {
  static Me? instance;

  final String userId;
  final String userName;

  Me({required this.userId, required this.userName}) {
    instance = this;
  }

  bool isMe(String userId) {
    return this.userId == userId;
  }
}