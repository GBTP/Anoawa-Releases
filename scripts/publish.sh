#!/usr/bin/env bash
#
# 发布一个 Anoawa 版本到 GitHub Releases。
#
#   scripts/publish.sh <版本号> <apk 路径> <windows zip 路径> [--draft]
#   scripts/publish.sh 1.1.2 ~/Desktop/build/AnoawaV1.1.2.Apk ~/Desktop/build/AnoawaV1.1.2.zip
#
# 为什么要这个脚本：官网的下载按钮硬链到 releases/latest/download/<固定文件名>，
# 而 Unity 产出的包名带版本号。手动上传很容易直接把带版本号的文件名传上去，
# 官网就 404 了。这里统一改名，顺便算好校验和写进说明。

set -euo pipefail

REPO="GBTP/Anoawa-Releases"
APK_NAME="Anoawa-Android.apk"
WIN_NAME="Anoawa-Windows-x64.zip"

die() { echo "错误：$*" >&2; exit 1; }

[ $# -ge 3 ] || die "用法：$0 <版本号> <apk 路径> <windows zip 路径> [--draft]"

VERSION="${1#v}"          # 容忍传 v1.1.2 或 1.1.2
APK_SRC="$2"
WIN_SRC="$3"
DRAFT="${4:-}"
TAG="v$VERSION"

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || die "版本号格式不对：$VERSION"
[ -f "$APK_SRC" ] || die "找不到 APK：$APK_SRC"
[ -f "$WIN_SRC" ] || die "找不到 Windows 包：$WIN_SRC"

# Windows 包必须是解压即能跑的构建，缺 exe 说明选错了文件（比如传成了 APK）。
#
# 清单先读进变量再匹配，不要写成 unzip -l ... | grep -q ...：grep -q 一匹配上就退出并
# 关掉管道，unzip 吃到 SIGPIPE 返回 141，pipefail 于是把整条管道判成失败——匹配明明
# 成功了却报「没有 exe」。实测这个竞态大约一半概率触发，v1.1.2 发布时侥幸赢了，
# v1.1.3 就卡住了。顺带把「压缩包读不了」和「包里没有 exe」分成两个错误。
WIN_LIST="$(unzip -l "$WIN_SRC")" || die "读不了 $WIN_SRC，压缩包可能损坏或不是 zip"
grep -q "Anoawa.exe" <<<"$WIN_LIST" || die "$WIN_SRC 里没有 Anoawa.exe，确认是不是 Windows 构建"

gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1 && die "$TAG 已存在。要重发先 gh release delete $TAG --repo $REPO"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
cp "$APK_SRC" "$STAGE/$APK_NAME"
cp "$WIN_SRC" "$STAGE/$WIN_NAME"

sha_of() { shasum -a 256 "$1" | cut -d' ' -f1; }
size_of() { ls -lh "$1" | awk '{print $5}'; }

APK_SHA="$(sha_of "$STAGE/$APK_NAME")"
WIN_SHA="$(sha_of "$STAGE/$WIN_NAME")"

NOTES="$(cat <<NOTE
## 下载

| 平台 | 文件 | 大小 |
|---|---|---|
| Android | \`$APK_NAME\` | $(size_of "$STAGE/$APK_NAME") |
| Windows x64 | \`$WIN_NAME\` | $(size_of "$STAGE/$WIN_NAME") |

iOS 走 [TestFlight](https://testflight.apple.com/join/XMcFWlQA)，不在这里分发。

Android 侧载时系统会提示来源未知，允许即可。Windows 要解压整个压缩包再运行
\`Anoawa.exe\`，它依赖同级的 \`Anoawa_Data/\`。

## SHA-256

\`\`\`
$APK_SHA  $APK_NAME
$WIN_SHA  $WIN_NAME
\`\`\`
NOTE
)"

echo "发布 $TAG 到 $REPO"
echo "  $APK_NAME  $(size_of "$STAGE/$APK_NAME")  $APK_SHA"
echo "  $WIN_NAME  $(size_of "$STAGE/$WIN_NAME")  $WIN_SHA"

ARGS=(release create "$TAG" "$STAGE/$APK_NAME" "$STAGE/$WIN_NAME"
      --repo "$REPO" --title "Anoawa $TAG" --notes "$NOTES")
[ "$DRAFT" = "--draft" ] && ARGS+=(--draft)

gh "${ARGS[@]}"
