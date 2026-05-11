/// 莫尔斯电码参考表组件
/// 显示常用字符的莫尔斯电码编码，方便用户查阅
import 'package:flutter/material.dart';
import '../models/morse_code_map.dart';

class MorseReferenceTable extends StatelessWidget {
  const MorseReferenceTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                '莫尔斯电码参考',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 字母表
          _buildSection('字母', [
            'A', 'B', 'C', 'D', 'E', 'F', 'G',
            'H', 'I', 'J', 'K', 'L', 'M', 'N',
            'O', 'P', 'Q', 'R', 'S', 'T', 'U',
            'V', 'W', 'X', 'Y', 'Z',
          ]),
          const SizedBox(height: 6),
          // 数字
          _buildSection('数字', ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> chars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: chars.map((char) {
            final morse = MorseCodeMap.encode(char) ?? '';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$char ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    TextSpan(
                      text: morse,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
