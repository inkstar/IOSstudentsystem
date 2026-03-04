import Foundation

// 考试模型
struct Exam: Identifiable, Codable, Equatable {
    var id: Int64?
    var name: String           // 考试名称
    var date: Date             // 考试日期
    var className: String?     // 班级名称（可选）
    var subject: String        // 考试科目
    var totalScore: Double     // 总分
    var notes: String?         // 备注
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case date
        case className = "class_name"
        case subject
        case totalScore = "total_score"
        case notes
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, name: String = "", date: Date = Date(), className: String? = nil, subject: String = "", totalScore: Double = 100.0, notes: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.date = date
        self.className = className
        self.subject = subject
        self.totalScore = totalScore
        self.notes = notes
        self.createdAt = createdAt
    }
}
