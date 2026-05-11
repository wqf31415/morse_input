/// Windows 平台服务
/// 提供剪贴板操作等 Windows 特有功能
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class WindowsPlatformService {
  static const MethodChannel _channel = MethodChannel('com.morse.morse_input/platform');

  /// 将文本复制到剪贴板
  static Future<void> copyToClipboard(String text) async {
    try {
      await _channel.invokeMethod('copyToClipboard', {'text': text});
    } on PlatformException {
      // 回退到 Flutter 内置剪贴板
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  /// 检查是否运行在 Windows 平台
  static bool get isWindows => !kIsWeb;

  /// 检查是否运行在 Android 平台
  static bool get isAndroid => !kIsWeb;
}
