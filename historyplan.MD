# 迭代记录

## 2026-01-24

- 取消首次配置向导界面，应用首次启动时直接进入主界面。
- 桌面模式：启动流程不再打开 `FirstTimeStartupWindow`；仍保留数据库路径初始化与自动备份默认值初始化。
- 全屏模式：取消首次启动时强制重启到桌面模式；改为初始化数据库路径与自动备份默认值，并标记首次配置已完成。
- 行为变化：首次启动不再自动下载/安装推荐扩展（如需导入平台库，请手动安装对应扩展）。

## 2026-01-25

- 品牌重命名（用户可见）：英文显示改为 “ETPlayer”，简体中文显示改为“以太玩家”。
- 本地化精简：仅保留英文源与 `zh_CN` 本地化文件，更新 `locstatus.json`。
- 默认数据目录变更并自动迁移：`%AppData%\\Playnite` → `%AppData%\\ETPlayer`，失败时回退使用旧目录。
- 程序与组件输出重命名：核心/桌面/全屏/SDK 组件的 AssemblyName 与可执行文件名改为 ETPlayer 前缀。
- 构建与模板同步：SDK NuGet 规范文件改为 `ETPlayerSDK.nuspec`，模板引用与包名更新为 `ETPlayerSDK`。
- 运行时与日志文案更新：启动/关停/崩溃/Discord/备份等文本从 Playnite 改为 ETPlayer。
- 备份命名与默认库路径更新：自动备份改为 `ETPlayerBackup`，默认库路径改为 `%AppData%\\ETPlayer\\library`。
- 解决方案改名：`Playnite.sln` → `ETPlayer.sln`，并更新构建脚本引用。
- 修复测试插件 XAML 仍引用旧 SDK 程序集名称导致的构建失败（`Playnite.SDK` → `ETPlayer.SDK`）。
- 修复 `DatabaseFieldsManagerWindow.xaml` 文件内容为空导致的构建失败（MC3000: 缺少根元素），重新创建完整的数据库字段管理窗口 XAML 界面。
- 修改构建脚本默认平台从 x86 改为 x64（`build.bat` 和 `build/build.ps1`）。
- 修复 NuGet 包缺失导致的构建失败：在 `source/Playnite/packages.config` 中添加 `Magick.NET-Q8-x64` 包引用（项目文件引用了 x64 版本但 packages.config 中只有 x86 版本）。
- 新增 `clean.bat` 清理脚本，用于清理构建产物（build/Debug、build/Release、source/packages、obj、bin 目录），避免项目体积膨胀。

## 2026-02-08

- 引入 Git 版本管理：初始化 Git 仓库，提交当前项目基线状态（1363 个文件）。
- 新增 `GIT_GUIDE.md` 版本管理指南文档，涵盖日常工作流、分支策略、回退方法、与 AI 助手协作建议等。
- 解决了之前"复制整个项目文件夹"做版本管理的痛点，改用 Git 分支 + 提交的标准工作流。
- 去除桌面模式和全屏模式下「在 Patreon 上支持我们」和「在 Ko-fi 上支持我们」两个菜单项及相关功能：
  - 桌面模式：移除 `MainMenu.cs` 中 Patreon/Ko-fi 菜单项的添加代码。
  - 全屏模式：移除 `MainMenuViewModel.cs` 中 `OpenPatreonCommand`/`OpenKofiCommand` 命令及 `OpenPatreon()`/`OpenKofi()` 方法；移除 `MainMenuWindow.xaml` 中对应的两个按钮；移除 `MainMenu.xaml` 主题模板中 `MainMenuPatreonButtonTemplate`/`MainMenuKofiButtonTemplate` 数据模板。
- 将全屏模式主菜单中的【最小化】【帮助】【退出以太玩家】【切换至桌面模式】四个控制按钮迁移至全屏模式的【设置】页面中：
  - `MainMenuWindow.xaml`：移除 `PART_ButtonExitPlaynite`、`PART_ButtonSwitchToDesktop`、`PART_ButtonFeedback`（帮助）、`PART_ButtonMinimize` 四个按钮。
  - `SettingsViewModel.cs`：新增 `MinimizeCommand`、`OpenHelpCommand`、`ExitCommand`、`SwitchToDesktopCommand` 四个命令，保存 `mainModel` 引用以调用对应功能。
  - `SettingsWindow.xaml`：在设置菜单按钮列表底部添加四个新按钮，分别绑定上述命令。
  - `SettingsMenus.xaml`：新增 `SettingsMenuMinimizeButtonTemplate`、`SettingsMenuHelpButtonTemplate`、`SettingsMenuExitButtonTemplate`、`SettingsMenuSwitchDesktopButtonTemplate` 四个 DataTemplate。

## 2026-02-09

- 修复一键构建脚本默认平台不一致问题：`build.bat` 的默认 `PLATFORM` 从 `x64` 改为 `x86`，与脚本说明和当前可用构建路径保持一致。
- 修复 x86 构建失败（CS8012）问题：`source/Playnite/Playnite.csproj` 中 `Magick.NET` 引用由固定 `x64` 改为按 `PlatformTarget` 条件选择 `x86/x64`，并同步调整 NuGet targets 的校验与导入条件。

