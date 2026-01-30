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
import 'package:scene_hub/my_logger.dart';
import 'package:scene_hub/network/binary_message_packer.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/network_status.dart';
import 'package:scene_hub/network/tcp_client.dart';
import 'package:scene_hub/network/unpack_result.dart';

class PendingRequest {
  final Completer<MyResponse> completer;
  PendingRequest({required this.completer});
}

class Server {
  static final Server instance = Server();

  TcpClient? client;
  final Map<int, PendingRequest> _pending = {};

  bool _running = false;
  NetworkStatus _state = NetworkStatus.init;
  Future<void> start() async {
    if (_running) {
      return;
    }

    _running = true;

    while (_running) {
      switch (_state) {
        case NetworkStatus.init:
          client = TcpClient(
            host: "localhost",
            port: 8020,
            packer: BinaryMessagePacker(),
          );
          client!.onMessage = _onMessage;

          bool ok = await client!.connect();
          if (!ok) {
            _state = NetworkStatus.init;
            await Future.delayed(const Duration(seconds: 1));
          } else {
            _state = NetworkStatus.login;
          }
          break;

        case NetworkStatus.login:
          {
            MyLogger.instance.d('login...');

            var msg = new MsgLogin(
              version: "1.0",
              platform: "android",
              channel: "uuid",
              channelUserId: "1",
              verifyData: "",
              userId: 0,
              token: "",
              deviceUid: "",
              dict: Map(),
            );

            MyResponse r = await request(MsgType.login, msg);
            MyLogger.instance.d('login result ${r.e}');
            if (r.e == ECode.success) {
              _state = NetworkStatus.online;

              var res = ResLogin.fromMsgPack(r.res!);
              MyLogger.instance.d('isNewUser? ${res.isNewUser}');
              MyLogger.instance.d('kickOther? ${res.kickOther}');
              MyLogger.instance.d('userId = ${res.userInfo.userId}');
              MyLogger.instance.d('userName = ${res.userInfo.userName}');
            } else {
              _state = NetworkStatus.init;
            }
          }
          break;

        case NetworkStatus.online:
          {
            await Future.delayed(const Duration(seconds: 1));
          }
      }
    }
  }

  static int nextSeq = 1;

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
    _pending[seq] = PendingRequest(completer: completer);

    List list = msg.toMsgPack();
    Uint8List msgBytes = serialize(list);
    client!.send(seq, msgType.code, msgBytes, true);
    return completer.future;
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
    }
    else if (result.seq > 0) {
      MsgType msgType = MsgType.fromCode(result.code);
      List msg = result.msgBytes != null ? deserialize(result.msgBytes!) : null;
      _handlePush(msgType, msg);
    }
  }

  void _handlePush(MsgType msgType, List msg) {
    MyLogger.instance.d("received $msgType");
  }

  void _onDisconnected() {
    for (final c in _pending.values) {
      c.completer.completeError(Exception('disconnected'));
    }
    _pending.clear();
  }
}
