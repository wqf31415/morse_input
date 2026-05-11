/// 莫尔斯电码大按钮组件
/// 核心输入按钮，支持按压检测、视觉反馈、多种形状
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/morse_input_engine.dart';

class MorseInputButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final bool isPressing;
  final ButtonShape shape;
  final VoidCallback? onTapEmpty; // 点击按钮旁空白区域

  const MorseInputButton({
    super.key,
    required this.onPressed,
    required this.onReleased,
    this.isPressing = false,
    this.shape = ButtonShape.circle,
    this.onTapEmpty,
  });

  @override
  State<MorseInputButton> createState() => _MorseInputButtonState();
}

class _MorseInputButtonState extends State<MorseInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MorseInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressing) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// 根据形状获取 BoxDecoration
  BoxDecoration _buildDecoration(bool isPressing) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isPressing
          ? [Colors.blue.shade400, Colors.blue.shade600]
          : [Colors.blue.shade600, Colors.blue.shade900],
    );
    final shadow = BoxShadow(
      color: isPressing
          ? Colors.blue.withOpacity(0.5)
          : Colors.blue.withOpacity(0.3),
      blurRadius: isPressing ? 20 : 10,
      spreadRadius: isPressing ? 2 : 0,
      offset: const Offset(0, 4),
    );

    switch (widget.shape) {
      case ButtonShape.circle:
        return BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: [shadow],
        );
      case ButtonShape.roundedRect:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [shadow],
        );
      case ButtonShape.stadium:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          gradient: gradient,
          boxShadow: [shadow],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPressing = widget.isPressing;
    final isCircle = widget.shape == ButtonShape.circle;

    // 按钮本体
    final button = GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapUp: (_) => widget.onReleased(),
      onTapCancel: () => widget.onReleased(),
      child: AnimatedBuilder(
        listenable: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: isCircle ? 120 : double.infinity,
              height: 80,
              decoration: _buildDecoration(isPressing),
              child: Center(
                child: Icon(
                  Icons.radio_button_checked,
                  size: isCircle ? 56 : 40,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          );
        },
      ),
    );

    // 如果有空白区域点击回调，用 Row 包裹按钮两侧空白
    if (widget.onTapEmpty != null) {
      return Row(
        children: [
          // 左侧空白区域
          Expanded(
            child: GestureDetector(
              onTap: widget.onTapEmpty,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(height: 80),
            ),
          ),
          // 按钮居中
          if (isCircle) button else Expanded(child: button),
          // 右侧空白区域
          Expanded(
            child: GestureDetector(
              onTap: widget.onTapEmpty,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(height: 80),
            ),
          ),
        ],
      );
    }

    return button;
  }
}

/// AnimatedBuilder
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
