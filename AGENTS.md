# AGENTS.md（ETPlayer 二次开发协作指南）

本文件面向“自动化编码助手/代理（agent）”与贡献者，目的是让后续修改遵循本仓库的结构、构建方式与代码风格，减少无效返工。

## 项目概览
- Playnite 是基于 **Windows** 的游戏库管理与启动器（桌面模式/全屏模式），主要为 **WPF + .NET Framework** 工程。
- 解决方案入口：`source/ETPlayer.sln`
- README 中的风格规则为准：`README.md`

## 沟通交流
- 请优先使用简体中文对话

## 目录结构（常用）
- `source/`：主要 C# 源码与解决方案
  - `source/Playnite/`：核心库（业务逻辑、数据层、通用组件等）
  - `source/Playnite.DesktopApp/`：桌面模式（WPF）
  - `source/Playnite.FullscreenApp/`：全屏模式（WPF）
  - `source/PlayniteSDK/`：对外 SDK（插件/主题开发相关）
  - `source/Tools/`：工具与安装器相关项目
  - `source/Tests/`：C# 单元测试项目（NUnit 等）
- `build/`：PowerShell 构建脚本（打包、校验本地化文件、SDK nuget 等）
- `tests/`：PowerShell/Pester 的自动化测试脚本与测试资产
- `media/`：截图、图标等媒体资源
- `references/`：外部参考/依赖相关文件（按需使用）

## 开发与构建（Windows 优先）
### 前置要求（建议）
- Windows 10/11（WPF/.NET Framework 工程不支持在 macOS/Linux 原生构建）
- Visual Studio 2019/2022（包含 “.NET desktop development” 工作负载）
- 安装 **.NET Framework 4.6.2 Targeting Pack**（项目目标框架为 `v4.6.2`）
- PowerShell 7（构建脚本在 `build/` 下，脚本头部声明 `#Requires -Version 7`）

### 使用 Visual Studio
- 打开 `source/ETPlayer.sln`
- 常见启动项目：
  - `Playnite.DesktopApp`（桌面模式）
  - `Playnite.FullscreenApp`（全屏模式）
- 若遇到平台/位数问题，优先使用解决方案里已有的 `x86/x64` 配置，避免新建不一致配置。

### 使用脚本构建（CI/打包路径）
构建脚本位于 `build/build.ps1`，默认会执行一些非代码校验（如本地化与 YAML 定义检查）。

示例（PowerShell 7）：
- `pwsh -File build/build.ps1 -Configuration Release -Platform x86`
- 打包 zip：`pwsh -File build/build.ps1 -Package`

说明：
- 默认输出目录为 `build/<Configuration>/`（例如 `build/Release/`）
- 脚本会执行 `nuget restore` 并通过 `vswhere` 寻找 MSBuild

## 测试
本仓库存在两类测试：
- C# 单元测试：在 `source/Tests/` 下（通过 VS Test Explorer 运行最方便）
- PowerShell/Pester 自动化测试：`tests/RunTests.ps1`

运行 Pester（示例）：
- `pwsh -File tests/RunTests.ps1`
- 只跑单个测试名：`pwsh -File tests/RunTests.ps1 -TestName "Initial Startup"`

新增/修改功能时：
- 优先补充 **C# 单元测试**（可维护、运行更快）
- UI/端到端行为再考虑 `tests/` 下的 Pester 测试（通常更依赖环境）

## 代码风格与约定（必须遵守）
以 `README.md` 的规则为准，核心点如下：
- 私有字段/属性使用 `camelCase`（**不要**以下划线开头）
- 方法（private/public）使用 `PascalCase`
- 使用空格缩进（4 spaces），不要用 tab
- `if/for/foreach/while` 等必须使用花括号包裹代码块
- `}` 结束一个代码块后，与后续表达式之间保持空行（遵循现有文件的风格）

额外建议：
- 尽量保持修改“最小且聚焦”：不要做大规模无关重构/格式化
- 修改公共 API（尤其 SDK）时，考虑向后兼容与插件生态影响

