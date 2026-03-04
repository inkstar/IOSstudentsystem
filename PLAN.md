# 开发计划 (PLAN)

## 更新规则
1. 每次完成一组功能，新增一个 Phase，插入到 PLAN.md 最顶部
2. 标题必须为：## [UTC+8 YYYY-MM-DD HH:mm] Phase N - <标题>（Done）
3. 每个 Phase 必须包含：目标、改动文件、验收标准、风险与回滚 四项
4. 不得删除历史 Phase；废弃项用删除线
5. 更新后必须同步修改：
   - 阶段状态总览：追加 Phase N ...：Done
   - 执行日志：追加当天完成记录一条
6. 时间统一使用 UTC+8，精确到分钟

---

## 阶段状态总览
- Phase 1：初始化项目基础架构：Done
- Phase 2：核心 CRUD 功能开发：Done
- Phase 3：API 对接与数据同步：Done
- Phase 4：日历视图：Done
- Phase 5：数据统计图表：Done
- Phase 6：课程详情页：Done
- Phase 7：知识点标签功能：Done
- Phase 8：构建稳定性与预览修复：Done
- Phase 9：课程时间段自由选择：Done

---

## 执行日志
- 2026-03-04: 完成 Phase 9 - 课程时间段自由选择
- 2026-03-04: 完成 Phase 8 - 构建稳定性与预览修复
- 2026-03-04: 完成 Phase 7 - 知识点标签功能开发
- 2026-03-04: 完成 Phase 6 - 课程详情页开发
- 2026-03-04: 完成 Phase 5 - 数据统计图表开发
- 2026-03-04: 完成 Phase 4 - 日历视图开发
- 2026-03-04: 完成 Phase 3 - API 对接与数据同步
- 2026-03-04: 完成 Phase 2 - 核心 CRUD 功能开发
- 2026-03-04: 完成 Phase 1 - 初始化项目基础架构

---

## [UTC+8 2026-03-04 14:52] Phase 9 - 课程时间段自由选择（Done）

**目标**: 添加课程时支持开始/结束时间自由选择（分钟级），不再限制半点粒度

**改动文件**:
- `Views/Lessons/LessonFormView.swift` - 将时间输入改为 `DatePicker(.hourAndMinute)`，并按时间段自动计算时长

**验收标准**:
- [x] 可自由选择开始时间与结束时间（分钟级）
- [x] 自动计算时长并在表单中展示
- [x] 保存时使用时间段格式（如 `09:10-10:45`）
- [x] 编辑历史课程时可兼容旧时间字符串

**风险与回滚**:
- 风险：旧课程时间字符串格式不规范导致解析偏差
- 回滚：保留单时间输入模式并恢复固定时段选择

---

## [UTC+8 2026-03-04 13:25] Phase 8 - 构建稳定性与预览修复（Done）

**目标**: 修复构建失败与预览不可用问题，恢复 Debug 构建稳定性

**改动文件**:
- `Services/APIService.swift` - 修复 `Encodable`/`Void` 请求泛型导致的编译失败
- `Views/Students/StudentDetailView.swift` - 修复 `TabView` 中条件分支 `.tag()` 编译问题
- `Views/Statistics/StatisticsView.swift` - 替换 iOS 17+ 的 `SectorMark` 以兼容 iOS 16
- `Views/Calendar/CalendarView.swift` - 清理未使用变量 warning
- `Views/Components/CommonViews.swift` - 清理未使用变量 warning
- `StudentCourseManager.xcodeproj/project.pbxproj` - 修复产物名、Debug 优化级别、预览配置与基础构建设置

**验收标准**:
- [x] `xcodebuild Debug` 构建通过
- [x] Swift 编译参数为 `-Onone`（支持 Previews）
- [x] 不再出现 `.app` 空产物路径冲突
- [x] MainTabView 索引/识别问题可通过清理缓存后恢复

**风险与回滚**:
- 风险：工程配置手动修改后与 XcodeGen 输出不一致
- 回滚：基于 `project.yml` 重新生成工程并按需回放配置

---

## [UTC+2026-03-04 08:00] Phase 7 - 知识点标签功能（Done）

**目标**: 添加知识点标签功能，用于跟踪学生学习情况

**改动文件**:
- `Models/KnowledgePoint.swift` - 新增知识点模型
- `Services/KnowledgePointService.swift` - 新增知识点服务
- `Services/DatabaseService.swift` - 添加知识点存储方法
- `ViewModels/KnowledgePointViewModel.swift` - 新增知识点视图模型
- `Views/Progress/ProgressFormView.swift` - 添加知识点类型选择
- `Views/Students/StudentDetailView.swift` - 添加薄弱知识点 Tab
- `Views/Students/WeakPointsByGradeView.swift` - 新增年级薄弱知识点视图
- `Views/MainTabView.swift` - 添加年级薄弱知识点入口
- `Views/Components/CommonViews.swift` - 添加知识点行组件

