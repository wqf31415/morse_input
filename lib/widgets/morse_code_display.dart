/// 电码显示区域组件
/// 显示当前正在输入的莫尔斯电码，支持点击快速转换
import 'package:flutter/material.dart';

class MorseCodeDisplay extends StatelessWidget {
  /// 当前电码字符串（如 ".-"）
  final String morseCode;

  /// 是否即将自动转换
  final bool isAutoConverting;

  /// 点击回调（手动触发转换）
  final VoidCallback onTap;

  const MorseCodeDisplay({
    super.key,
    required this.morseCode,
    this.isAutoConverting = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAutoConverting
                ? Colors.orange.shade400
                : Colors.grey.shade300,
            width: isAutoConverting ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  '电码',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isAutoConverting) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '即将转换...',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (morseCode.isNotEmpty)
                  Text(
                    '点击转换',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade400,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (morseCode.isEmpty)
              Text(
                '等待输入...',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade400,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              )
            else
              Text(
                morseCode,
                style: TextStyle(
                  fontSize: 32,
                  color: isAutoConverting
                      ? Colors.orange.shade700
                      : Colors.blue.shade800,
                  letterSpacing: 6,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
