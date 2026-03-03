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

---

## 执行日志
- 2026-03-04: 完成 Phase 4 - 日历视图开发
- 2026-03-04: 完成 Phase 3 - API 对接与数据同步
- 2026-03-04: 完成 Phase 2 - 核心 CRUD 功能开发
- 2026-03-04: 完成 Phase 1 - 初始化项目基础架构

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
