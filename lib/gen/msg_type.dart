enum MsgType {
  clientStart(10000), // default for dart
  forward(10001),
  login(10002),
  kick(10003),
  enterRoom(10004),
  leaveRoom(10005),
  sendRoomChat(10006),
  a_RoomChat(10007),
  searchRoom(10008),
  getRecommendedRooms(10009),
  setName(10010),
  setAvatarIndex(10011),
  getRoomChatHistory(10012),
  reportRoomMessage(10013),
  reportUser(10014);

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
        return MsgType.enterRoom;
      case 10005:
        return MsgType.leaveRoom;
      case 10006:
        return MsgType.sendRoomChat;
      case 10007:
        return MsgType.a_RoomChat;
      case 10008:
        return MsgType.searchRoom;
      case 10009:
        return MsgType.getRecommendedRooms;
      case 10010:
        return MsgType.setName;
      case 10011:
        return MsgType.setAvatarIndex;
      case 10012:
        return MsgType.getRoomChatHistory;
      case 10013:
        return MsgType.reportRoomMessage;
      case 10014:
        return MsgType.reportUser;
      default:
        return MsgType.clientStart;
    }
  }

  final int code;
  const MsgType(this.code);
}