import 'dart:typed_data';

import 'package:scene_hub/gen/e_code.dart';

class MyResponseT<T> {
  final ECode e;
  final T? res;
  MyResponseT({required this.e, required this.res});
}
