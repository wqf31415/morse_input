/// 设置弹窗组件
/// 允许用户配置自动空格、电码转换时长、按钮形状等参数
import 'package:flutter/material.dart';
import '../services/morse_input_engine.dart';

class SettingsDialog extends StatefulWidget {
  final MorseEngineConfig currentConfig;
  final ValueChanged<MorseEngineConfig> onConfigChanged;

  const SettingsDialog({
    super.key,
    required this.currentConfig,
    required this.onConfigChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _autoSpace;
  late double _charTimeoutSec;
  late double _wordTimeoutSec;
  late ButtonShape _buttonShape;

  @override
  void initState() {
    super.initState();
    _autoSpace = widget.currentConfig.autoSpace;
    _charTimeoutSec = widget.currentConfig.charTimeoutMs / 1000.0;
    _wordTimeoutSec = widget.currentConfig.wordTimeoutMs / 1000.0;
    _buttonShape = widget.currentConfig.buttonShape;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('输入设置'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 按钮形状
            _buildSection(
              '输入按钮形状',
              '选择输入按钮的外观形状',
              _buildShapeSelector(),
            ),

            const SizedBox(height: 16),

            // 自动添加空格
            _buildSection(
              '自动添加空格',
              '字符转换后，超过一定时间无新输入时自动插入空格',
              SwitchListTile(
                value: _autoSpace,
                onChanged: (v) => setState(() => _autoSpace = v),
                title: const Text('启用自动空格'),
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.blue,
              ),
            ),

            const SizedBox(height: 16),

            // 电码自动转换时长
            _buildSliderSection(
              '电码自动转换时长',
              '最后一次输入后，超过此时长自动将电码转换为字符',
              _charTimeoutSec,
              0.3,
              3.0,
              (v) => setState(() => _charTimeoutSec = v),
              '${_charTimeoutSec.toStringAsFixed(1)} 秒',
            ),

            const SizedBox(height: 16),

            // 单词间隔时长
            _buildSliderSection(
              '自动空格间隔时长',
              '字符转换后，超过此时长自动插入空格分隔单词',
              _wordTimeoutSec,
              0.5,
              5.0,
              (v) => setState(() => _wordTimeoutSec = v),
              '${_wordTimeoutSec.toStringAsFixed(1)} 秒',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfigChanged(MorseEngineConfig(
              autoSpace: _autoSpace,
              charTimeoutMs: (_charTimeoutSec * 1000).round(),
              wordTimeoutMs: (_wordTimeoutSec * 1000).round(),
              buttonShape: _buttonShape,
            ));
            Navigator.of(context).pop();
          },
          child: const Text('确定'),
        ),
      ],
    );
  }

  /// 形状选择器
  Widget _buildShapeSelector() {
    return Row(
      children: ButtonShape.values.map((shape) {
        final isSelected = _buttonShape == shape;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => setState(() => _buttonShape = shape),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: isSelected
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue, width: 2),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 形状预览图标
                      _buildShapePreview(shape, isSelected),
                      const SizedBox(height: 6),
                      Text(
                        shape.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 形状预览小图标
  Widget _buildShapePreview(ButtonShape shape, bool isSelected) {
    final color = isSelected ? Colors.blue.shade600 : Colors.grey.shade400;
    switch (shape) {
      case ButtonShape.circle:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      case ButtonShape.roundedRect:
        return Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: color,
          ),
        );
      case ButtonShape.stadium:
        return Container(
          width: 44,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: color,
          ),
        );
    }
  }

  Widget _buildSection(String title, String description, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSliderSection(
    String title,
    String description,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String label,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).round(),
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ],
    );
  }
}
