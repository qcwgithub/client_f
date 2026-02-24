enum MsgType {
  clientStart(10000), // default for dart
  forward(10001),
  login(10002),
  kick(10003),
  enterScene(10004),
  leaveScene(10005),
  sendSceneChat(10006),
  aChatMessage(10007),
  searchScene(10008),
  getRecommendedScenes(10009),
  setName(10010),
  setAvatarIndex(10011),
  getSceneChatHistory(10012),
  reportMessage(10013),
  reportUser(10014),
  sendFriendRequest(10015),
  rejectFriendRequest(10016),
  acceptFriendRequest(10017),
  blockUser(10018),
  unblockUser(10019),
  removeFriend(10020),
  aReceiveFriendRequest(10021),
  aOtherAcceptFriendRequest(10022),
  aOtherRejectFriendRequest(10023),
  aRemoveFriend(10024),
  getUserBriefInfos(10025),
  sendFriendChat(10026),
  getFriendChatUnreadMessages(10027),
  ackFriendChatReadSeq1(10028),
  ackFriendChatReadSeqN(10029),
  count(10030);

  static MsgType fromCode(int code) {
    switch (code) {
      case 10000:
        return MsgType.clientStart;
      case 10001:
        return MsgType.forward;
      case 10002:
        return MsgType.login;
      case 10003:
        return MsgType.kick;
      case 10004:
        return MsgType.enterScene;
      case 10005:
        return MsgType.leaveScene;
      case 10006:
        return MsgType.sendSceneChat;
      case 10007:
        return MsgType.aChatMessage;
      case 10008:
        return MsgType.searchScene;
      case 10009:
        return MsgType.getRecommendedScenes;
      case 10010:
        return MsgType.setName;
      case 10011:
        return MsgType.setAvatarIndex;
      case 10012:
        return MsgType.getSceneChatHistory;
      case 10013:
        return MsgType.reportMessage;
      case 10014:
        return MsgType.reportUser;
      case 10015:
        return MsgType.sendFriendRequest;
      case 10016:
        return MsgType.rejectFriendRequest;
      case 10017:
        return MsgType.acceptFriendRequest;
      case 10018:
        return MsgType.blockUser;
      case 10019:
        return MsgType.unblockUser;
      case 10020:
        return MsgType.removeFriend;
      case 10021:
        return MsgType.aReceiveFriendRequest;
      case 10022:
        return MsgType.aOtherAcceptFriendRequest;
      case 10023:
        return MsgType.aOtherRejectFriendRequest;
      case 10024:
        return MsgType.aRemoveFriend;
      case 10025:
        return MsgType.getUserBriefInfos;
      case 10026:
        return MsgType.sendFriendChat;
      case 10027:
        return MsgType.getFriendChatUnreadMessages;
      case 10028:
        return MsgType.ackFriendChatReadSeq1;
      case 10029:
        return MsgType.ackFriendChatReadSeqN;
      case 10030:
        return MsgType.count;
      default:
        return MsgType.clientStart;
    }
  }

  final int code;
  const MsgType(this.code);
}