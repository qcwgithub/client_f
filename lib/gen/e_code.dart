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
  roomLocationNotFound(91),
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
  name_TooShort(103),
  name_TooLong(104),
  name_Reserved(105),
  name_Empty(106),
  name_InvalidChar(107),
  name_TooFrequent(108),
  chat_InvalidType(109),
  chat_Empty(110),
  chat_TooShort(111),
  chat_TooLong(112),
  chat_AllSpace(113),
  search_TooShort(114),
  search_TooLong(115),
  avatarIndex_TooFrequent(116),
  avatarIndex_OutOfRange(117);

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
        return ECode.roomLocationNotFound;
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
        return ECode.name_TooShort;
      case 104:
        return ECode.name_TooLong;
      case 105:
        return ECode.name_Reserved;
      case 106:
        return ECode.name_Empty;
      case 107:
        return ECode.name_InvalidChar;
      case 108:
        return ECode.name_TooFrequent;
      case 109:
        return ECode.chat_InvalidType;
      case 110:
        return ECode.chat_Empty;
      case 111:
        return ECode.chat_TooShort;
      case 112:
        return ECode.chat_TooLong;
      case 113:
        return ECode.chat_AllSpace;
      case 114:
        return ECode.search_TooShort;
      case 115:
        return ECode.search_TooLong;
      case 116:
        return ECode.avatarIndex_TooFrequent;
      case 117:
        return ECode.avatarIndex_OutOfRange;
      default:
        return ECode.error;
    }
  }

  final int code;
  const ECode(this.code);
}