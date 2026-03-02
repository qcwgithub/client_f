enum SceneChatRefreshStatus { refreshing, success, error }

class SceneChatRefreshEvent {
  final SceneChatRefreshStatus status;
  SceneChatRefreshEvent(this.status);
}
