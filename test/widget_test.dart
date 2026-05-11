import 'package:flutter_test/flutter_test.dart';
import 'package:morse_input/models/morse_code_map.dart';
import 'package:morse_input/services/morse_input_engine.dart';

void main() {
  group('MorseCodeMap', () {
    test('字母编码正确', () {
      expect(MorseCodeMap.encode('A'), '.-');
      expect(MorseCodeMap.encode('B'), '-...');
      expect(MorseCodeMap.encode('S'), '...');
      expect(MorseCodeMap.encode('O'), '---');
    });

    test('数字编码正确', () {
      expect(MorseCodeMap.encode('0'), '-----');
      expect(MorseCodeMap.encode('1'), '.----');
      expect(MorseCodeMap.encode('5'), '.....');
      expect(MorseCodeMap.encode('9'), '----.');
    });

    test('解码正确', () {
      expect(MorseCodeMap.decode('.-'), 'A');
      expect(MorseCodeMap.decode('...'), 'S');
      expect(MorseCodeMap.decode('---'), 'O');
      expect(MorseCodeMap.decode('-----'), '0');
    });

    test('无效电码返回 null', () {
      expect(MorseCodeMap.decode('......'), isNull);
      expect(MorseCodeMap.decode(''), isNull);
    });

    test('大小写不敏感编码', () {
      expect(MorseCodeMap.encode('a'), '.-');
      expect(MorseCodeMap.encode('Z'), '--..');
    });
  });

  group('MorseInputEngine', () {
    late MorseInputEngine engine;

    setUp(() {
      engine = MorseInputEngine();
    });

    tearDown(() {
      engine.dispose();
    });

    test('初始状态正确', () {
      expect(engine.currentMorse, '');
      expect(engine.outputText, '');
      expect(engine.state, EngineState.idle);
    });

    test('短按产生点信号', () {
      // 模拟短按（不直接测试定时器，只测试状态变化）
      engine.onPressed();
      expect(engine.state, EngineState.pressing);
    });

    test('手动转换空电码不崩溃', () {
      engine.manualConvert();
      expect(engine.outputText, '');
    });

    test('退格空内容不崩溃', () {
      engine.backspace();
      expect(engine.outputText, '');
    });

    test('清除电码不崩溃', () {
      engine.clearCurrentMorse();
      expect(engine.currentMorse, '');
    });

    test('清除全部不崩溃', () {
      engine.clearAll();
      expect(engine.currentMorse, '');
      expect(engine.outputText, '');
    });
  });
}
