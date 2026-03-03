import Foundation

enum LessonStatus: String, Codable, CaseIterable {
    case completed = "completed"
    case cancelled = "cancelled"
    case rescheduled = "rescheduled"

    var displayName: String {
        switch self {
        case .completed: return "已完成"
        case .cancelled: return "已取消"
        case .rescheduled: return "已改期"
        }
    }
}

struct Lesson: Identifiable, Codable, Equatable {
    var id: Int64?
    var studentId: Int64
    var studentName: String?
    var lessonDate: Date
    var lessonTime: String
    var subject: String
    var content: String
    var homework: String
    var duration: Int
    var status: LessonStatus
    var notes: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case studentId = "student_id"
        case studentName = "student_name"
        case lessonDate = "lesson_date"
        case lessonTime = "lesson_time"
        case subject
        case content
        case homework
        case duration
        case status
        case notes
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, studentId: Int64 = 0, studentName: String? = nil, lessonDate: Date = Date(), lessonTime: String = "", subject: String = "", content: String = "", homework: String = "", duration: Int = 60, status: LessonStatus = .completed, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.studentId = studentId
        self.studentName = studentName
        self.lessonDate = lessonDate
        self.lessonTime = lessonTime
        self.subject = subject
        self.content = content
        self.homework = homework
        self.duration = duration
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }
}
