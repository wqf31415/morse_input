/// 莫尔斯电码输入引擎
/// 负责处理按压检测、电码缓冲、自动转换逻辑
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/morse_code_map.dart';

/// 输入事件类型
enum MorseSignal {
  dot,   // 短按 → 点 (.)
  dash,  // 长按 → 划 (-)
}

/// 按钮形状枚举
enum ButtonShape {
  circle('圆形'),
  roundedRect('圆角矩形'),
  stadium('胶囊形');

  final String label;
  const ButtonShape(this.label);
}

/// 输入引擎配置
class MorseEngineConfig {
  /// 短按与长按的分界时间（毫秒）
  final int pressThresholdMs;

  /// 字符间自动转换超时时间（毫秒）
  final int charTimeoutMs;

  /// 单词间自动插入空格的超时时间（毫秒）
  final int wordTimeoutMs;

  /// 是否自动添加空格（单词间隔）
  final bool autoSpace;

  /// 输入按钮形状
  final ButtonShape buttonShape;

  const MorseEngineConfig({
    this.pressThresholdMs = 200,
    this.charTimeoutMs = 1000,
    this.wordTimeoutMs = 2000,
    this.autoSpace = true,
    this.buttonShape = ButtonShape.circle,
  });

  MorseEngineConfig copyWith({
    int? pressThresholdMs,
    int? charTimeoutMs,
    int? wordTimeoutMs,
    bool? autoSpace,
    ButtonShape? buttonShape,
  }) {
    return MorseEngineConfig(
      pressThresholdMs: pressThresholdMs ?? this.pressThresholdMs,
      charTimeoutMs: charTimeoutMs ?? this.charTimeoutMs,
      wordTimeoutMs: wordTimeoutMs ?? this.wordTimeoutMs,
      autoSpace: autoSpace ?? this.autoSpace,
      buttonShape: buttonShape ?? this.buttonShape,
    );
  }
}

/// 输入引擎状态
enum EngineState {
  idle,        // 空闲，等待输入
  pressing,    // 正在按压中
  buffering,   // 电码缓冲中（等待可能的更多输入）
  converting,  // 正在转换为字符
}

/// 莫尔斯电码输入引擎
class MorseInputEngine extends ChangeNotifier {
  MorseEngineConfig _config;
  MorseEngineConfig get config => _config;

  // 当前状态
  EngineState _state = EngineState.idle;
  EngineState get state => _state;

  // 当前正在输入的电码序列（如 ".-"）
  String _currentMorse = '';
  String get currentMorse => _currentMorse;

  // 已输入的完整文本
  String _outputText = '';
  String get outputText => _outputText;

  // 按压开始时间
  DateTime? _pressStartTime;

  // 字符超时定时器
  Timer? _charTimer;

  // 单词超时定时器
  Timer? _wordTimer;

  // 按压时长记录（用于 UI 显示）
  int _lastPressDurationMs = 0;
  int get lastPressDurationMs => _lastPressDurationMs;

  // 当前电码是否即将自动转换（用于 UI 提示）
  bool _isAutoConverting = false;
  bool get isAutoConverting => _isAutoConverting;

  MorseInputEngine({MorseEngineConfig config = const MorseEngineConfig()})
      : _config = config;

