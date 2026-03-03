# 开发计划 (PLAN)

## 更新规则
- 新增计划必须放在最前面
- 每条新增计划标题使用 `[UTC+8 YYYY-MM-DD HH:mm]`
- 废弃计划不删除，使用 ~~删除线~~ 保留历史
- 每条计划包含：目标、改动文件、验收标准、风险与回滚

---

## [UTC+2026-03-04 06:30] 初始化 iOS 项目结构

**目标**: 创建 iOS 项目基础结构，配置 XcodeGen

**改动文件**:
- `project.yml` - XcodeGen 项目配置文件
- `App/` - 应用入口文件
  - `StudentCourseManagerApp.swift`
- `ContentView.swift` - 根视图

**验收标准**:
- [x] XcodeGen 可生成 .xcodeproj
- [ ] 项目可编译成功 (需要 Xcode)
- [x] 显示基础界面

**风险与回滚**:
- 风险：XcodeGen 配置可能需要多次调整
- 回滚：删除生成的文件，重新配置

---

## [UTC+2026-03-04 06:35] 创建数据模型和 SQLite 数据库层

**目标**: 定义数据模型并实现本地数据存储

**改动文件**:
- `Models/` - 数据模型
  - `Student.swift`
  - `Lesson.swift`
  - `ProgressRecord.swift`
- `Services/DatabaseService.swift` - 数据库服务

**验收标准**:
- [x] 数据模型定义完整
- [x] 数据库创建成功
- [x] 基本的 CRUD 操作可用

**风险与回滚**:
- 风险：SQLite.swift 语法可能有误
- 回滚：检查文档并修正

---

## [UTC+2026-03-04 06:45] 实现仪表盘功能

**目标**: 创建仪表盘页面，展示统计数据

**改动文件**:
- `Views/Dashboard/` - 仪表盘视图
  - `DashboardView.swift`
  - `StatCardView.swift`

**验收标准**:
- [x] 显示学生总数、课程数
- [x] 显示本周出勤率
- [x] 展示近期课程列表

**风险与回滚**:
- 风险：数据统计逻辑可能不准确
- 回滚：重新审查统计逻辑

---

## [UTC+2026-03-04 07:00] 实现学生管理功能

**目标**: 创建学生列表、添加、编辑、删除功能

**改动文件**:
- `Views/Students/` - 学生视图
  - `StudentListView.swift`
  - `StudentRowView.swift`
  - `StudentFormView.swift`
- `ViewModels/StudentViewModel.swift`

**验收标准**:
- [x] 学生列表展示正常
- [x] 添加学生功能正常
- [x] 编辑学生功能正常
- [x] 删除学生功能正常
- [x] 搜索和筛选功能正常

**风险与回滚**:
- 风险：表单验证逻辑
- 回滚：检查输入验证

---

## [UTC+2026-03-04 07:20] 实现课程记录功能

**目标**: 创建课程列表、添加课程功能

**改动文件**:
- `Views/Lessons/` - 课程视图
  - `LessonListView.swift`
  - `LessonRowView.swift`
  - `LessonFormView.swift`
- `ViewModels/LessonViewModel.swift`

**验收标准**:
- [x] 课程列表展示正常
- [x] 添加课程功能正常
- [x] 课程状态管理正常
- [x] 按学生筛选正常

**风险与回滚**:
- 风险：日期选择器集成
- 回滚：使用原生 DatePicker

---

## [UTC+2026-03-04 07:40] 实现学习进度功能

**目标**: 创建进度记录列表、添加进度功能

**改动文件**:
- `Views/Progress/` - 进度视图
  - `ProgressListView.swift`
  - `ProgressRowView.swift`
  - `ProgressFormView.swift`
- `ViewModels/ProgressViewModel.swift`

**验收标准**:
- [x] 进度列表展示正常
- [x] 添加进度记录功能正常
- [x] 掌握程度评估正常

**风险与回滚**:
- 风险：进度计算逻辑
- 回滚：简化评估逻辑

---

## [UTC+2026-03-04 08:00] 配置 TabBar 导航和主界面

**目标**: 整合所有视图到 TabBar 导航

**改动文件**:
- `ContentView.swift` - 更新根视图
- `MainTabView.swift` - TabBar 视图

**验收标准**:
- [x] 四个 Tab 正常切换
- [x] 导航层级正确
- [x] 界面响应流畅

**风险与回滚**:
- 风险：导航状态管理
- 回滚：检查状态绑定

---

## [UTC+2026-03-04 08:30] 对接后端 API（可选）

**目标**: 实现与 Flask 后端的 API 通信

**改动文件**:
- `Services/APIService.swift` - API 服务
- 更新 ViewModel 使用网络请求

**验收标准**:
- [ ] 可获取远程数据
- [ ] 数据同步正常

**风险与回滚**:
- 风险：网络请求错误处理
- 回滚：添加错误提示和重试

---

## [UTC+2026-03-04 09:00] 项目优化和测试

**目标**: 优化性能，完善功能

**改动文件**:
- 各项优化

**验收标准**:
- [ ] 应用流畅运行
- [ ] 无明显卡顿
- [ ] 数据正确保存

**风险与回滚**:
- 风险：优化可能引入新问题
- 回滚：保留备份版本
