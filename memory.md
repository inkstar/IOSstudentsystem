# memory.md

用于记录本项目中需要长期记住的约定与事实，避免后续反复踩坑。

## 项目入口与构建
- 工程入口固定为 `StudentCourseManager.xcodeproj`。
- 不再使用重复工程（`StudentCourseManager 2.xcodeproj` 已移除）。
- 本地命令行构建推荐：
  - `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project "StudentCourseManager.xcodeproj" -scheme "StudentCourseManager" -configuration Debug -destination 'generic/platform=iOS' build`
- Previews 必须使用 Debug 且 `-Onone`。

## Xcode 预览/索引常见故障处理
- 若出现 `cannot find MainTabView` 或预览异常：
  1. 关闭 Xcode
  2. 清理缓存：`rm -rf ~/Library/Developer/Xcode/DerivedData/StudentCourseManager-*`
  3. 重开 `StudentCourseManager.xcodeproj`
  4. `Product -> Clean Build Folder`
- `MainTabView` 定义在 `Views/MainTabView.swift`，`ContentView` 直接引用它。

## 课程时间字段约定
- 新增/编辑课程时使用“开始时间 + 结束时间”时间段输入（分钟级自由选择）。
- `Lesson.lessonTime` 持久化格式：`HH:mm-HH:mm`（例如 `09:10-10:45`）。
- `duration` 由时间段自动计算（分钟）。
- 兼容历史数据：旧的单时间字符串会在编辑时自动解析并补全结束时间。

## 计划文档维护约定（PLAN.md）
- 每完成一组功能，新增一个 Phase，插入到顶部。
- 标题格式：`## [UTC+8 YYYY-MM-DD HH:mm] Phase N - <标题>（Done）`
- 每个 Phase 必须包含：目标、改动文件、验收标准、风险与回滚。
- 不删除历史 Phase。
- 同步更新：
  - 阶段状态总览
  - 执行日志

## 已确认的关键修复（不可回退）
- APIService 已拆分请求泛型与 `requestVoid`，避免 `Encodable`/`Void` 编译问题。
- StudentDetailView 的 Tab 分支使用 `Group { ... }.tag(...)`，避免条件视图链式 `.tag` 编译报错。
- StatisticsView 不使用 iOS 17 才有的 `SectorMark`，保持 iOS 16 兼容。
- 工程配置中 Debug 明确 `SWIFT_OPTIMIZATION_LEVEL = -Onone`，Release 为 `-O`。

## 提交范围偏好
- 默认不要把 `project.yml` 和 `00/` 目录一起提交，除非明确要求。
- 提交前先确认 `git status`，只 add 目标文件。

---
最后更新：2026-03-04（UTC+8）
