#!/bin/bash
# macOS 构建脚本：使用 DevEco Studio 自带的 node 与 hvigor
# 用法：
#   ./build-mac.sh                 # 等价于 assembleHap -p buildMode=debug
#   ./build-mac.sh clean           # 清理
#   ./build-mac.sh assembleHap -p buildMode=release
set -e

DEVECO_HOME="/Applications/DevEco-Studio.app/Contents"
export DEVECO_SDK_HOME="$DEVECO_HOME/sdk"
export NODE_HOME="$DEVECO_HOME/tools/node"
export OHOS_SDK_HOME="$DEVECO_SDK_HOME"

cd "$(dirname "$0")"

if [ $# -eq 0 ]; then
  set -- assembleHap -p buildMode=debug
fi

"$NODE_HOME/bin/node" "$DEVECO_HOME/tools/hvigor/bin/hvigorw.js" "$@" --no-daemon
