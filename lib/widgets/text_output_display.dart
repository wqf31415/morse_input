/// 文本输出显示区域
/// 显示已输入转换后的文本
import 'package:flutter/material.dart';

class TextOutputDisplay extends StatelessWidget {
  /// 已输出的文本
  final String text;

  const TextOutputDisplay({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                '输出文本',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (text.isEmpty)
            Text(
              '输入的文本将显示在这里',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade400,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
