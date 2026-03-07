class ConversationUnreadCountChangedEvent {
  final int roomId;
  final int unreadCount;

  ConversationUnreadCountChangedEvent(this.roomId, this.unreadCount);
}
