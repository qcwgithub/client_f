enum ChatRefreshStatus { refreshing, success, error }

class ChatRefreshEvent {
  final ChatRefreshStatus status;
  ChatRefreshEvent(this.status);
}
