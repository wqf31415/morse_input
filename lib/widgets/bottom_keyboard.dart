// 底部键盘区域组件
// 上方行：[退格][电码显示区][清除]
// 下方行：[设置][空格][回车]
import 'package:flutter/material.dart';

/// 上方行：退格 | 电码显示 | 清除
class TopRow extends StatelessWidget {
  final String morseCode;
  final bool isAutoConverting;
  final VoidCallback onMorseTap;
  final VoidCallback onBackspace;
  final VoidCallback onClearMorse;

  const TopRow({
    super.key,
    required this.morseCode,
    required this.isAutoConverting,
    required this.onMorseTap,
    required this.onBackspace,
    required this.onClearMorse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NarrowButton(
          icon: Icons.backspace_outlined,
          label: '退格',
          onTap: onBackspace,
          color: Colors.orange.shade50,
          iconColor: Colors.orange.shade700,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MorseDisplay(
            morseCode: morseCode,
            isAutoConverting: isAutoConverting,
            onTap: onMorseTap,
          ),
        ),
        const SizedBox(width: 6),
        _NarrowButton(
          icon: Icons.clear,
          label: '清除',
          onTap: onClearMorse,
          color: Colors.purple.shade50,
          iconColor: Colors.purple.shade700,
        ),
      ],
    );
  }
}

/// 下方行：设置 | 空格 | 回车
class BottomRow extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onSpace;
  final VoidCallback onNewline;

  const BottomRow({
    super.key,
    required this.onSettings,
    required this.onSpace,
    required this.onNewline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NarrowButton(
          icon: Icons.settings_outlined,
          label: '设置',
          onTap: onSettings,
          color: Colors.grey.shade100,
          iconColor: Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _WideButton(
            icon: Icons.space_bar,
            label: '空格',
            onTap: onSpace,
            color: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 6),
        _NarrowButton(
          icon: Icons.keyboard_return,
          label: '回车',
          onTap: onNewline,
          color: Colors.green.shade50,
          iconColor: Colors.green.shade700,
        ),
      ],
    );
  }
}

/// 窄按钮（退格、清除、设置、回车）
class _NarrowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _NarrowButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 宽按钮（空格）
class _WideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _WideButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 电码显示区域
class _MorseDisplay extends StatelessWidget {
  final String morseCode;
  final bool isAutoConverting;
  final VoidCallback onTap;

  const _MorseDisplay({
    required this.morseCode,
    required this.isAutoConverting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCode = morseCode.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: hasCode ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAutoConverting ? Colors.orange.shade400 : Colors.grey.shade300,
            width: isAutoConverting ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('电码', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                if (isAutoConverting) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('转换中', style: TextStyle(fontSize: 8, color: Colors.orange.shade700)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hasCode ? morseCode : '...',
              style: TextStyle(
                fontSize: 22,
                color: hasCode ? Colors.blue.shade800 : Colors.grey.shade400,
                letterSpacing: 4,
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
