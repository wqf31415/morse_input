/// 莫尔斯电码映射表
/// 包含字母、数字和常用标点符号的标准莫尔斯电码编码
class MorseCodeMap {
  MorseCodeMap._();

  /// 字符 -> 莫尔斯电码
  static const Map<String, String> charToMorse = {
    // 字母
    'A': '.-',    'B': '-...',  'C': '-.-.',  'D': '-..',
    'E': '.',     'F': '..-.',  'G': '--.',   'H': '....',
    'I': '..',    'J': '.---',  'K': '-.-',   'L': '.-..',
    'M': '--',    'N': '-.',    'O': '---',   'P': '.--.',
    'Q': '--.-',  'R': '.-.',   'S': '...',   'T': '-',
    'U': '..-',   'V': '...-',  'W': '.--',   'X': '-..-',
    'Y': '-.--',  'Z': '--..',
    // 数字
    '0': '-----', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.',
    // 标点符号
    '.': '.-.-.-',  ',': '--..--',  '?': '..--..',
    "'": '.----.',  '!': '-.-.--',  '/': '-..-.',
    '(': '-.--.',   ')': '-.--.-',  '&': '.-...',
    ':': '---...',  ';': '-.-.-.',  '=': '-...-',
    '+': '.-.-.',   '-': '-....-',  '_': '..--.-',
    '"': '.-..-.',  '\$': '...-..-', '@': '.--.-.',
  };

  /// 莫尔斯电码 -> 字符
  static final Map<String, String> morseToChar = {
    for (final entry in charToMorse.entries) entry.value: entry.key,
  };

  /// 将莫尔斯电码字符串转换为字符
  /// 返回 null 表示无效的电码
  static String? decode(String morse) {
    return morseToChar[morse];
  }

  /// 将字符转换为莫尔斯电码
  /// 返回 null 表示不支持的字符
  static String? encode(String char) {
    return charToMorse[char.toUpperCase()];
  }

  /// 检查莫尔斯电码是否有效
  static bool isValidMorse(String morse) {
    return morseToChar.containsKey(morse);
  }

  /// 获取所有支持的字符列表
  static List<String> get supportedChars =>
      charToMorse.keys.toList()..sort();
}