  /// 更新配置
  void updateConfig(MorseEngineConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  /// 处理按钮按下事件
  void onPressed() {
    // 取消所有待处理的定时器
    _cancelTimers();
    _isAutoConverting = false;

    _state = EngineState.pressing;
    _pressStartTime = DateTime.now();
    notifyListeners();
  }

  /// 处理按钮释放事件
  void onReleased() {
    if (_state != EngineState.pressing || _pressStartTime == null) return;

    final duration = DateTime.now().difference(_pressStartTime!).inMilliseconds;
    _lastPressDurationMs = duration;
    _pressStartTime = null;

    // 根据按压时长判断是点还是划
    final signal = duration < config.pressThresholdMs ? MorseSignal.dot : MorseSignal.dash;
    _addSignal(signal);
  }

  /// 添加一个莫尔斯信号
  void _addSignal(MorseSignal signal) {
    final morseChar = signal == MorseSignal.dot ? '.' : '-';
    _currentMorse += morseChar;

    _state = EngineState.buffering;
    notifyListeners();

    // 启动字符超时定时器
    _startCharTimer();
  }

  /// 启动字符自动转换定时器
  void _startCharTimer() {
    _charTimer?.cancel();
    _charTimer = Timer(Duration(milliseconds: config.charTimeoutMs), () {
      if (_currentMorse.isNotEmpty) {
        _isAutoConverting = true;
        notifyListeners();
        // 短暂延迟后执行转换，让 UI 显示提示
        Future.delayed(const Duration(milliseconds: 100), () {
          _convertCurrentMorse();
        });
      }
    });
  }

  /// 启动单词间隔定时器（转换字符后）
  void _startWordTimer() {
    if (!config.autoSpace) return;
    _wordTimer?.cancel();
    _wordTimer = Timer(Duration(milliseconds: config.wordTimeoutMs), () {
      // 自动插入空格
      _addSpace();
    });
  }

  /// 将当前电码转换为字符
  void _convertCurrentMorse() {
    if (_currentMorse.isEmpty) return;

    final char = MorseCodeMap.decode(_currentMorse);
    if (char != null) {
      _outputText += char;
    }
    // 无效电码直接丢弃（也可以选择保留并提示用户）

    _currentMorse = '';
    _isAutoConverting = false;
    _state = EngineState.idle;
    _charTimer?.cancel();

    notifyListeners();

    // 启动单词间隔定时器
    if (char != null) {
      _startWordTimer();
    }
  }

  /// 手动触发转换（点击空白区域）
  void manualConvert() {
    _cancelTimers();
    _isAutoConverting = false;
    _convertCurrentMorse();
  }

  /// 添加空格
  void _addSpace() {
    if (_outputText.isNotEmpty && !_outputText.endsWith(' ')) {
      _outputText += ' ';
      notifyListeners();
    }
  }

  /// 手动插入空格
  void insertSpace() {
    _cancelTimers();
    _isAutoConverting = false;

    // 先转换当前电码
    if (_currentMorse.isNotEmpty) {
      final char = MorseCodeMap.decode(_currentMorse);
      if (char != null) {
        _outputText += char;
      }
      _currentMorse = '';
    }

    _outputText += ' ';
    _state = EngineState.idle;
    notifyListeners();
  }

  /// 插入换行
  void insertNewline() {
    _cancelTimers();
    _isAutoConverting = false;

    // 先转换当前电码
    if (_currentMorse.isNotEmpty) {
      final char = MorseCodeMap.decode(_currentMorse);
      if (char != null) {
        _outputText += char;
      }
      _currentMorse = '';
    }

    _outputText += '\n';
    _state = EngineState.idle;
    notifyListeners();
  }

  /// 退格：删除最后一个字符
  void backspace() {
    _cancelTimers();
    _isAutoConverting = false;

    if (_currentMorse.isNotEmpty) {
      // 先删除当前电码的最后一个信号
      _currentMorse = _currentMorse.substring(0, _currentMorse.length - 1);
      if (_currentMorse.isNotEmpty) {
        _startCharTimer();
      } else {
        _state = EngineState.idle;
      }
    } else if (_outputText.isNotEmpty) {
      // 删除已输出文本的最后一个字符
      _outputText = _outputText.substring(0, _outputText.length - 1);
      _state = EngineState.idle;
    }
    notifyListeners();
  }

  /// 清除当前未转换的电码
  void clearCurrentMorse() {
    _cancelTimers();
    _isAutoConverting = false;
    _currentMorse = '';
    _state = EngineState.idle;
    notifyListeners();
  }

  /// 清除所有内容
  void clearAll() {
    _cancelTimers();
    _isAutoConverting = false;
    _currentMorse = '';
    _outputText = '';
    _state = EngineState.idle;
    notifyListeners();
  }

  /// 取消所有定时器
  void _cancelTimers() {
    _charTimer?.cancel();
    _charTimer = null;
    _wordTimer?.cancel();
    _wordTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
