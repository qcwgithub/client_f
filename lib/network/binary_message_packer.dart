import 'dart:typed_data';

import 'package:scene_hub/network/binary_writter.dart';
import 'package:scene_hub/network/i_message_packer.dart';
import 'package:scene_hub/network/unpack_result.dart';

class BinaryMessagePacker implements IMessagePacker {
  int getHeaderLength() {
    return 3 * 4 + 1;
  }

  @override
  bool isCompleteMessage(
    Uint8List buffer,
    int offset,
    int count,
    void Function(int exact) exact,
  ) {
    if (count < getHeaderLength()) {
      return false;
    }

    final totalLen = BinaryWriter.readInt(buffer, offset);
    if (count < totalLen) {
      return false;
    }

    exact(totalLen);
    return true;
  }

  @override
  Uint8List pack(int code, Uint8List? msg, int seq, bool requireResponse) {
    final bodyLen = msg?.length ?? 0;
    final totalLen = getHeaderLength() + 4 + bodyLen;

    final buffer = Uint8List(totalLen);
    int offset = 0;

    BinaryWriter.writeInt(buffer, offset, totalLen);
    offset += 4;

    BinaryWriter.writeInt(buffer, offset, seq);
    offset += 4;

    BinaryWriter.writeInt(buffer, offset, code);
    offset += 4;

    buffer[offset++] = requireResponse ? 1 : 0;

    BinaryWriter.writeInt(buffer, offset, bodyLen);
    offset += 4;

    if (bodyLen > 0) {
      buffer.setRange(offset, offset + bodyLen, msg!);
    }

    return buffer;
  }

  @override
  UnpackResult unpack(Uint8List buffer, int offset, int count) {
    final r = UnpackResult();

    r.totalLength = BinaryWriter.readInt(buffer, offset);
    offset += 4;

    r.seq = BinaryWriter.readInt(buffer, offset);
    offset += 4;

    r.code = BinaryWriter.readInt(buffer, offset);
    offset += 4;

    r.requireResponse = buffer[offset++] == 1;

    final bodyLen = BinaryWriter.readInt(buffer, offset);
    offset += 4;

    if (bodyLen > 0) {
      r.msgBytes = Uint8List(bodyLen);
      r.msgBytes!.setRange(
        0,
        bodyLen,
        buffer.sublist(offset, offset + bodyLen),
      );
    }

    r.success = true;
    return r;
  }
}
