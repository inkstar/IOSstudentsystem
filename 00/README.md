# 学生课程管理系统

一个基于Flask和Bootstrap的现代化学生课程管理Web应用系统。

## 🌟 功能特性

### 📊 仪表盘
- 实时统计数据展示（学生总数、课程数、出勤率等）
- 可视化图表展示学习进度和出勤情况
- 直观的数据概览

### 👥 学生管理
- 添加、编辑、删除学生信息
- 学生基本信息管理（姓名、年级、联系方式等）
- 搜索和筛选功能
- 响应式表格展示

### 📚 课程记录
- 记录上课信息（时间、科目、内容、作业）
- 课程状态管理（已完成、已取消、已改期）
- 课程历史记录查看
- 自动填充学生选择

### 📈 学习进度
- 记录学生学习进度和掌握程度
- 知识点掌握情况跟踪
- 分数记录和分析
- 学习报告生成

## 🚀 快速开始

### 环境要求
- Python 3.7+
- pip

### 安装步骤

1. **克隆或下载项目**
```bash
cd /Users/shenchaonan/Documents/cursor_project/student_info
```

2. **安装依赖**
```bash
pip install -r requirements.txt
```

3. **运行应用**

**方法一：使用启动脚本（推荐）**
```bash
./start.sh
```

**方法二：手动启动**
```bash
# 激活虚拟环境
source venv/bin/activate

# 运行应用
python app.py
```

4. **访问系统**
打开浏览器访问：http://localhost:8080

## 📱 界面预览

### 仪表盘
- 统计卡片显示关键数据
- 饼图展示出勤率
- 柱状图显示学习进度分布

### 学生管理
- 响应式表格展示学生列表
- 搜索框快速查找学生
- 年级筛选功能
- 模态框添加/编辑学生

### 课程记录
- 课程信息表单
- 学生选择下拉框
- 课程状态管理
- 课程历史记录表格

### 学习进度
- 进度记录表单
- 掌握程度评估
- 分数记录
- 进度历史查看

## 🛠️ 技术栈

### 后端
- **Flask** - Web框架
- **SQLAlchemy** - 数据库ORM
- **SQLite** - 轻量级数据库
- **Flask-CORS** - 跨域支持

### 前端
- **Bootstrap 5** - 响应式UI框架
- **Chart.js** - 数据可视化
- **Bootstrap Icons** - 图标库
- **原生JavaScript** - 前端逻辑

## 📊 数据库设计

### 学生表 (Student)
- id: 主键
- name: 姓名
- grade: 年级
- phone: 联系方式
- parent_phone: 家长电话
- email: 邮箱
- address: 地址
- notes: 备注

### 课程表 (Lesson)
- id: 主键
- student_id: 学生ID（外键）
- lesson_date: 上课日期
- lesson_time: 上课时间
- subject: 科目
- content: 课程内容
- homework: 作业
- duration: 时长（分钟）
- status: 状态
- notes: 备注

### 进度记录表 (ProgressRecord)
- id: 主键
- student_id: 学生ID（外键）
- record_date: 记录日期
- subject: 科目
- topic: 知识点
- mastery_level: 掌握程度
- score: 分数
- notes: 备注

## 🔧 API接口

### 学生管理
- `GET /api/students` - 获取所有学生
- `POST /api/students` - 添加学生
- `PUT /api/students/<id>` - 更新学生信息
- `DELETE /api/students/<id>` - 删除学生

### 课程记录
- `GET /api/lessons` - 获取课程记录
- `POST /api/lessons` - 添加课程记录

### 学习进度
- `GET /api/progress` - 获取学习进度
- `POST /api/progress` - 添加学习进度记录

### 统计报告
- `GET /api/dashboard` - 获取仪表盘数据
- `GET /api/reports/student/<id>` - 获取学生报告

## 📁 项目结构

```
student_info/
├── app.py                 # Flask主应用
├── requirements.txt       # 依赖列表
├── README.md             # 项目说明
├── templates/
│   └── index.html        # 主页面模板
├── static/
│   ├── css/              # 样式文件
│   ├── js/
│   │   └── app.js        # 前端JavaScript
│   └── images/           # 图片资源
└── student_info.db       # SQLite数据库（自动生成）
```

## 🎯 使用指南

### 1. 学生管理
1. 点击"学生管理"进入学生管理页面
2. 点击"添加学生"按钮添加新学生
3. 填写学生基本信息
4. 使用搜索框快速查找学生
5. 使用年级筛选功能筛选学生

### 2. 课程记录
1. 点击"课程记录"进入课程记录页面
2. 点击"添加课程"按钮记录新课程
3. 选择学生、填写课程信息
4. 查看课程历史记录

### 3. 学习进度
1. 点击"学习进度"进入进度管理页面
2. 点击"记录进度"按钮添加进度记录
3. 评估学生掌握程度
4. 查看学习进度历史

### 4. 仪表盘
1. 查看关键统计数据
2. 分析出勤率图表
3. 查看学习进度分布

## 🔒 数据安全

- 数据自动保存到本地SQLite数据库
- 输入数据验证和错误处理
- 用户友好的错误提示

## 🚀 部署建议

### 本地部署
- 直接运行 `python app.py`
- 访问 http://localhost:5000

### 生产部署
- 使用Gunicorn作为WSGI服务器
- 配置Nginx作为反向代理
- 使用PostgreSQL或MySQL替代SQLite
- 配置HTTPS和域名

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 📄 许可证

MIT License

## 🆘 常见问题

### Q: 如何重置数据库？
A: 删除 `student_info.db` 文件，重新启动应用即可。

### Q: 如何备份数据？
A: 直接复制 `student_info.db` 文件即可备份所有数据。

### Q: 如何添加新的字段？
A: 修改 `app.py` 中的模型定义，然后删除数据库文件重新创建。

## 📞 技术支持

如有问题或建议，请通过以下方式联系：
- 创建Issue
- 发送邮件
- 提交Pull Request

---

**享受使用学生课程管理系统！** 🎓✨
