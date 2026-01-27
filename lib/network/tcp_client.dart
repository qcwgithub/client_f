import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:scene_hub/network/i_message_packer.dart';
import 'package:scene_hub/network/unpack_result.dart';

typedef MessageHandler = void Function(UnpackResult result);

class TcpClient {
  final String host;
  final int port;
  final IMessagePacker packer;

  Socket? _socket;

  Uint8List _recvBuffer = Uint8List(64 * 1024);
  int _recvCount = 0;

  MessageHandler? onMessage;
  VoidCallback? onDisconnected;

  TcpClient({required this.host, required this.port, required this.packer});

  Future<void> connect() async {
    _socket = await Socket.connect(host, port);
    _socket!.setOption(SocketOption.tcpNoDelay, true);

    _socket!.listen(
      _onData,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: true,
    );
  }

  void send(int seq, int msgType, Uint8List? body, bool requireResponse) {
    final packet = packer.pack(msgType, body, seq, requireResponse);
    _socket?.add(packet);
  }

  void close() {
    _socket?.destroy();
    _socket = null;
  }

  void _ensureCapacity(int need) {
    if (_recvBuffer.length >= need) {
      return;
    }

    int newSize = _recvBuffer.length;
    while (newSize < need) {
      newSize *= 2;
    }

    final newBuf = Uint8List(newSize);
    newBuf.setRange(0, _recvCount, _recvBuffer);
    _recvBuffer = newBuf;
  }

  void _onData(Uint8List data) {
    _ensureCapacity(_recvCount + data.length);

    _recvBuffer.setRange(_recvCount, _recvCount + data.length, data);
    _recvCount += data.length;

    _processBuffer();
  }

  void _processBuffer() {
    int offset = 0;

    while (true) {
      int exactLen = 0;
      final completed = packer.isCompleteMessage(
        _recvBuffer,
        offset,
        _recvCount - offset,
        (len) => exactLen = len,
      );

      if (!completed) {
        break;
      }

      final result = packer.unpack(_recvBuffer, offset, exactLen);
      if (result.success) {
        onMessage?.call(result);
      }

      offset += exactLen;
    }

    if (offset > 0) {
      final remain = _recvCount - offset;
      if (remain > 0) {
        _recvBuffer.setRange(0, remain, _recvBuffer, offset);
      }
      _recvCount = remain;
    }
  }

  void _onDone() {
    onDisconnected?.call();
  }

  void _onError(Object error) {
    close();
    onDisconnected?.call();
  }
}
