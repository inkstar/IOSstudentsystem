# iOS 学生课程管理系统 - 产品需求文档 (PRD)

## 1. 项目概述

- **项目名称**: StudentCourseManager (iOS)
- **项目类型**: iOS 原生应用
- **核心功能**: 学生课程管理移动端应用，提供学生管理、课程记录、学习进度跟踪等功能
- **目标用户**: 老师/培训机构工作人员

## 2. 功能需求

### 2.1 仪表盘
- 显示学生总数、课程数、本周出勤率等关键统计数据
- 展示近期课程安排
- 快速查看今日/本周课程

### 2.2 学生管理
- 学生列表展示（表格/列表形式）
- 添加新学生（姓名、年级、联系方式、家长电话、邮箱、地址、备注）
- 编辑学生信息
- 删除学生
- 搜索学生（按姓名）
- 筛选学生（按年级）

### 2.3 课程记录
- 课程列表展示
- 添加课程记录（选择学生、日期、时间、科目、内容、作业、时长、状态、备注）
- 课程状态管理：已完成、已取消、已改期
- 查看课程历史记录
- 按学生筛选课程

### 2.4 学习进度
- 进度记录列表
- 添加进度记录（选择学生、日期、科目、知识点、掌握程度、分数、备注）
- 掌握程度评估：优秀、良好、一般、需努力
- 查看学习进度历史

## 3. UI/UX 设计要求

### 3.1 导航结构
- **UITabBarController**: 4个Tab
  - 仪表盘 (Dashboard)
  - 学生 (Students)
  - 课程 (Lessons)
  - 进度 (Progress)

### 3.2 视觉设计
- 配色方案：蓝色为主色（#007AFF），白色背景，灰色文字
- 使用 iOS 原生设计语言 (SwiftUI)
- 卡片式布局展示数据
- 列表形式展示记录

### 3.3 关键页面
1. **仪表盘页面**: 统计卡片 + 近期课程列表
2. **学生列表页面**: 搜索栏 + 筛选器 + 学生列表
3. **学生详情/编辑页面**: 表单视图
4. **课程列表页面**: 课程记录列表 + 添加按钮
5. **课程添加/编辑页面**: 表单视图
6. **进度列表页面**: 进度记录列表
7. **进度添加页面**: 表单视图

## 4. 技术架构

### 4.1 技术栈
- **UI Framework**: SwiftUI
- **语言**: Swift 5.9+
- **数据存储**: SQLite (使用 SQLite.swift)
- **架构模式**: MVVM

### 4.2 数据模型
```
Student:
  - id: Int64 (主键)
  - name: String
  - grade: String
  - phone: String
  - parentPhone: String
  - email: String
  - address: String
  - notes: String
  - createdAt: Date

Lesson:
  - id: Int64 (主键)
  - studentId: Int64 (外键)
  - lessonDate: Date
  - lessonTime: String
  - subject: String
  - content: String
  - homework: String
  - duration: Int (分钟)
  - status: String (completed/cancelled/rescheduled)
  - notes: String
  - createdAt: Date

ProgressRecord:
  - id: Int64 (主键)
  - studentId: Int64 (外键)
  - recordDate: Date
  - subject: String
  - topic: String
  - masteryLevel: String (excellent/good/average/poor)
  - score: Double
  - notes: String
  - createdAt: Date
```

## 5. API 接口 (对接现有后端)

由于本项目已有 Flask 后端，iOS 应用将通过 REST API 与后端通信：

- Base URL: `http://localhost:8080/api`
- 详细接口参照原网页端 API 设计

### 离线支持
- 优先使用本地 SQLite 缓存
- 支持离线查看缓存数据
- 网络可用时同步数据

## 6. 验收标准

### 功能验收
- [ ] 仪表盘正确显示统计数据
- [ ] 学生 CRUD 操作正常
- [ ] 课程 CRUD 操作正常
- [ ] 进度记录 CRUD 操作正常
- [ ] 搜索和筛选功能正常

### UI 验收
- [ ] 四个 Tab 导航正常切换
- [ ] 表单输入体验良好
- [ ] 列表加载流畅
- [ ] 适配不同 iPhone 尺寸

### 数据验收
- [ ] 数据正确保存到本地
- [ ] 数据正确显示在界面上
