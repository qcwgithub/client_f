class Conversation {
  int roomId;
  int targetUserId;
  String title;
  int avatarIndex;
  String lastMessage;
  int lastMessageTime;
  int unreadCount;

  /// 会话类型：0=好友聊天，1=场景房间聊天
  int type;

  Conversation({
    required this.roomId,
    required this.targetUserId,
    required this.title,
    required this.avatarIndex,
    this.lastMessage = '',
    this.lastMessageTime = 0,
    this.unreadCount = 0,
    this.type = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'target_user_id': targetUserId,
      'title': title,
      'avatar_index': avatarIndex,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'type': type,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      roomId: map['room_id'] as int,
      targetUserId: map['target_user_id'] as int,
      title: map['title'] as String,
      avatarIndex: map['avatar_index'] as int,
      lastMessage: map['last_message'] as String,
      lastMessageTime: map['last_message_time'] as int,
      unreadCount: map['unread_count'] as int,
      type: map['type'] as int,
    );
  }
}
