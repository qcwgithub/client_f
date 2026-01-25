class MPTestInfo {
    int intValue;
    bool boolValue;
    int longValue;
    String stringValue;
    List<int> listOfInt;
    List<int> listOfLong;
    List<String> listOfString;

    MPTestInfo({
      required this.intValue,
      required this.boolValue,
      required this.longValue,
      required this.stringValue,
      required this.listOfInt,
      required this.listOfLong,
      required this.listOfString,
    });

    List toMsgPack() {
      return [
        intValue, // [0]
        boolValue, // [1]
        longValue, // [2]
        stringValue, // [3]
        listOfInt, // [4]
        listOfLong, // [5]
        listOfString, // [6]
      ];
    }

    factory MPTestInfo.fromMsgPack(List list) {
      return MPTestInfo(
        intValue: list[0] as int, // [0]
        boolValue: list[1] as bool, // [1]
        longValue: list[2] as int, // [2]
        stringValue: list[3] as String, // [3]
        listOfInt: List<int>.from(list[4], growable: true), // [4]
        listOfLong: List<int>.from(list[5], growable: true), // [5]
        listOfString: List<String>.from(list[6], growable: true), // [6]
      );
    }
}