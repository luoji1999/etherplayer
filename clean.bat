@echo off
chcp 65001 >nul
echo ============================================
echo   ETPlayer 清理脚本
echo ============================================
echo.

echo [清理] 正在删除构建输出目录...
if exist "build\Debug" (
    rmdir /s /q "build\Debug"
    echo   - 已删除 build\Debug
)
if exist "build\Release" (
    rmdir /s /q "build\Release"
    echo   - 已删除 build\Release
)

echo.
echo [清理] 正在删除 NuGet 包目录...
if exist "source\packages" (
    rmdir /s /q "source\packages"
    echo   - 已删除 source\packages
)

echo.
echo [清理] 正在删除 obj 和 bin 目录...
for /d /r "source" %%d in (obj) do (
    if exist "%%d" (
        rmdir /s /q "%%d"
        echo   - 已删除 %%d
    )
)
for /d /r "source" %%d in (bin) do (
    if exist "%%d" (
        rmdir /s /q "%%d"
        echo   - 已删除 %%d
    )
)

echo.
echo ============================================
echo   清理完成
echo ============================================
echo.
pause
