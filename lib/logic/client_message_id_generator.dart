class ClientMessageIdGenerator {
  int _lastTimestamp = 0;
  int _sequence = 0;

  int nextId() {
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now == _lastTimestamp) {
      _sequence++;
    } else {
      _sequence = 0;
      _lastTimestamp = now;
    }

    return (now << 16) | (_sequence & 0xFFFF);
  }
}

final clientMessageIdGenerator = ClientMessageIdGenerator();
