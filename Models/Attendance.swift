import Foundation

// 出勤状态
enum AttendanceStatus: String, Codable, CaseIterable {
    case present = "出勤"
    case absent = "缺勤"
    case late = "迟到"
    case leave = "请假"
}

// 课堂表现等级
enum PerformanceLevel: String, Codable, CaseIterable {
    case excellent = "优秀"
    case good = "良好"
    case average = "一般"
    case poor = "较差"
}

// 学生出勤记录
struct Attendance: Identifiable, Codable, Equatable {
    var id: Int64?
    var sessionId: Int64       // 课堂记录ID
    var studentId: Int64       // 学生ID
    var studentName: String    // 学生姓名
    var status: AttendanceStatus // 出勤状态
    var performance: PerformanceLevel? // 课堂表现
    var homework: String?      // 作业完成情况
    var comment: String?       // 老师评语
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case studentId = "student_id"
        case studentName = "student_name"
        case status
        case performance
        case homework
        case comment
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, sessionId: Int64 = 0, studentId: Int64 = 0, studentName: String = "", status: AttendanceStatus = .present, performance: PerformanceLevel? = nil, homework: String? = nil, comment: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.sessionId = sessionId
        self.studentId = studentId
        self.studentName = studentName
        self.status = status
        self.performance = performance
        self.homework = homework
        self.comment = comment
        self.createdAt = createdAt
    }
}