## 本地化与资源
- 英文原始字符串主要在：`source/Playnite/Localization/LocSource.xaml`
- 构建脚本会运行语言文件校验：`build/VerifyLanguageFiles.ps1`

对 agent 的要求：
- 新增 UI 文案时，优先走本地化资源，不要硬编码字符串
- 若修改了本地化/平台/模拟器 YAML 定义，确保构建脚本校验能通过

## 变更策略（给自动化助手的“工作方式”）
- 优先复用现有模式与工具：先搜索现有实现（`rg`），再新增代码
- 变更需包含：
  - 必要的代码修改（尽量局部）
  - 对应的测试或至少可复现/可验证的步骤说明
  - 如涉及用户可见行为，更新相关文档/注释（仅在仓库已有文档体系内）
- 避免：
  - 引入新的构建系统或大范围升级依赖（除非明确要求）
  - 破坏性改动（数据库/设置格式变更等）不提供迁移方案
  - 一次性改动大量文件但缺少理由（会降低 review 与回归效率）

## 常见二次开发切入点（建议）
- 增加库/平台集成：通常在 `source/Playnite/` 下的库导入、元数据、脚本集成相关模块
- 调整 UI/交互：在 `source/Playnite.DesktopApp/` 与 `source/Playnite.FullscreenApp/` 的 XAML/视图模型中进行
- 对外扩展能力：优先通过 `source/PlayniteSDK/` 暴露能力，避免直接耦合内部实现

## UI 二开指南（桌面/全屏）
UI 相关代码主要在以下位置：
- 桌面模式：`source/Playnite.DesktopApp/`
  - 资源入口：`source/Playnite.DesktopApp/GlobalResources.xaml`
  - 默认主题：`source/Playnite.DesktopApp/Themes/Desktop/Default/`
  - 控件：`source/Playnite.DesktopApp/Controls/`
  - 窗口：`source/Playnite.DesktopApp/Windows/`
  - 视图模型：`source/Playnite.DesktopApp/ViewModels/`
- 全屏模式：`source/Playnite.FullscreenApp/`
  - 资源入口：`source/Playnite.FullscreenApp/GlobalResources.xaml`
  - 默认主题：`source/Playnite.FullscreenApp/Themes/Fullscreen/Default/`

对 agent 的建议（UI 变更时）：
- 优先改 **资源字典/样式**（Theme/GlobalResources），再考虑改控件模板与布局，最后才是改业务逻辑
- 保持 MVVM 风格：尽量把行为放在 `ViewModels/`，避免把复杂逻辑写进 XAML code-behind
- 避免“一次性全局替换样式/颜色”：会制造大量 diff 且难以回归；更推荐新增可复用的资源 key 并逐步迁移
- UI 变更要同时在桌面与全屏下过一遍关键页面（尤其是列表/详情/对话框），避免只修一种模式

## 主题（Theme）与皮肤改造
Playnite 的主题通过 `theme.yaml` 标识：
- 桌面默认主题 manifest：`source/Playnite.DesktopApp/Themes/Desktop/Default/theme.yaml`
- 全屏默认主题 manifest：`source/Playnite.FullscreenApp/Themes/Fullscreen/Default/theme.yaml`

二开策略（按推荐顺序）：
- **Fork 内置默认主题**：直接改 `source/**/Themes/**/Default/` 下的 XAML/资源，适合“改 UI 风格 + 伴随功能改动”的深度定制
- **做可分发主题**：使用 Toolbox 的主题模板（见下方），打包成 `.pthm` 并通过 Add-ons 安装，适合“可选皮肤/多主题共存”

主题模板位置：
- `source/Tools/Playnite.Toolbox/Templates/Themes/Desktop/`
- `source/Tools/Playnite.Toolbox/Templates/Themes/Fullscreen/`

