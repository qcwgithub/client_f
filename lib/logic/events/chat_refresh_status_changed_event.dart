enum ChatRefreshStatus { refreshing, success, error }

class ChatRefreshStatusChangedEvent {
  final ChatRefreshStatus status;
  ChatRefreshStatusChangedEvent(this.status);
}
