@echo off
setlocal

set "DEVECO_HOME=D:\oppp\DevEco Studio"
set "PROJECT_DIR=%~dp0"
set "NODE_EXE=%DEVECO_HOME%\tools\node\node.exe"
set "HVIGOR_JS=%DEVECO_HOME%\tools\hvigor\hvigor\bin\hvigor.js"

set "DEVECO_SDK_HOME=%DEVECO_HOME%\sdk"
set "OHOS_SDK_HOME=%DEVECO_HOME%\sdk"
set "PATH=%DEVECO_HOME%\tools\node;%PATH%"

cd /d "%PROJECT_DIR%"
"%NODE_EXE%" "%HVIGOR_JS%" assembleHap -p buildMode=debug --no-daemon
