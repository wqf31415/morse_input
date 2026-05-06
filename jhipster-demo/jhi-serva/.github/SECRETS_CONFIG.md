# GitHub Secrets 配置指南

本指南帮助你在GitHub仓库中配置所需的Secrets，以便GitHub Actions工作流能够正常运行。

## 1. 配置Secrets的步骤

1. 进入你的GitHub仓库
2. 点击 **Settings**（设置）
3. 在左侧菜单中选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret** 按钮
5. 添加以下所需的Secrets

## 2. 必需Secrets

### SONAR_TOKEN（代码质量扫描）

- **用途**: SonarCloud代码质量扫描
- **获取方式**:
  1. 访问 https://sonarcloud.io
  2. 使用GitHub账号登录
  3. 进入你的项目 → Administration → Security → Users → Tokens
  4. 生成新Token并复制

### DOCKER_REGISTRY_TOKEN（Docker镜像仓库）

- **用途**: Docker镜像推送到私有仓库（如Docker Hub）
- **获取方式**:
  1. Docker Hub: https://hub.docker.com/settings/security
  2. 生成Access Token

## 3. 可选Secrets

### ANDROID_SIGNING_KEY（Android应用签名）

- **用途**: 为Android发布版本APK签名
- **获取方式**:
  1. 生成keystore文件（使用keytool）
  2. 将keystore文件Base64编码后存储

示例命令:
```bash
# 生成keystore
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

# Base64编码
base64 my-release-key.jks | tr -d '\n'
```

需要配置的Secrets:
- `ANDROID_SIGNING_KEY`: Base64编码的keystore文件
- `ANDROID_KEYSTORE_PASSWORD`: keystore密码
- `ANDROID_KEY_ALIAS`: 密钥别名
- `ANDROID_KEY_PASSWORD`: 密钥密码

### HARMONY_SDK_TOKEN（鸿蒙应用构建）

- **用途**: 下载HarmonyOS SDK进行应用构建
- **获取方式**: 华为开发者联盟官网

### NEXUS_USERNAME / NEXUS_PASSWORD（私有Maven仓库）

- **用途**: 从私有Maven仓库拉取依赖
- **获取方式**: Nexus仓库管理员提供

## 4. 配置示例

### GitHub CLI方式

```bash
# 使用GitHub CLI配置Secrets
gh secret set SONAR_TOKEN -b "your-sonar-token"
gh secret set DOCKER_REGISTRY_TOKEN -b "your-docker-token"

# Android签名配置
gh secret set ANDROID_SIGNING_KEY -b "$(base64 my-release-key.jks | tr -d '\n')"
gh secret set ANDROID_KEYSTORE_PASSWORD -b "keystore-password"
gh secret set ANDROID_KEY_ALIAS -b "my-key-alias"
gh secret set ANDROID_KEY_PASSWORD -b "key-password"
```

### 手动配置

1. 进入仓库 Settings → Secrets and variables → Actions
2. 点击 "New repository secret"
3. 添加以下Secrets:

| Secret名称 | 说明 | 示例值 |
|-----------|------|-------|
| SONAR_TOKEN | SonarCloud访问令牌 | `sqc_xxxxxxxxxxxxx` |
| DOCKER_REGISTRY_TOKEN | Docker仓库令牌 | `dckr_pat_xxxxx` |
| ANDROID_SIGNING_KEY | Base64编码的签名文件 | `MIIKw...` |
| ANDROID_KEYSTORE_PASSWORD | keystore密码 | `password` |
| ANDROID_KEY_ALIAS | 密钥别名 | `release-key` |
| ANDROID_KEY_PASSWORD | 密钥密码 | `password` |

## 5. 环境变量配置（Variables）

除了Secrets，有些配置建议使用Variables:

1. 进入仓库 Settings → Secrets and variables → Actions
2. 点击 **Variables** 标签
3. 点击 **New repository variable**

建议配置的Variables:

| Variable名称 | 说明 | 示例值 |
|-------------|------|-------|
| JAVA_VERSION | Java版本 | `11` |
| MAVEN_OPTS | Maven JVM参数 | `-Xmx2048m` |
| DOCKER_REGISTRY | Docker镜像仓库地址 | `ghcr.io` |
| DOCKER_IMAGE_PREFIX | 镜像前缀 | `mycompany` |

## 6. 验证配置

配置完成后，可以触发一个测试workflow来验证:

```bash
# 使用GitHub CLI触发测试
gh workflow run ci.yml --ref main
```

检查Actions页面，确保所有Jobs都成功执行。

## 7. 常见问题

### Q: Secrets没有生效怎么办？

A: 检查以下几点:
- Secrets名称是否完全匹配（区分大小写）
- Secrets是否在正确的仓库中配置
- 确保Secrets已启用（Repository secrets）

### Q: 推送Docker镜像失败？

A: 确认以下配置:
- `GITHUB_TOKEN`已自动配置（不需要手动添加）
- 如果使用Docker Hub，需要配置`DOCKER_REGISTRY_TOKEN`
- 镜像名称是否正确

### Q: Android构建失败？

A: 常见原因:
- Keystore文件Base64编码有误
- 密钥别名或密码配置错误
- ANDROID_SIGNING_KEY包含换行符

## 8. 安全建议

1. **定期轮换Secrets**: 定期更换访问令牌
2. **使用最小权限**: 只授予必要的权限
3. **不要在日志中打印Secrets**: Workflow已自动屏蔽Secrets输出
4. **使用Organization secrets**: 如果有多个仓库，在Organization级别配置Secrets
5. **审计日志**: 定期检查GitHub Actions的使用日志

## 9. 链接资源

- [GitHub Actions文档](https://docs.github.com/cn/actions)
- [管理GitHub Secrets](https://docs.github.com/cn/actions/security-guides/encrypted-secrets)
- [SonarCloud](https://sonarcloud.io)
- [华为开发者联盟](https://developer.huawei.com)
