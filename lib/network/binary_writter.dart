import 'dart:typed_data';

class BinaryWriter {
  static void writeInt(Uint8List buffer, int offset, int value) {
    final bd = ByteData.sublistView(buffer);
    bd.setInt32(offset, value, Endian.little);
  }

  static int readInt(Uint8List buffer, int offset) {
    final bd = ByteData.sublistView(buffer);
    return bd.getInt32(offset, Endian.little);
  }

  static void writeLong(Uint8List buffer, int offset, int value) {
    final bd = ByteData.sublistView(buffer);
    bd.setInt64(offset, value, Endian.little);
  }

  static int readLong(Uint8List buffer, int offset) {
    final bd = ByteData.sublistView(buffer);
    return bd.getInt64(offset, Endian.little);
  }
}
