import Foundation

enum KnowledgePointType: String, Codable, CaseIterable {
    case mastered = "mastered"
    case weak = "weak"

    var displayName: String {
        switch self {
        case .mastered: return "已掌握"
        case .weak: return "薄弱知识点"
        }
    }

    var icon: String {
        switch self {
        case .mastered: return "checkmark.circle.fill"
        case .weak: return "exclamationmark.triangle.fill"
        }
    }
}

struct KnowledgePoint: Identifiable, Codable, Equatable {
    var id: Int64?
    var studentId: Int64
    var studentName: String?
    var grade: String
    var subject: String
    var topic: String
    var type: KnowledgePointType
    var totalScore: Double
    var recordCount: Int
    var lastRecordDate: Date
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case studentId = "student_id"
        case studentName = "student_name"
        case grade
        case subject
        case topic
        case type
        case totalScore = "total_score"
        case recordCount = "record_count"
        case lastRecordDate = "last_record_date"
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, studentId: Int64 = 0, studentName: String? = nil, grade: String = "", subject: String = "", topic: String = "", type: KnowledgePointType = .weak, totalScore: Double = 0, recordCount: Int = 1, lastRecordDate: Date = Date(), createdAt: Date = Date()) {
        self.id = id
        self.studentId = studentId
        self.studentName = studentName
        self.grade = grade
        self.subject = subject
        self.topic = topic
        self.type = type
        self.totalScore = totalScore
        self.recordCount = recordCount
        self.lastRecordDate = lastRecordDate
        self.createdAt = createdAt
    }
}
