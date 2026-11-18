#!/bin/bash
export DEVECO_SDK_HOME="D:/oppp/DevEco Studio/sdk"
export NODE_HOME="D:/oppp/DevEco Studio/tools/node"
export OHOS_SDK_HOME="D:/oppp/DevEco Studio/sdk"
cd "D:/oppp/1"
"D:/oppp/DevEco Studio/tools/node/node.exe" \
  "D:/oppp/DevEco Studio/tools/hvigor/bin/hvigorw.js" \
  assembleHap -p buildMode=debug 2>&1
echo "EXIT: $?"