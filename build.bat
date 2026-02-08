@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 始终在结束时暂停，方便查看输出
set "PAUSE_ON_EXIT=1"

:: ============================================
:: ETPlayer 一键构建脚本
:: ============================================
:: 用法: build.bat [选项]
::   无参数        - 默认 Release x86 构建
::   debug         - Debug 模式构建
::   release       - Release 模式构建
::   x64           - 64位构建
::   x86           - 32位构建 (默认)
::   package       - 构建并打包为 zip
::   clean         - 清理构建输出
::   help          - 显示帮助信息
:: 
:: 示例:
::   build.bat                    - Release x86 构建
::   build.bat debug              - Debug x86 构建
::   build.bat release x64        - Release x64 构建
::   build.bat package            - Release x86 构建并打包
::   build.bat debug x64 package  - Debug x64 构建并打包
:: ============================================

set "SCRIPT_DIR=%~dp0"
set "BUILD_DIR=%SCRIPT_DIR%build"
set "SOURCE_DIR=%SCRIPT_DIR%source"

:: 默认配置
set "CONFIG=Release"
set "PLATFORM=x64"
set "DO_PACKAGE="
set "DO_CLEAN="
set "PWSH_CMD="

:: 解析命令行参数
:parse_args
if "%~1"=="" goto :check_prereq
if /i "%~1"=="debug" set "CONFIG=Debug" & shift & goto :parse_args
if /i "%~1"=="release" set "CONFIG=Release" & shift & goto :parse_args
if /i "%~1"=="x64" set "PLATFORM=x64" & shift & goto :parse_args
if /i "%~1"=="x86" set "PLATFORM=x86" & shift & goto :parse_args
if /i "%~1"=="package" set "DO_PACKAGE=-Package" & shift & goto :parse_args
if /i "%~1"=="clean" set "DO_CLEAN=1" & shift & goto :parse_args
if /i "%~1"=="help" goto :show_help
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="/?" goto :show_help
echo [警告] 未知参数: %~1
shift
goto :parse_args

:show_help
echo.
echo ============================================
echo   ETPlayer 一键构建脚本
echo ============================================
echo.
echo 用法: build.bat [选项]
echo.
echo 选项:
echo   debug         Debug 模式构建
echo   release       Release 模式构建 (默认)
echo   x64           64位构建
echo   x86           32位构建 (默认)
echo   package       构建并打包为 zip
echo   clean         清理构建输出
echo   help, -h, /?  显示此帮助信息
echo.
echo 示例:
echo   build.bat                    - Release x86 构建
echo   build.bat debug              - Debug x86 构建
echo   build.bat release x64        - Release x64 构建
echo   build.bat package            - Release x86 构建并打包
echo   build.bat debug x64 package  - Debug x64 构建并打包
echo   build.bat clean              - 清理所有构建输出
echo.
echo 前置要求:
echo   - PowerShell 7 (pwsh)
echo   - Visual Studio 2019/2022 (含 .NET desktop development)
echo   - .NET Framework 4.6.2 Targeting Pack
echo.
if defined PAUSE_ON_EXIT (
    echo 按任意键退出...
    pause >nul
)
goto :eof

:check_prereq
echo.
echo ============================================
echo   ETPlayer 构建脚本
echo ============================================
echo.
echo [信息] 配置: %CONFIG%
echo [信息] 平台: %PLATFORM%
if defined DO_PACKAGE echo [信息] 打包: 是
echo.

:: 检查 PowerShell 7
echo [检查] 正在检查 PowerShell 7...
where pwsh >nul 2>&1
if errorlevel 1 goto :no_pwsh
set "PWSH_CMD=pwsh"
echo [成功] 找到 PowerShell 7 (pwsh)
goto :pwsh_found

:no_pwsh
echo [错误] 未找到 PowerShell 7 (pwsh)
echo [提示] 构建脚本需要 PowerShell 7 才能运行
echo [提示] 请从以下地址安装 PowerShell 7:
echo        https://github.com/PowerShell/PowerShell/releases
echo        或运行: winget install Microsoft.PowerShell
goto :error_exit

:pwsh_found

:: 检查构建目录
if not exist "%BUILD_DIR%" (
    echo [错误] 构建目录不存在: %BUILD_DIR%
    goto :error_exit
)

:: 清理操作
if defined DO_CLEAN (
    echo.
    echo [清理] 正在清理构建输出...
    if exist "%BUILD_DIR%\Release" (
        echo [清理] 删除 %BUILD_DIR%\Release
        rmdir /s /q "%BUILD_DIR%\Release" 2>nul
    )
    if exist "%BUILD_DIR%\Debug" (
        echo [清理] 删除 %BUILD_DIR%\Debug
        rmdir /s /q "%BUILD_DIR%\Debug" 2>nul
    )
    if exist "%BUILD_DIR%\ETPlayer.zip" (
        echo [清理] 删除 %BUILD_DIR%\ETPlayer.zip
        del /f /q "%BUILD_DIR%\ETPlayer.zip" 2>nul
    )
    echo [成功] 清理完成
    if "%CONFIG%"=="Release" if "%PLATFORM%"=="x86" if not defined DO_PACKAGE (
        goto :success_exit
    )
)

:: 执行构建
echo.
echo [构建] 开始构建 ETPlayer (%CONFIG% %PLATFORM%)...
echo [构建] 这可能需要几分钟时间，请耐心等待...
echo.

pushd "%BUILD_DIR%"
%PWSH_CMD% -ExecutionPolicy Bypass -File build.ps1 -Configuration %CONFIG% -Platform %PLATFORM% %DO_PACKAGE%
set "BUILD_RESULT=%errorlevel%"
popd

if %BUILD_RESULT% neq 0 (
    echo.
    echo [错误] 构建失败，错误代码: %BUILD_RESULT%
    goto :error_exit
)

echo.
echo ============================================
echo   构建成功完成!
echo ============================================
echo.
echo [输出] 构建输出目录: %BUILD_DIR%\%CONFIG%
if defined DO_PACKAGE (
    echo [输出] 打包文件: %BUILD_DIR%\ETPlayer.zip
)
echo.

:success_exit
if defined PAUSE_ON_EXIT (
    echo.
    echo 按任意键退出...
    pause >nul
)
endlocal
exit /b 0

:error_exit
echo.
echo [失败] 构建过程中发生错误
echo.
if defined PAUSE_ON_EXIT (
    echo 按任意键退出...
    pause >nul
)
endlocal
exit /b 1
