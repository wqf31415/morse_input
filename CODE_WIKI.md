# Morse Input - 莫尔斯电码输入法 Code Wiki

## 项目概述

**项目名称**: Morse Input (莫尔斯电码输入法)  
**项目类型**: Flutter 跨平台应用  
**核心功能**: 通过按压时长区分点(.)和划(-)信号,实现莫尔斯电码输入转换为文字  
**目标平台**: Android, Windows, Linux, Web

---

## 1. 项目整体架构

### 1.1 技术栈

| 类别 | 技术 |
|------|------|
| **框架** | Flutter 3.x |
| **状态管理** | Provider |
| **编程语言** | Dart |
| **最低 SDK** | Android 21 (Lollipop) |

### 1.2 架构模式

```
lib/
├── main.dart                    # 应用程序入口
├── models/                      # 数据模型层
│   └── morse_code_map.dart      # 莫尔斯电码映射表
├── services/                     # 服务层
│   ├── morse_input_engine.dart   # 核心输入引擎
│   ├── feedback_service.dart     # 音效与振动反馈
│   └── windows_platform_service.dart # Windows平台服务
└── widgets/                      # UI组件层
    ├── morse_input_button.dart   # 莫尔斯输入按钮
    ├── bottom_keyboard.dart      # 底部键盘
    ├── text_output_display.dart  # 文本输出显示
    ├── morse_reference_table.dart # 电码参考表
    ├── settings_dialog.dart      # 设置对话框
    ├── morse_code_display.dart   # 电码显示组件
    └── control_bar.dart          # 控制按钮栏
```

### 1.3 架构图

```
┌─────────────────────────────────────────────────────┐
│                    main.dart                         │
│            (MorseInputApp / MorseInputScreen)        │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│              MorseInputEngine (ChangeNotifier)       │
│  ┌─────────────────────────────────────────────────┐ │
│  │ - 状态管理: EngineState (idle/pressing/buffering)│ │
│  │ - 电码缓冲: currentMorse (如 ".-")               │ │
│  │ - 输出文本: outputText                           │ │
│  │ - 配置管理: MorseEngineConfig                    │ │
│  │ - 定时器管理: charTimer / wordTimer              │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────┬───────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌────────────────┐
│ MorseCodeMap │ │ Feedback │ │ WindowsPlatform │
│   (Model)    │ │ Service  │ │    Service     │
└──────────────┘ └──────────┘ └────────────────┘
```

---

## 2. 主要模块职责

### 2.1 模型层 (models/)

#### MorseCodeMap
**文件**: `lib/models/morse_code_map.dart`

**职责**: 定义莫尔斯电码与字符之间的映射关系

