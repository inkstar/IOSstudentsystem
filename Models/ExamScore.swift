import Foundation

// 学生成绩记录
struct ExamScore: Identifiable, Codable, Equatable {
    var id: Int64?
    var examId: Int64          // 考试ID
    var studentId: Int64       // 学生ID
    var studentName: String     // 学生姓名
    var scores: [String: Double] // 各科分数字典，如 ["数学": 95, "英语": 88]
    var totalScore: Double      // 总分
    var rank: Int?             // 排名
    var comment: String?      // 评语
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case examId = "exam_id"
        case studentId = "student_id"
        case studentName = "student_name"
        case scores
        case totalScore = "total_score"
        case rank
        case comment
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, examId: Int64 = 0, studentId: Int64 = 0, studentName: String = "", scores: [String: Double] = [:], totalScore: Double = 0, rank: Int? = nil, comment: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.examId = examId
        self.studentId = studentId
        self.studentName = studentName
        self.scores = scores
        self.totalScore = totalScore
        self.rank = rank
        self.comment = comment
        self.createdAt = createdAt
    }
}
