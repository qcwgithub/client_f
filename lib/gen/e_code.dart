enum ECode {
  success(0),
  noAvailableUserService(1),
  accountNotExist(2),
  invalidPassword(3),
  userNotExist(5),
  roomNotExist(6),
  serverNotReady(8),
  exception(14),
  invalidParam(17),
  error(21), // default for dart
  serviceIsShuttingDown(23),
  userDestroying(25),
  serviceConfigError(31),
  blocked(32),
  delayLogin(33),
  userInfoNotExist(34),
  serverBusy(44),
  timeout(45),
  notConnected(46),
  roomInfoNotExist(47),
  invalidChannel(85),
  dBErrorAffectedRowCount(86),
  redisLockFail(87),
  msgProcessing(88),
  monitorRunLoop(89),
  notEnoughCount(90),
  roomLocationNotExist(91),
  alreadyIs(92),
  noAvailableRoomService(93),
  retryFailed(95),
  wrongRoomId(96),
  userNotInRoom(97),
  noHandler(98),
  invalidRoomId(99),
  fileNotExist(100),
  chat_TooFast(101),
  notSupported(102),
  nameTooShort(103),
  nameTooLong(104),
  nameReserved(105),
  nameEmpty(106),
  nameInvalidChar(107),
  nameTooFrequent(108),
  chatInvalidType(109),
  chatEmpty(110),
  chatTooShort(111),
  chatTooLong(112),
  chatAllSpace(113),
  searchTooShort(114),
  searchTooLong(115),
  avatarIndex_TooFrequent(116),
  avatarIndex_OutOfRange(117),
  chatMissingImageContent(118),
  alreadyFriends(119),
  invalidUserId(120),
  outgoingFriendRequestNotExist(121),
  friendRequestResultNotWait(122),
  incomingFriendRequestNotExist(123),
  outgoingFriendRequestAlreadyExist(124),
  notFriends(125),
  duplicate(126),
  invalidRoomType(127);

  static ECode fromCode(int code) {
    switch (code) {
      case 0:
        return ECode.success;
      case 1:
        return ECode.noAvailableUserService;
      case 2:
        return ECode.accountNotExist;
      case 3:
        return ECode.invalidPassword;
      case 5:
        return ECode.userNotExist;
      case 6:
        return ECode.roomNotExist;
      case 8:
        return ECode.serverNotReady;
      case 14:
        return ECode.exception;
      case 17:
        return ECode.invalidParam;
      case 21:
        return ECode.error;
      case 23:
        return ECode.serviceIsShuttingDown;
      case 25:
        return ECode.userDestroying;
      case 31:
        return ECode.serviceConfigError;
      case 32:
        return ECode.blocked;
      case 33:
        return ECode.delayLogin;
      case 34:
        return ECode.userInfoNotExist;
      case 44:
        return ECode.serverBusy;
      case 45:
        return ECode.timeout;
      case 46:
        return ECode.notConnected;
      case 47:
        return ECode.roomInfoNotExist;
      case 85:
        return ECode.invalidChannel;
      case 86:
        return ECode.dBErrorAffectedRowCount;
      case 87:
        return ECode.redisLockFail;
      case 88:
        return ECode.msgProcessing;
      case 89:
        return ECode.monitorRunLoop;
      case 90:
        return ECode.notEnoughCount;
      case 91:
        return ECode.roomLocationNotExist;
      case 92:
        return ECode.alreadyIs;
      case 93:
        return ECode.noAvailableRoomService;
      case 95:
        return ECode.retryFailed;
      case 96:
        return ECode.wrongRoomId;
      case 97:
        return ECode.userNotInRoom;
      case 98:
        return ECode.noHandler;
      case 99:
        return ECode.invalidRoomId;
      case 100:
        return ECode.fileNotExist;
      case 101:
        return ECode.chat_TooFast;
      case 102:
        return ECode.notSupported;
      case 103:
        return ECode.nameTooShort;
      case 104:
        return ECode.nameTooLong;
      case 105:
        return ECode.nameReserved;
      case 106:
        return ECode.nameEmpty;
      case 107:
        return ECode.nameInvalidChar;
      case 108:
        return ECode.nameTooFrequent;
      case 109:
        return ECode.chatInvalidType;
      case 110:
        return ECode.chatEmpty;
      case 111:
        return ECode.chatTooShort;
      case 112:
        return ECode.chatTooLong;
      case 113:
        return ECode.chatAllSpace;
      case 114:
        return ECode.searchTooShort;
      case 115:
        return ECode.searchTooLong;
      case 116:
        return ECode.avatarIndex_TooFrequent;
      case 117:
        return ECode.avatarIndex_OutOfRange;
      case 118:
        return ECode.chatMissingImageContent;
      case 119:
        return ECode.alreadyFriends;
      case 120:
        return ECode.invalidUserId;
      case 121:
        return ECode.outgoingFriendRequestNotExist;
      case 122:
        return ECode.friendRequestResultNotWait;
      case 123:
        return ECode.incomingFriendRequestNotExist;
      case 124:
        return ECode.outgoingFriendRequestAlreadyExist;
      case 125:
        return ECode.notFriends;
      case 126:
        return ECode.duplicate;
      case 127:
        return ECode.invalidRoomType;
      default:
        return ECode.error;
    }
  }

  final int code;
  const ECode(this.code);
}