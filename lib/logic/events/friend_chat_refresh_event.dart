enum FriendChatRefreshStatus { refreshing, success, error }

class FriendChatRefreshEvent {
  final FriendChatRefreshStatus status;
  FriendChatRefreshEvent(this.status);
}
