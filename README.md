# Anoawa Releases

Anoawa 客户端的安装包分发仓库。游戏本体仓库是私有的，这里**只放发布产物**，
不含源码。

## 下载

| 平台 | 下载 | 说明 |
|---|---|---|
| Android | [Anoawa-Android.apk](https://github.com/GBTP/Anoawa-Releases/releases/latest/download/Anoawa-Android.apk) | 直接安装，需要允许「未知来源」 |
| Windows | [Anoawa-Windows-x64.zip](https://github.com/GBTP/Anoawa-Releases/releases/latest/download/Anoawa-Windows-x64.zip) | 解压后运行 `Anoawa.exe`，仅 64 位 |
| iOS | [TestFlight](https://testflight.apple.com/join/XMcFWlQA) | 不在本仓库分发，走 Apple 的公测渠道 |

上面两个链接**永远指向最新版**，历史版本在 [Releases](https://github.com/GBTP/Anoawa-Releases/releases) 页面。

GitHub 在国内下载可能很慢或连不上，社区群里也有同一份安装包：
QQ 一群 `694748554`、二群 `499564108`、QQ 频道 `ngqny4035b`。

## 安装

**Android** — 下载 APK 后直接点开安装。系统会提示来源未知，允许即可（本仓库的包
没有经过 Google Play 签名验证，这是侧载的正常提示）。Android 11 及以上首次导入
谱面时还会要求授予文件访问权限。

**Windows** — 解压整个压缩包再运行 `Anoawa.exe`。不要只把 exe 拖出来，它依赖同级的
`Anoawa_Data/`。SmartScreen 可能拦截未签名的可执行文件，选「仍要运行」。

## 校验文件完整性

每个 release 的说明里都附 SHA-256。下载后比对：

```bash
# macOS / Linux
shasum -a 256 Anoawa-Android.apk

# Windows PowerShell
Get-FileHash Anoawa-Android.apk -Algorithm SHA256
```

对不上就是传输损坏或来源不对，别装。

## 发布约定

**资产文件名是固定的，不带版本号。** 官网 <https://anoawa.cc/get.html> 的下载按钮
直接硬链到 `releases/latest/download/<固定文件名>`，改名会让官网下载按钮 404。
版本号记在 tag、标题和说明里，不进文件名。

| 项 | 格式 |
|---|---|
| tag | `v1.1.2`（对齐 Unity 的 `bundleVersion`） |
| 标题 | `Anoawa v1.1.2` |
| Android 资产 | `Anoawa-Android.apk` |
| Windows 资产 | `Anoawa-Windows-x64.zip` |

不要发布 Unity 产出的 `*_BurstDebugInformation_DoNotShip/`——那是调试符号，
名字里已经写了别发。

发布用 `scripts/publish.sh`，它负责改名、算校验和、建 release：

```bash
scripts/publish.sh 1.1.2 ~/Desktop/build/AnoawaV1.1.2.Apk ~/Desktop/build/AnoawaV1.1.2.zip
```

## 相关仓库

| | 是什么 | 可见性 |
|---|---|---|
| [Dnoawa](https://github.com/GBTP/Dnoawa) | 社区网站 anoawa.cc | 公开 |
| Anoawa | Unity 客户端 | 私有 |
| Bnoawa | 后端 API | 私有 |
