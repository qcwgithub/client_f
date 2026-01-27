import 'package:scene_hub/network/tcp_client.dart';
import 'package:scene_hub/network/unpack_result.dart';

class Server {
  TcpClient? client;

  static int seq = 1;

  void _onMessage(UnpackResult result) {}
}
