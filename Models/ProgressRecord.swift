import Foundation

enum MasteryLevel: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"

    var displayName: String {
        switch self {
        case .excellent: return "优秀"
        case .good: return "良好"
        case .average: return "一般"
        case .poor: return "需努力"
        }
    }
}

struct ProgressRecord: Identifiable, Codable, Equatable {
    var id: Int64?
    var studentId: Int64
    var studentName: String?
    var recordDate: Date
    var subject: String
    var topic: String
    var masteryLevel: MasteryLevel
    var score: Double
    var notes: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case studentId = "student_id"
        case studentName = "student_name"
        case recordDate = "record_date"
        case subject
        case topic
        case masteryLevel = "mastery_level"
        case score
        case notes
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, studentId: Int64 = 0, studentName: String? = nil, recordDate: Date = Date(), subject: String = "", topic: String = "", masteryLevel: MasteryLevel = .average, score: Double = 0, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.studentId = studentId
        self.studentName = studentName
        self.recordDate = recordDate
        self.subject = subject
        self.topic = topic
        self.masteryLevel = masteryLevel
        self.score = score
        self.notes = notes
        self.createdAt = createdAt
    }
}
