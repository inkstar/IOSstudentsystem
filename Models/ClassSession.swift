import Foundation

// 课堂记录 - 按课程实例创建，记录每次上课情况
struct ClassSession: Identifiable, Codable, Equatable {
    var id: Int64?
    var className: String      // 班级名称
    var date: Date             // 上课日期
    var startTime: String      // 开始时间
    var endTime: String        // 结束时间
    var subject: String         // 课程科目
    var topic: String?          // 本次主题
    var notes: String?         // 备注
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case className = "class_name"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case subject
        case topic
        case notes
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, className: String = "", date: Date = Date(), startTime: String = "", endTime: String = "", subject: String = "", topic: String? = nil, notes: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.className = className
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.subject = subject
        self.topic = topic
        self.notes = notes
        self.createdAt = createdAt
    }
}
