# GitHub Action 多平台构建配置

本仓库包含一个GitHub Action工作流，用于在提交到`master`分支时自动构建多平台应用。

## 工作流概述

工作流文件：[build-apps.yml](./build-apps.yml)

### 触发条件
- 推送到 `master` 分支
- 针对 `master` 分支的 Pull Request

### 包含的任务

1. **build-backend**: 构建两个Spring Boot后端应用（jhi-serva和jhi-servb）
2. **build-windows**: 使用jpackage将Spring Boot应用打包为Windows MSI安装包
3. **build-android**: Android应用构建框架（需要根据实际项目调整）
4. **build-harmony**: HarmonyOS应用构建框架（需要根据实际项目调整）
5. **release**: 在master分支推送时自动创建GitHub Release并上传所有构建产物

## 如何使用

### 1. 后端应用构建
当前已配置好，可以直接使用，会构建两个JHipster项目的JAR包。

### 2. Windows安装包
使用jpackage工具将Spring Boot JAR打包为MSI安装包，已配置完成。

### 3. Android应用
要使Android构建正常工作，您需要：
- 将Android项目代码添加到仓库
- 在工作流的`build-android`任务中添加实际的构建命令，例如：
  ```yaml
  - name: Build Android APK/AAB
    run: |
      cd android-app
      ./gradlew assembleRelease
  ```

### 4. HarmonyOS应用
要使HarmonyOS构建正常工作，您需要：
- 将HarmonyOS项目代码添加到仓库
- 配置DevEco Studio构建环境
- 在工作流的`build-harmony`任务中添加实际的构建命令

## 自定义配置

根据您的实际项目需求，您可能需要修改以下内容：

- 应用名称和版本号
- JDK版本
- Android SDK版本
- 构建命令
- 发布配置

## 注意事项

- 本工作流是一个基础框架，需要根据您的实际项目结构进行调整
- Android和HarmonyOS部分需要添加相应的项目代码才能正常工作
- Windows安装包使用jpackage，需要JDK 14+支持
