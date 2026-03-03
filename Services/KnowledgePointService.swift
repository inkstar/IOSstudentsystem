import Foundation
import Combine

class KnowledgePointService: ObservableObject {
    static let shared = KnowledgePointService()

    @Published var knowledgePoints: [KnowledgePoint] = []

    private let databaseService = DatabaseService.shared

    private init() {
        loadKnowledgePoints()
    }

    func loadKnowledgePoints() {
        knowledgePoints = databaseService.getAllKnowledgePoints()
    }

    func getKnowledgePoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return databaseService.getKnowledgePoints(forStudentId: studentId)
    }

    func getWeakPoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return databaseService.getWeakPoints(forStudentId: studentId)
    }

    func getWeakPoints(forGrade grade: String) -> [KnowledgePoint] {
        return databaseService.getWeakPoints(forGrade: grade)
    }

    func getMasteredPoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return databaseService.getMasteredPoints(forStudentId: studentId)
    }

    func saveKnowledgePoint(_ knowledgePoint: KnowledgePoint) {
        _ = databaseService.saveKnowledgePoint(knowledgePoint)
        loadKnowledgePoints()
    }

    func saveFromProgressRecord(_ progress: ProgressRecord, student: Student, type: KnowledgePointType) {
        let knowledgePoint = KnowledgePoint(
            studentId: progress.studentId,
            studentName: student.name,
            grade: student.grade,
            subject: progress.subject,
            topic: progress.topic,
            type: type,
            totalScore: progress.score,
            recordCount: 1,
            lastRecordDate: Date(),
            createdAt: Date()
        )
        saveKnowledgePoint(knowledgePoint)
    }

    func deleteKnowledgePoint(id: Int64) {
        databaseService.deleteKnowledgePoint(id: id)
        loadKnowledgePoints()
    }
}
