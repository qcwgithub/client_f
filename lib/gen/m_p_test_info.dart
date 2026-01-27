import 'package:scene_hub/i_to_msg_pack.dart';

class MPTestInfo implements IToMsgPack {
    // [0]
    int intValue;
    // [1]
    bool boolValue;
    // [2]
    int longValue;
    // [3]
    String stringValue;
    // [4]
    List<int> listOfInt;
    // [5]
    List<int> listOfLong;
    // [6]
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

    @override
    List toMsgPack() {
      return [
        intValue,
        boolValue,
        longValue,
        stringValue,
        listOfInt,
        listOfLong,
        listOfString,
      ];
    }

    factory MPTestInfo.fromMsgPack(List list) {
      return MPTestInfo(
        intValue: list[0] as int,
        boolValue: list[1] as bool,
        longValue: list[2] as int,
        stringValue: list[3] as String,
        listOfInt: List<int>.from(list[4], growable: true),
        listOfLong: List<int>.from(list[5], growable: true),
        listOfString: List<String>.from(list[6], growable: true),
      );
    }
}