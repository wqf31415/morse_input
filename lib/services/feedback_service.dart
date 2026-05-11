/// 音效与振动反馈服务
/// 提供点（dot）和划（dash）的音频反馈，以及振动反馈
import 'package:flutter/services.dart';

class FeedbackService {
  static const MethodChannel _channel = MethodChannel('com.morse.morse_input/feedback');

  /// 播放点的音效（短促高音）
  static Future<void> playDotSound() async {
    try {
      await _channel.invokeMethod('playDotSound');
    } on PlatformException {
      // 如果原生通道不可用，使用系统反馈
      HapticFeedback.lightImpact();
    }
  }

  /// 播放划的音效（较长低音）
  static Future<void> playDashSound() async {
    try {
      await _channel.invokeMethod('playDashSound');
    } on PlatformException {
      HapticFeedback.mediumImpact();
    }
  }

  /// 播放转换成功音效
  static Future<void> playConvertSound() async {
    try {
      await _channel.invokeMethod('playConvertSound');
    } on PlatformException {
      HapticFeedback.selectionClick();
    }
  }

  /// 播放错误音效（无效电码）
  static Future<void> playErrorSound() async {
    try {
      await _channel.invokeMethod('playErrorSound');
    } on PlatformException {
      HapticFeedback.heavyImpact();
    }
  }

  /// 触发短振动（点反馈）
  static Future<void> vibrateDot() async {
    try {
      await _channel.invokeMethod('vibrateDot');
    } on PlatformException {
      HapticFeedback.lightImpact();
    }
  }

  /// 触发长振动（划反馈）
  static Future<void> vibrateDash() async {
    try {
      await _channel.invokeMethod('vibrateDash');
    } on PlatformException {
      HapticFeedback.mediumImpact();
    }
  }
}
