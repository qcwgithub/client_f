import 'dart:typed_data';

import 'package:scene_hub/network/unpack_result.dart';

abstract class IMessagePacker {
  bool isCompleteMessage(
    Uint8List buffer,
    int offset,
    int count,
    void Function(int exact) exact,
  );

  UnpackResult unpack(Uint8List buffer, int offset, int count);
  Uint8List pack(int code, Uint8List? msg, int seq, bool requireResponse);
}