## 自定义插件（Add-on）开发
插件/扩展以 `extension.yaml` 作为 manifest（文件名固定）：
- manifest 文件名常量：`source/Playnite/Settings/PlaynitePaths.cs`
- 扩展模板：`source/Tools/Playnite.Toolbox/Templates/Extensions/`
  - `GenericPlugin`：通用插件（最适合做“增减功能/加 UI 菜单/侧边栏项/设置页”等）
  - `CustomLibraryPlugin`：游戏库导入类插件
  - `CustomMetadataPlugin`：元数据抓取类插件
  - `PowerShellScript`：脚本扩展

插件 UI 的常见挂载点（建议从 SDK 入口类开始查）：
- 菜单项：`source/PlayniteSDK/Plugins/MenuEntry.cs`
- 侧边栏：`source/PlayniteSDK/Plugins/SidebarItem.cs`
- 顶部面板：`source/PlayniteSDK/Plugins/TopPanelItem.cs`
- 游戏动作（运行/安装/卸载等）：`source/PlayniteSDK/Plugins/Actions.cs`
- 设置页与数据存取：`source/PlayniteSDK/Plugins/Plugin.cs`（`GetSettingsView` / `LoadPluginSettings` / `SavePluginSettings`）

`extension.yaml` 的 `Type` 常见取值（示例见模板）：
- `GenericPlugin` / `GameLibrary` / `MetadataProvider` / `Script`

对 agent 的要求（插件实现）：
- 以 SDK 为边界：优先只引用/使用 `source/PlayniteSDK/` 提供的 API，避免直接依赖 `source/Playnite/` 内部类型（降低升级/重构风险）
- 扩展数据写入扩展数据目录（避免写到安装目录）：可用 `IPlayniteAPI.Paths.ExtensionsDataPath`（路径定义可参考 `source/Playnite/Settings/PlaynitePaths.cs`）
- `extension.yaml` 的 `Id`（通常包含 GUID）一旦发布就保持稳定，否则用户会丢失插件设置/数据

## 使用 Toolbox 生成/打包插件与主题（推荐工作流）
仓库内提供了 `Toolbox`（命令行工具）来生成模板与打包发布物：
- 工程：`source/Tools/Playnite.Toolbox/Playnite.Toolbox.csproj`（输出为 `Toolbox.exe`）
- 支持命令：`new` / `pack` / `update` / `verify`（参数定义见 `source/Tools/Playnite.Toolbox/CmdLineOptions.cs`）

示例（先自行编译出 `Toolbox.exe` 后运行）：
- 生成通用插件模板：`Toolbox.exe new GenericPlugin MyPlugin <输出目录>`
- 生成桌面主题模板：`Toolbox.exe new DesktopTheme MyTheme`
- 打包插件/主题：`Toolbox.exe pack <插件或主题目录> <输出目录>`

## “增减功能”时的边界与兼容性
- 涉及 `config.json`/数据库结构等持久化变更时，必须提供迁移/兼容路径（避免用户升级后无法启动或数据丢失）
- 对外行为变化（菜单、快捷键、默认值、导入规则）尽量可配置，避免硬编码成“唯一正确”
- 优先把“可选功能”做成：
  - 核心功能开关（写入设置），或
  - 可独立安装/卸载的 `GenericPlugin`（更易迭代与回滚）

## 本地安装与调试路径（Windows）
Playnite 支持安装版与便携版（portable），路径会不同；代码可参考 `source/Playnite/Settings/PlaynitePaths.cs`。

常见默认位置（非便携版）：
- 用户数据根目录：`%AppData%\\Playnite\\`
- 扩展（安装/调试）：`%AppData%\\Playnite\\Extensions\\`
- 扩展数据（插件存储）：`%AppData%\\Playnite\\ExtensionsData\\`
- 主题（安装/调试）：`%AppData%\\Playnite\\Themes\\`

便携版（portable）通常会把上述目录放在安装目录下（与 `ETPlayer.DesktopApp.exe` 同级）。

## 版本迭代记录
-每次迭代完成后再historyplan.md文档中记录迭代的内容
