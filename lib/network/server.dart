import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_login.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/gen/res_login.dart';
import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/main.dart';
import 'package:scene_hub/my_logger.dart';
import 'package:scene_hub/network/binary_message_packer.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/network_status.dart';
import 'package:scene_hub/network/tcp_client.dart';
import 'package:scene_hub/network/unpack_result.dart';
import 'package:scene_hub/providers/nav_provider.dart';

class PendingRequest {
  final MsgType msgType;
  final Completer<MyResponse> completer;
  PendingRequest({required this.msgType, required this.completer});
}

class Server {
  static final Server instance = Server();
  TcpClient? client;
  NetworkStatus _state = NetworkStatus.init;
  NetworkStatus get state => _state;
  void _setState(NetworkStatus e) {
    _state = e;
    print("-> $e");
  }

  String? _ip;
  int _port = 0;
  void setIpAndPort(String ip, int port) {
    _ip = ip;
    _port = port;
  }

  String? _channel;
  String? _channelUserId;
  void setChannelAndChannelUserId(String ch, String chUserId) {
    _channel = ch;
    _channelUserId = chUserId;
  }

  Future<bool> _connectOnce() async {
    assert(_state == NetworkStatus.init);

    if (client != null) {
      client!.close();
      client = null;
    }

    _setState(NetworkStatus.connecting);

    client = TcpClient(host: _ip!, port: _port, packer: BinaryMessagePacker());

    // listen
    client!.onMessage = _onMessage;
    client!.onDisconnected = _onDisconnected;

    if (await client!.connect()) {
      _setState(NetworkStatus.connected);
      return true;
    } else {
      _setState(NetworkStatus.init);
      return false;
    }
  }

  void _onDisconnected() {
    for (final c in _pending.values) {
      c.completer.complete(MyResponse(e: ECode.timeout, res: null));
    }
    _pending.clear();

    _setState(NetworkStatus.init);

    // TEMP
    globalContainer.read(navProvider.notifier).state = 0;
  }

  Future<bool> _loginOnce() async {
    assert(_state == NetworkStatus.connected);

    _setState(NetworkStatus.logining);
    MyLogger.instance.d('login...');

    var msg = new MsgLogin(
      version: "1.0",
      platform: "android",
      channel: _channel!,
      channelUserId: _channelUserId!,
      verifyData: "",
      userId: 0,
      token: "",
      deviceUid: "",
      dict: Map(),
    );

    MyResponse r = await request(MsgType.login, msg);
    MyLogger.instance.d('login result ${r.e}');
    if (r.e == ECode.success) {
      _setState(NetworkStatus.online);

      var res = ResLogin.fromMsgPack(r.res!);
      MyLogger.instance.d('isNewUser? ${res.isNewUser}');
      MyLogger.instance.d('kickOther? ${res.kickOther}');
      MyLogger.instance.d('userId = ${res.userInfo.userId}');
      MyLogger.instance.d('userName = ${res.userInfo.userName}');

      // TEMP
      globalContainer.read(navProvider.notifier).state = 1;

      return true;
    } else {
      _setState(NetworkStatus.init);
      return false;
    }
  }

  Future<bool> connectAndLoginOnce() async {
    if (!await _connectOnce()) {
      return false;
    }
    assert(_state == NetworkStatus.connected);

    return await _loginOnce();
  }

  bool _running = false;
  Future<void> startLoop() async {
    if (_running) {
      return;
    }

    while (_running) {
      switch (_state) {
        case NetworkStatus.init:
          if (!await _connectOnce()) {
            await Future.delayed(const Duration(seconds: 1));
          } else {
            assert(_state == NetworkStatus.connected);
          }
          break;

        case NetworkStatus.connecting:
          {
            // nothing to do
          }
          break;

        case NetworkStatus.connected:
          {
            if (!await _loginOnce()) {
              await Future.delayed(const Duration(seconds: 1));
            } else {
              assert(_state == NetworkStatus.online);
            }
          }
          break;

        case NetworkStatus.logining:
          {
            // nothing to do
          }
          break;

        case NetworkStatus.online:
          {
            await Future.delayed(const Duration(seconds: 1));
          }
      }
    }
  }

  void stopLoop() {
    _running = false;
  }

  static int nextSeq = 1;
  final Map<int, PendingRequest> _pending = {};

  Future<MyResponse> request<T extends IToMsgPack>(
    MsgType msgType,
    T msg,
  ) async {
    if (client == null) {
      return MyResponse(e: ECode.notConnected, res: null);
    }

    int seq = nextSeq++;
    MyLogger.instance.d('request $msgType seq $seq');
    final completer = Completer<MyResponse>();
    _pending[seq] = PendingRequest(msgType: msgType, completer: completer);

    List list = msg.toMsgPack();
    Uint8List msgBytes = serialize(list);
    client!.send(seq, msgType.code, msgBytes, true);
    return completer.future;
  }

  bool isPending(MsgType msgType) {
    for (PendingRequest pr in _pending.values) {
      if (pr.msgType == msgType) {
        return true;
      }
    }
    return false;
  }

  void _onMessage(UnpackResult result) {
    MyLogger.instance.d('_onMessage seq ${result.seq}');
    if (result.seq < 0) {
      ECode e = ECode.fromCode(result.code);
      List res = result.msgBytes != null ? deserialize(result.msgBytes!) : null;

      final request = _pending.remove(-result.seq);
      if (request != null) {
        request.completer.complete(MyResponse(e: e, res: res));
      }
    } else if (result.seq > 0) {
      MsgType msgType = MsgType.fromCode(result.code);
      List msg = result.msgBytes != null ? deserialize(result.msgBytes!) : null;
      _handlePush(msgType, msg);
    }
  }

  void _handlePush(MsgType msgType, List msg) {
    MyLogger.instance.d("received $msgType");
  }
}
