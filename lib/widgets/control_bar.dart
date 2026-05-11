/// 控制按钮栏组件
/// 包含退格、空格、换行、清除电码等操作按钮
import 'package:flutter/material.dart';

class ControlBar extends StatelessWidget {
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final VoidCallback onNewline;
  final VoidCallback onClearMorse;
  final VoidCallback onClearAll;

  const ControlBar({
    super.key,
    required this.onBackspace,
    required this.onSpace,
    required this.onNewline,
    required this.onClearMorse,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 退格按钮
        Expanded(
          child: _ControlButton(
            icon: Icons.backspace_outlined,
            label: '退格',
            onTap: onBackspace,
            color: Colors.orange.shade50,
            iconColor: Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 8),
        // 空格按钮
        Expanded(
          child: _ControlButton(
            icon: Icons.space_bar,
            label: '空格',
            onTap: onSpace,
            color: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 8),
        // 换行按钮
        Expanded(
          child: _ControlButton(
            icon: Icons.keyboard_return,
            label: '换行',
            onTap: onNewline,
            color: Colors.green.shade50,
            iconColor: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 8),
        // 清除电码按钮
        Expanded(
          child: _ControlButton(
            icon: Icons.clear,
            label: '清除电码',
            onTap: onClearMorse,
            color: Colors.purple.shade50,
            iconColor: Colors.purple.shade700,
          ),
        ),
        const SizedBox(width: 8),
        // 清除全部按钮
        Expanded(
          child: _ControlButton(
            icon: Icons.delete_sweep,
            label: '全部清除',
            onTap: onClearAll,
            color: Colors.red.shade50,
            iconColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _ControlButton({
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: iconColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