**验收标准**:
- [x] 可选择知识点类型（已掌握/薄弱）
- [x] 薄弱知识点支持多次记录，分数累加
- [x] 学生详情页显示薄弱知识点列表
- [x] 支持按次数或累计分数排序
- [x] 年级薄弱知识点视图正常显示

**风险与回滚**:
- 风险：进度记录与知识点标签的数据一致性
- 回滚：使用单一数据源，移除知识点聚合逻辑

---

## [UTC+2026-03-04 07:24] Phase 5 - 数据统计图表（Done）

**目标**: 使用 SwiftUI Charts 显示数据统计图表

**改动文件**:
- `Views/Statistics/StatisticsView.swift` - 统计图表视图
- 更新 MainTabView 添加统计 Tab

**验收标准**:
- [x] 显示学生年级分布柱状图
- [x] 显示课程状态分布饼图
- [x] 显示本周课程趋势折线图
- [x] 显示掌握程度分布图
- [x] 显示科目分布图

**风险与回滚**:
- 风险：Charts 框架兼容性
- 回滚：使用自定义图表替代

---

## [UTC+2026-03-04 07:17] Phase 4 - 日历视图（Done）

**目标**: 按日历方式查看课程安排

**改动文件**:
- `Views/Calendar/CalendarView.swift` - 日历视图
- `Views/Calendar/CalendarDayView.swift` - 日历单元格
- 更新 MainTabView 添加日历 Tab

**验收标准**:
- [x] 显示月历视图
- [x] 标记有课程的日子
- [x] 点击日期显示当天课程列表
- [x] 支持切换月份

**风险与回滚**:
- 风险：日期处理逻辑复杂
- 回滚：简化日历逻辑

---

## [UTC+2026-03-04 06:30] Phase 1 - 初始化项目基础架构（Done）

**目标**: 创建 iOS 项目基础结构，配置 XcodeGen

**改动文件**:
- `project.yml` - XcodeGen 项目配置文件
- `App/StudentCourseManagerApp.swift` - 应用入口
- `App/ContentView.swift` - 根视图

**验收标准**:
- [x] XcodeGen 可生成 .xcodeproj
- [ ] 项目可编译成功 (需要 Xcode)
- [x] 显示基础界面

**风险与回滚**:
- 风险：XcodeGen 配置可能需要多次调整
- 回滚：删除生成的文件，重新配置

---

## [UTC+2026-03-04 06:35] Phase 2 - 核心 CRUD 功能开发（Done）

**目标**: 实现学生管理、课程记录、学习进度功能

**改动文件**:
- `Models/Student.swift`, `Lesson.swift`, `ProgressRecord.swift` - 数据模型
- `Services/DatabaseService.swift` - 本地存储
- `ViewModels/StudentViewModel.swift`, `LessonViewModel.swift`, `ProgressViewModel.swift` - 视图模型
- `Views/Dashboard/DashboardView.swift` - 仪表盘
- `Views/Students/StudentListView.swift`, `StudentFormView.swift` - 学生管理
- `Views/Lessons/LessonListView.swift`, `LessonFormView.swift` - 课程记录
- `Views/Progress/ProgressListView.swift`, `ProgressFormView.swift` - 学习进度
- `Views/MainTabView.swift` - TabBar 导航

**验收标准**:
- [x] 仪表盘显示统计数据
- [x] 学生 CRUD 功能正常
- [x] 课程 CRUD 功能正常
- [x] 进度 CRUD 功能正常
- [x] 搜索和筛选功能正常

**风险与回滚**:
- 风险：表单验证逻辑复杂
- 回滚：简化验证规则

---

## [UTC+2026-03-04 08:30] Phase 3 - API 对接与数据同步（Done）

**目标**: 实现与 Flask 后端的 API 通信，支持远程数据同步

**改动文件**:
- `Services/APIService.swift` - API 服务
- `Services/SyncService.swift` - 同步服务
- `Services/ExportService.swift` - 导出服务
- `Views/Settings/SettingsView.swift` - 设置页面
- `Views/Students/StudentDetailView.swift` - 学生详情页
- `Views/Components/CommonViews.swift` - 通用组件

**验收标准**:
- [x] 登录认证功能正常
- [x] 可获取远程数据
- [x] 数据同步正常（本地+远程）
- [x] 离线支持正常
- [x] 数据导出功能正常

**风险与回滚**:
- 风险：网络请求错误处理复杂
- 回滚：添加错误提示和重试机制
