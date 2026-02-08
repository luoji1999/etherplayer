# Git 版本管理指南（ETPlayer 项目）

本文档面向项目开发者与自动化助手，介绍如何使用 Git 进行版本管理，替代"复制整个文件夹"的笨重做法。

---

## 为什么用 Git？

| 以前的做法 | 用 Git 之后 |
|---|---|
| 改代码前复制整个项目到另一个文件夹 | `git commit` 保存快照，随时可回退 |
| 改坏了要手动把文件夹内容复制回来 | `git checkout` / `git revert` 一条命令恢复 |
| 不知道改了哪些文件 | `git diff` / `git status` 精确显示差异 |
| 多个版本占用大量磁盘空间 | Git 只存增量，几乎不占额外空间 |

---

## 日常工作流（最常用的命令）

### 1. 查看当前状态
```bash
git status
```
显示哪些文件被修改、新增、删除。

### 2. 查看具体改了什么
```bash
# 查看所有未暂存的修改
git diff

# 查看某个文件的修改
git diff source/Playnite/SomeFile.cs
```

### 3. 开始一次新的改动（推荐用分支）
```bash
# 创建并切换到新分支（比如要做"添加XX功能"）
git checkout -b feature/添加XX功能

# 现在可以放心改代码了，不会影响 master 分支
```

### 4. 保存改动（提交）
```bash
# 添加所有修改的文件到暂存区
git add -A

# 提交，写清楚这次改了什么
git commit -m "添加XX功能：修改了YY文件，实现了ZZ效果"
```

### 5. 改完没问题，合并回主分支
```bash
# 切回主分支
git checkout master

# 把功能分支合并进来
git merge feature/添加XX功能

# 合并成功后可以删除功能分支
git branch -d feature/添加XX功能
```

### 6. 改坏了，想回退
```bash
# 情况A：还没提交，想撤销某个文件的修改
git checkout -- source/Playnite/SomeFile.cs

# 情况B：还没提交，想撤销所有修改
git checkout -- .

# 情况C：已经提交了，想回到上一个提交
git revert HEAD

# 情况D：想彻底回到某个历史版本（谨慎使用！会丢失之后的提交）
git log --oneline          # 先查看提交历史，找到目标提交的哈希值
git reset --hard <提交哈希>  # 回退到那个版本
```

---

## 分支策略（推荐）

```
master          ← 稳定版本，随时可构建
  │
  ├── feature/XX功能   ← 开发新功能
  ├── fix/修复YY问题    ← 修复 bug
  └── experiment/尝试ZZ ← 实验性改动（不确定要不要保留）
```

**核心原则：**
- `master` 分支始终保持可构建、可运行的状态
- 每次改动都在新分支上进行
- 改完测试没问题再合并回 `master`
- 实验性改动如果不要了，直接删除分支即可

---

## 常用场景速查

### 场景 1：我要改一堆代码，但不确定能不能成功
```bash
git checkout -b experiment/尝试新方案
# ... 改代码 ...
git add -A && git commit -m "尝试新方案"
# 构建测试...

# 如果成功：
git checkout master && git merge experiment/尝试新方案

# 如果失败，想放弃：
git checkout master
git branch -D experiment/尝试新方案   # -D 强制删除
```

### 场景 2：改到一半想看看之前的版本是什么样
```bash
# 查看某个文件之前的内容
git show HEAD:source/Playnite/SomeFile.cs

# 查看提交历史
git log --oneline -20
```

### 场景 3：改了很多文件，只想提交其中一部分
```bash
git add source/Playnite/FileA.cs
git add source/Playnite/FileB.cs
git commit -m "只提交这两个文件的修改"
```

### 场景 4：想对比两个版本之间的差异
```bash
# 对比当前和上一次提交
git diff HEAD~1

# 对比两个分支
git diff master..feature/XX功能

# 只看改了哪些文件（不看具体内容）
git diff --name-only HEAD~1
```

---

## 与 Roo（AI 助手）协作时的建议

每次让 Roo 做较大改动前：

1. **先提交当前状态**：`git add -A && git commit -m "改动前的状态"`
2. **创建新分支**：`git checkout -b feature/本次改动描述`
3. **让 Roo 开始改代码**
4. **改完后提交**：`git add -A && git commit -m "Roo: 本次改动描述"`
5. **构建测试**，没问题就合并回 `master`

这样即使 Roo 改坏了，一条 `git checkout master` 就能回到安全状态。

---

## 查看提交历史

```bash
# 简洁的提交历史
git log --oneline

# 带日期的提交历史
git log --format="%h %ai %s"

# 图形化查看分支历史
git log --oneline --graph --all
```

---

## 注意事项

1. **不要提交构建产物**：项目已有 `.gitignore` 文件，会自动忽略 `bin/`、`obj/`、`Debug/`、`Release/` 等目录
2. **提交信息写清楚**：方便以后回溯，建议格式：`类型: 简要描述`，例如：
   - `feat: 添加游戏分类功能`
   - `fix: 修复启动崩溃问题`
   - `refactor: 重构数据库查询逻辑`
   - `ui: 调整主界面布局`
3. **经常提交**：小步提交比一次性大提交更安全，出问题时更容易定位
4. **构建前先清理**：运行 `clean.bat` 清理构建产物后再提交，避免提交不必要的文件
