// 莫尔斯电码输入法 - 主界面
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/morse_input_engine.dart';
import 'widgets/morse_input_button.dart';
import 'widgets/text_output_display.dart';
import 'widgets/bottom_keyboard.dart' show TopRow, BottomRow;
import 'widgets/settings_dialog.dart';
import 'widgets/morse_reference_table.dart';

void main() {
  runApp(const MorseInputApp());
}

class MorseInputApp extends StatelessWidget {
  const MorseInputApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '莫尔斯电码输入法',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: ChangeNotifierProvider(
        create: (_) => MorseInputEngine(),
        child: const MorseInputScreen(),
      ),
    );
  }
}

class MorseInputScreen extends StatefulWidget {
  const MorseInputScreen({super.key});

  @override
  State<MorseInputScreen> createState() => _MorseInputScreenState();
}

class _MorseInputScreenState extends State<MorseInputScreen> {
  bool _isPressing = false;
  bool _showReference = false;

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSettings(BuildContext context, MorseInputEngine engine) {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        currentConfig: engine.config,
        onConfigChanged: (newConfig) => engine.updateConfig(newConfig),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const isDesktop = !kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text('莫尔斯电码输入法'),
        centerTitle: true,
        actions: [
          if (isDesktop)
            Consumer<MorseInputEngine>(
              builder: (context, engine, _) {
                return IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(engine.outputText),
                  tooltip: '复制文本到剪贴板',
                );
              },
            ),
          IconButton(
            icon: Icon(_showReference ? Icons.help : Icons.help_outline),
            onPressed: () => setState(() => _showReference = !_showReference),
            tooltip: '电码参考表',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<MorseInputEngine>(
          builder: (context, engine, child) {
            return Column(
              children: [
                // 已输出文本区域
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextOutputDisplay(text: engine.outputText),
                ),

                // 桌面端复制提示
                if (isDesktop && engine.outputText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _copyToClipboard(engine.outputText),
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('复制文本', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ),

                // 参考表（可折叠）
                if (_showReference)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: const MorseReferenceTable(),
                  ),

                const Spacer(),

                // 底部键盘区域
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 第一行：[退格][电码][清除]
                      TopRow(
                        morseCode: engine.currentMorse,
                        isAutoConverting: engine.isAutoConverting,
                        onMorseTap: () {
                          if (engine.currentMorse.isNotEmpty) {
                            engine.manualConvert();
                          }
                        },
                        onBackspace: engine.backspace,
                        onClearMorse: engine.clearCurrentMorse,
                      ),

                      const SizedBox(height: 10),

                      // 圆形输入按钮（两侧空白可点击转换电码）
                      MorseInputButton(
                        isPressing: _isPressing,
                        shape: engine.config.buttonShape,
                        onTapEmpty: () {
                          if (engine.currentMorse.isNotEmpty) {
                            engine.manualConvert();
                          }
                        },
                        onPressed: () {
                          setState(() => _isPressing = true);
                          engine.onPressed();
                        },
                        onReleased: () {
                          setState(() => _isPressing = false);
                          engine.onReleased();
                        },
                      ),

                      const SizedBox(height: 10),

                      // 第三行：[设置][空格][回车]
                      BottomRow(
                        onSettings: () => _openSettings(context, engine),
                        onSpace: engine.insertSpace,
                        onNewline: engine.insertNewline,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
