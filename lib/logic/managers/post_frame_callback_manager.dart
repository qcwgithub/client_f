import 'package:flutter/scheduler.dart';

class PostFrameCallbackManager {
  bool _scheduled = false;
  List<VoidCallback> _callbacks = [];

  /// 注册一个 postFrameCallback，如果还没调度则自动调度
  void registerNoDuplicate(VoidCallback callback) {
    if (_callbacks.contains(callback)) {
      // 已经注册过了，不重复注册
      return;
    }

    _callbacks.add(callback);
    if (!_scheduled) {
      _scheduled = true;
      SchedulerBinding.instance.addPostFrameCallback(_onPostFrame);
    }
  }

  void _onPostFrame(Duration timeStamp) {
    _scheduled = false;
    // 取走当前批次，回调中可以再次 register
    final batch = _callbacks;
    _callbacks = [];
    for (final callback in batch) {
      callback();
    }
    // 如果回调中又注册了新的，_scheduled 已经被 register 重新设为 true
  }
}
