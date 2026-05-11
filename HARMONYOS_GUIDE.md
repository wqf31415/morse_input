# 鸿蒙 (HarmonyOS) 适配指南

## 概述

本项目使用 Flutter 框架开发，核心 Dart 代码可在鸿蒙系统上运行。鸿蒙 NEXT（HarmonyOS 5.0+）已支持 Flutter，但需要额外配置。

## 方案一：通过 Flutter HarmonyOS 适配层运行（推荐）

### 1. 安装鸿蒙 Flutter 适配工具

```bash
# 克隆鸿蒙 Flutter 适配仓库
git clone https://gitee.com/openharmony-sig/flutter_flutter.git
cd flutter_flutter
# 按照仓库 README 安装到本地
```

### 2. 创建鸿蒙工程并集成

```bash
# 在项目根目录下
flutter create --platforms ohos .
```

### 3. 鸿蒙输入法服务

在 `ohos/entry/src/main/module.json5` 中注册输入法服务：

```json
{
  "module": {
    "name": "entry",
    "type": "entry",
    "abilities": [
      {
        "name": "MorseInputMethodAbility",
        "srcEntry": "./ets/morseinputmethod/MorseInputMethodAbility.ets",
        "description": "莫尔斯电码输入法",
        "icon": "$media:app_icon",
        "label": "莫尔斯电码输入法"
      }
    ],
    "extensionAbilities": [
      {
        "name": "MorseInputMethodExtensionAbility",
        "srcEntry": "./ets/morseinputmethod/MorseInputMethodExtensionAbility.ets",
        "description": "莫尔斯电码输入法扩展",
        "type": "inputMethod"
      }
    ]
  }
}
```

### 4. 鸿蒙输入法实现 (ArkTS)

文件路径: `ohos/entry/src/main/ets/morseinputmethod/MorseInputMethodExtensionAbility.ets`

```typescript
import { InputMethodExtensionAbility, InputMethodSetting } from '@ohos.InputMethodExtensionAbility';
import { InputMethodController } from '@ohos.InputMethod';

// 莫尔斯电码映射
const MORSE_MAP: Record<string, string> = {
  '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D',
  '.': 'E', '..-.': 'F', '--.': 'G', '....': 'H',
  '..': 'I', '.---': 'J', '-.-': 'K', '.-..': 'L',
  '--': 'M', '-.': 'N', '---': 'O', '.--.': 'P',
  '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
  '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X',
  '-.--': 'Y', '--..': 'Z',
  '-----': '0', '.----': '1', '..---': '2', '...--': '3',
  '....-': '4', '.....': '5', '-....': '6', '--...': '7',
  '---..': '8', '----.': '9',
};

export default class MorseInputMethodExtensionAbility extends InputMethodExtensionAbility {
  private currentMorse: string = '';
  private pressStartTime: number = 0;
  private isPressing: boolean = false;
  private controller: InputMethodController = new InputMethodController();

  // 时间阈值
  private readonly PRESS_THRESHOLD = 200;  // 短按/长按分界 (ms)
  private readonly CHAR_TIMEOUT = 1000;    // 字符自动转换超时 (ms)

  onAttach(context: any) {
    super.onAttach(context);
  }

  onDetach() {
    super.onDetach();
  }

  // 处理按压
  handlePressDown() {
    this.isPressing = true;
    this.pressStartTime = Date.now();
  }

  // 处理释放
  handlePressUp() {
    if (!this.isPressing) return;
    this.isPressing = false;

    const duration = Date.now() - this.pressStartTime;
    const signal = duration < this.PRESS_THRESHOLD ? '.' : '-';
    this.addSignal(signal);
  }

  // 添加信号
  private addSignal(signal: string) {
    this.currentMorse += signal;
    // 启动自动转换定时器
    setTimeout(() => {
      this.convertCurrentMorse();
    }, this.CHAR_TIMEOUT);
  }

  // 转换当前电码
  private convertCurrentMorse() {
    if (this.currentMorse.isEmpty()) return;
    const char = MORSE_MAP[this.currentMorse];
    if (char) {
      this.controller.insertText(char);
    }
    this.currentMorse = '';
  }

  // 退格
  handleBackspace() {
    if (this.currentMorse.length > 0) {
      this.currentMorse = this.currentMorse.slice(0, -1);
    } else {
      this.controller.deleteBackward();
    }
  }

  // 空格
  handleSpace() {
    if (this.currentMorse.isNotEmpty) {
      this.convertCurrentMorse();
    }
    this.controller.insertText(' ');
  }

  // 换行
  handleNewline() {
    if (this.currentMorse.isNotEmpty) {
      this.convertCurrentMorse();
    }
    this.controller.insertText('\n');
  }

  // 清除电码
  handleClear() {
    this.currentMorse = '';
  }
}
```

## 方案二：通过 Android 兼容层运行（鸿蒙 4.x 及以下）

鸿蒙 4.x 及以下版本支持 Android 应用兼容运行。本项目的 Android APK 可以直接安装运行：

1. 构建 Android APK：`flutter build apk`
2. 在鸿蒙设备上启用"Android 应用兼容"功能
3. 安装 APK 即可使用

## 注意事项

- 鸿蒙 NEXT (5.0+) 需要使用 DevEco Studio 进行开发调试
- 鸿蒙输入法需要在系统设置中手动启用并设为默认输入法
- 鸿蒙的输入法 API 与 Android 的 InputMethodService 有差异，需要使用 ArkTS 重写输入法服务
- 核心业务逻辑（莫尔斯电码映射、输入引擎）可以直接复用 Dart 代码
