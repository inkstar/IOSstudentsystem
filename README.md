# 学生课程管理系统 (iOS)

一个基于 SwiftUI 的 iOS 学生课程管理移动应用。

## 功能特性

### 仪表盘
- 实时统计数据展示（学生总数、课程数、本周出勤率）
- 近期课程列表

### 学生管理
- 添加、编辑、删除学生信息
- 学生基本信息管理（姓名、年级、联系方式等）
- 搜索和按年级筛选功能
- 学生详情页（查看关联课程和进度）

### 课程记录
- 记录上课信息（时间、科目、内容、作业）
- 课程状态管理（已完成、已取消、已改期）
- 按学生筛选课程

### 学习进度
- 记录学生学习进度和掌握程度
- 知识点跟踪
- 分数记录

### 设置
- 服务器地址配置
- 数据同步（本地/远程）
- 用户登录/登出

### 数据导出
- 支持导出 CSV 格式
- 支持导出 JSON 格式

## 技术栈

- **SwiftUI** - UI 框架
- **MVVM** - 架构模式
- **UserDefaults** - 本地数据存储
- **URLSession** - 网络请求

## 项目结构

```
├── App/                    # 应用入口
│   ├── StudentCourseManagerApp.swift
│   └── ContentView.swift
├── Models/                 # 数据模型
│   ├── Student.swift
│   ├── Lesson.swift
│   └── ProgressRecord.swift
├── Services/               # 服务层
│   ├── DatabaseService.swift    # 本地存储
│   ├── APIService.swift         # API 通信
│   ├── SyncService.swift        # 数据同步
│   └── ExportService.swift      # 数据导出
├── ViewModels/             # 视图模型
├── Views/                  # 视图
│   ├── Dashboard/
│   ├── Students/
│   ├── Lessons/
│   ├── Progress/
│   ├── Settings/
│   └── Components/
└── Resources/              # 资源文件
```

## 快速开始

### 环境要求
- Xcode 15.0+
- iOS 16.0+

### 安装

1. 克隆项目
```bash
git clone https://github.com/inkstar/IOSstudentsystem.git
```

2. 用 Xcode 打开 `StudentCourseManager.xcodeproj`

3. 选择模拟器并运行

### 配置服务器

1. 点击右下角「设置」Tab
2. 在「服务器地址」中输入后端服务器地址
3. 点击「保存服务器地址」
4. 点击「立即同步」同步数据

## API 接口

应用通过 REST API 与后端通信：

- `GET /api/dashboard` - 获取仪表盘数据
- `GET/POST /api/students` - 学生 CRUD
- `GET/POST /api/lessons` - 课程 CRUD
- `GET/POST /api/progress` - 进度 CRUD
- `POST /api/auth/login` - 用户登录

## 数据模型

### Student
- id: 主键
- name: 姓名
- grade: 年级
- phone: 联系电话
- parentPhone: 家长电话
- email: 邮箱
- address: 地址
- notes: 备注

### Lesson
- id: 主键
- studentId: 学生ID
- lessonDate: 上课日期
- lessonTime: 上课时间
- subject: 科目
- content: 课程内容
- homework: 作业
- duration: 时长
- status: 状态

### ProgressRecord
- id: 主键
- studentId: 学生ID
- recordDate: 记录日期
- subject: 科目
- topic: 知识点
- masteryLevel: 掌握程度
- score: 分数

## 许可证

MIT License

---

**享受使用学生课程管理系统！** 🎓
