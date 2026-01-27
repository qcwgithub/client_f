import 'dart:typed_data';

class UnpackResult {
  bool success = false;
  int totalLength = 0;
  int seq = 0;
  int code = 0;
  bool requireResponse = false;
  Uint8List? msgBytes;
}
