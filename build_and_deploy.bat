@echo off
setlocal

set "DEVECO_HOME=D:\oppp\DevEco Studio"
set "PROJECT_DIR=%~dp0"
set "NODE_EXE=%DEVECO_HOME%\tools\node\node.exe"
set "HVIGOR_JS=%DEVECO_HOME%\tools\hvigor\hvigor\bin\hvigor.js"
set "HDC=%DEVECO_HOME%\sdk\default\openharmony\toolchains\hdc.exe"
set "HAP_PATH=%PROJECT_DIR%entry\build\default\outputs\default\entry-default-signed.hap"

set "DEVECO_SDK_HOME=%DEVECO_HOME%\sdk"
set "OHOS_SDK_HOME=%DEVECO_HOME%\sdk"
set "PATH=%DEVECO_HOME%\tools\node;%PATH%"

cd /d "%PROJECT_DIR%"
"%NODE_EXE%" "%HVIGOR_JS%" assembleHap -p buildMode=debug --no-daemon
if errorlevel 1 exit /b 1

"%HDC%" app install -r "%HAP_PATH%"
if errorlevel 1 exit /b 1

"%HDC%" shell aa force-stop jiuqushiyi.1.ysd
"%HDC%" shell aa start -a EntryAbility -b jiuqushiyi.1.ysd