**核心内容**:
- **charToMorse**: `Map<String, String>` - 字符到电码的映射
  - 包含 26 个英文字母 (A-Z)
  - 包含 10 个数字 (0-9)
  - 包含常用标点符号 (.,?!'/等)
- **morseToChar**: `Map<String, String>` - 电码到字符的反向映射

**核心方法**:
| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `decode(morse)` | String | String? | 将电码转换为字符,无效返回null |
| `encode(char)` | String | String? | 将字符转换为电码,不支持返回null |
| `isValidMorse(morse)` | String | bool | 检查电码是否有效 |
| `supportedChars` | - | List<String> | 获取所有支持的字符列表 |

**使用示例**:
```dart
MorseCodeMap.decode('.-');    // 返回 'A'
MorseCodeMap.encode('S');     // 返回 '...'
MorseCodeMap.isValidMorse('..-'); // 返回 true
```

---

### 2.2 服务层 (services/)

#### MorseInputEngine
**文件**: `lib/services/morse_input_engine.dart`

**职责**: 核心输入引擎,处理按压检测、电码缓冲、自动转换逻辑

**类结构**:

```
MorseInputEngine (ChangeNotifier)
├── 枚举: MorseSignal (dot/dash)
├── 枚举: ButtonShape (circle/roundedRect/stadium)
├── 类: MorseEngineConfig
│   ├── pressThresholdMs: int (默认200ms)
│   ├── charTimeoutMs: int (默认1000ms)
│   ├── wordTimeoutMs: int (默认2000ms)
│   ├── autoSpace: bool (默认true)
│   └── buttonShape: ButtonShape (默认circle)
├── 枚举: EngineState (idle/pressing/buffering/converting)
└── 状态变量
    ├── currentMorse: String
    ├── outputText: String
    ├── isAutoConverting: bool
    └── lastPressDurationMs: int
```

**核心方法**:

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `onPressed()` | - | void | 处理按钮按下,记录开始时间 |
| `onReleased()` | - | void | 处理按钮释放,根据时长判断dot/dash |
| `manualConvert()` | - | void | 手动触发电码转换 |
| `insertSpace()` | - | void | 插入空格(先转换当前电码) |
| `insertNewline()` | - | void | 插入换行(先转换当前电码) |
| `backspace()` | - | void | 退格删除 |
| `clearCurrentMorse()` | - | void | 清除当前电码 |
| `clearAll()` | - | void | 清除所有内容 |
| `updateConfig(config)` | MorseEngineConfig | void | 更新配置 |

**状态转换图**:

```
[idle] ---onPressed()---> [pressing]
[pressing] ---onReleased()---> [buffering]
[buffering] ---charTimeout---> [converting]
[buffering] ---manualConvert---> [idle]
[converting] ---完成---> [idle]
[buffering] ---onPressed()---> [pressing] (继续输入)
```

**输入逻辑**:
1. 按下 < `pressThresholdMs`(200ms) → 点(dot) `.`
2. 按下 >= `pressThresholdMs`(200ms) → 划(dash) `-`
3. 字符间停顿超过 `charTimeoutMs` → 自动转换为字符
4. 单词间隔超过 `wordTimeoutMs` → 自动插入空格

---

#### FeedbackService
**文件**: `lib/services/feedback_service.dart`

**职责**: 提供音效与振动反馈

**核心方法**:

| 方法 | 说明 |
|------|------|
| `playDotSound()` | 播放点的音效(短促高音) |
| `playDashSound()` | 播放划的音效(较长低音) |
| `playConvertSound()` | 播放转换成功音效 |
| `playErrorSound()` | 播放错误音效(无效电码) |
| `vibrateDot()` | 短振动(点反馈) |
| `vibrateDash()` | 长振动(划反馈) |

**实现机制**: 通过 `MethodChannel` 调用原生平台代码,失败时回退到 Flutter HapticFeedback

---

#### WindowsPlatformService
**文件**: `lib/services/windows_platform_service.dart`

**职责**: 提供 Windows 平台特有功能

**核心方法**:

| 方法 | 说明 |
|------|------|
| `copyToClipboard(text)` | 将文本复制到剪贴板 |
| `isWindows` | 检查是否运行在 Windows |
| `isAndroid` | 检查是否运行在 Android |

---

### 2.3 UI组件层 (widgets/)

#### MorseInputButton
**文件**: `lib/widgets/morse_input_button.dart`

**职责**: 核心输入按钮组件,支持按压检测和视觉反馈

**属性**:
| 属性 | 类型 | 说明 |
|------|------|------|
| `onPressed` | VoidCallback | 按钮按下回调 |
| `onReleased` | VoidCallback | 按钮释放回调 |
| `isPressing` | bool | 是否正在按压 |
| `shape` | ButtonShape | 按钮形状(circle/roundedRect/stadium) |
| `onTapEmpty` | VoidCallback? | 点击空白区域回调 |

**特性**:
- 支持三种形状: 圆形、圆角矩形、胶囊形
- 按下时有缩放动画(scale 0.92)
- 渐变背景色和阴影效果
- 两侧空白区域可点击触发转换

---

#### BottomKeyboard
**文件**: `lib/widgets/bottom_keyboard.dart`

**职责**: 底部键盘区域,包含控制按钮

**子组件**:

1. **TopRow** (第一行)
   - 退格按钮 `[退格]`
   - 电码显示区 `[电码: ...]`
   - 清除按钮 `[清除]`

2. **BottomRow** (第二行)
   - 设置按钮 `[设置]`
   - 空格按钮 `[空格]`
   - 回车按钮 `[回车]`

3. **_MorseDisplay** (电码显示)
   - 显示当前输入的电码(如 `.-..`)
   - 自动转换时有橙色边框提示

4. **_NarrowButton** / **_WideButton**
   - 统一的按钮样式组件

---

#### TextOutputDisplay
**文件**: `lib/widgets/text_output_display.dart`

**职责**: 显示已转换输出的文本

**特性**:
- 空状态时显示占位文字
- 自动滚动到最新内容
- 白色卡片式容器

---

#### MorseReferenceTable
**文件**: `lib/widgets/morse_reference_table.dart`

**职责**: 莫尔斯电码参考表,帮助用户查询编码

**内容**:
- 字母表 A-Z 及其电码
- 数字 0-9 及其电码
- 折叠式设计,按需显示

---

#### SettingsDialog
**文件**: `lib/widgets/settings_dialog.dart`

**职责**: 设置弹窗,配置输入参数

**可配置项**:

| 配置项 | 类型 | 范围 | 说明 |
|--------|------|------|------|
| `buttonShape` | ButtonShape | 3种 | 输入按钮形状 |
| `autoSpace` | bool | - | 是否启用自动空格 |
| `charTimeoutMs` | int | 300-3000ms | 电码自动转换时长 |
| `wordTimeoutMs` | int | 500-5000ms | 自动空格间隔时长 |

---

#### MorseCodeDisplay
**文件**: `lib/widgets/morse_code_display.dart`

**职责**: 电码显示组件(独立版本)

**特性**:
- 大字体显示当前电码
- 支持点击快速转换
- 自动转换提示

---

#### ControlBar
**文件**: `lib/widgets/control_bar.dart`

**职责**: 控制按钮栏

**按钮**:
- 退格 (backspace)
- 空格 (space)
- 换行 (newline)
- 清除电码 (clearMorse)
- 全部清除 (clearAll)

---

## 3. 核心流程详解

### 3.1 莫尔斯电码输入流程

```
用户操作                    引擎处理                    结果
────────────────────────────────────────────────────────────────
点击按钮 ──────────► onPressed()
                             ├── 记录开始时间
                             ├── 取消定时器
                             └── 状态: pressing
                                    
松开按钮 ──────────► onReleased()
                             ├── 计算按压时长
                             ├── 时长<200ms → dot('.')
                             │   时长≥200ms → dash('-')
                             ├── 添加到 currentMorse
                             ├── 启动字符超时定时器
                             └── 状态: buffering

[等待中] ──────────► 定时器触发
                             ├── _isAutoConverting = true
                             ├── 100ms延迟
                             └── 调用 _convertCurrentMorse()
                                      │
                                      ▼
                             ├── 查询 MorseCodeMap
                             ├── 转换为字符
                             ├── 追加到 outputText
                             ├── 启动单词超时定时器
                             └── 状态: idle
```

### 3.2 定时器管理

**字符超时定时器 (charTimer)**:
- 在每次添加信号后启动
- 超时后触发自动转换
- 用户继续输入时被取消

**单词超时定时器 (wordTimer)**:
- 在字符转换成功后启动
- 超时后自动插入空格
- 可通过配置 `autoSpace` 禁用

---

## 4. 依赖关系

### 4.1 Pub依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8      # iOS风格图标
  provider: ^6.1.2              # 状态管理

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0        # 代码规范检查
```

### 4.2 平台通道

**FeedbackService 通道**: `com.morse.morse_input/feedback`
- `playDotSound()`: 播放点音效
- `playDashSound()`: 播放划音效
- `playConvertSound()`: 播放转换音效
- `playErrorSound()`: 播放错误音效
- `vibrateDot()`: 点振动
- `vibrateDash()`: 划振动

**WindowsPlatformService 通道**: `com.morse.morse_input/platform`
- `copyToClipboard(text)`: 复制到剪贴板

---

## 5. 项目运行方式

### 5.1 环境要求

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Android Studio / VS Code (Flutter扩展)

### 5.2 运行命令

**开发模式**:
```bash
# 运行到默认设备
flutter run

# 运行到特定平台
flutter run -d android     # Android
flutter run -d windows     # Windows
flutter run -d linux       # Linux
flutter run -d chrome      # Web
```

**构建发布**:
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

### 5.3 项目结构 (Flutter特定)

```
morse_input/
├── android/              # Android平台代码
│   └── app/src/main/kotlin/
│       └── MainActivity.kt  # Android入口
├── lib/                  # Dart/Flutter代码
│   ├── main.dart
│   ├── models/
│   ├── services/
│   └── widgets/
├── linux/                # Linux平台代码
├── windows/               # Windows平台代码
├── web/                  # Web平台代码
├── pubspec.yaml          # 项目配置
└── README.md             # 项目说明
```

---

## 6. 关键配置

### 6.1 MorseEngineConfig 默认值

```dart
const MorseEngineConfig({
  pressThresholdMs: 200,    // 短按/长按分界线
  charTimeoutMs: 1000,      // 字符自动转换超时
  wordTimeoutMs: 2000,       // 单词自动空格超时
  autoSpace: true,           // 启用自动空格
  buttonShape: ButtonShape.circle,  // 按钮形状
});
```

### 6.2 莫尔斯电码标准

**标准规则**:
- `.` (点/dot): 短按,持续时间短
- `-` (划/dash): 长按,持续时间约为点的3倍
- 字符内点划之间停顿极短
- 字符之间有一定停顿(通过定时器检测)
- 单词之间更长停顿(通过定时器检测)

---

## 7. Android输入法服务

**文件**: `android/app/src/main/kotlin/com/morse/morse_input/MorseInputMethodService.kt`

**职责**: 实现 Android 输入法(IME)功能

**配置**: `android/app/src/main/res/xml/method.xml`

---

## 8. 注意事项

1. **跨平台兼容性**: 大部分代码支持全平台,但某些功能(如输入法服务)仅限 Android

2. **状态管理**: 使用 `ChangeNotifier` + `Consumer` 模式,确保 UI 实时响应

3. **定时器清理**: 使用 `dispose()` 方法确保定时器被正确取消,防止内存泄漏

4. **电码有效性**: 无效电码不会转换,直接丢弃

5. **性能优化**: 使用 `const` 构造函数和 `AnimatedBuilder` 减少重建

---

## 9. 快速开始

1. 克隆项目
2. 安装依赖: `flutter pub get`
3. 运行应用: `flutter run`
4. 使用方式:
   - 短按按钮 → 输入点(.)
   - 长按按钮 → 输入划(-)
   - 等待自动转换或点击空白区域手动转换
   - 使用退格、空格、回车按钮进行控制
