import 'dart:async';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:scene_hub/gen/e_code.dart';
import 'package:scene_hub/gen/msg_type.dart';
import 'package:scene_hub/i_to_msg_pack.dart';
import 'package:scene_hub/network/my_response.dart';
import 'package:scene_hub/network/tcp_client.dart';
import 'package:scene_hub/network/unpack_result.dart';

class PendingRequest {
  final Completer<MyResponse> completer;
  PendingRequest({required this.completer});
}

class Server {
  TcpClient? client;
  final Map<int, PendingRequest> _pending = {};

  static int nextSeq = 1;

  Future<MyResponse> request<T extends IToMsgPack>(
    MsgType msgType,
    T msg,
  ) async {
    if (client == null) {
      return MyResponse(e: ECode.notConnected, res: null);
    }

    int seq = nextSeq++;
    final completer = Completer<MyResponse>();
    _pending[seq] = PendingRequest(completer: completer);

    List list = msg.toMsgPack();
    Uint8List msgBytes = serialize(list);
    client!.send(seq, msgType.code, msgBytes, true);
    return completer.future;
  }

  void _onMessage(UnpackResult result) {
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
    print("received msgType " + msgType.toString());
  }

  void _onDisconnected() {
    for (final c in _pending.values) {
      c.completer.completeError(Exception('disconnected'));
    }
    _pending.clear();
  }
}
