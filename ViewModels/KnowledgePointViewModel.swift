import Foundation
import Combine

class KnowledgePointViewModel: ObservableObject {
    @Published var weakPoints: [KnowledgePoint] = []
    @Published var masteredPoints: [KnowledgePoint] = []
    @Published var gradeWeakPoints: [KnowledgePoint] = []
    @Published var sortByCount: Bool = true

    private let knowledgePointService = KnowledgePointService.shared

    func loadWeakPoints(forStudentId studentId: Int64) {
        weakPoints = knowledgePointService.getWeakPoints(forStudentId: studentId)
        sortPoints()
    }

    func loadMasteredPoints(forStudentId studentId: Int64) {
        masteredPoints = knowledgePointService.getMasteredPoints(forStudentId: studentId)
    }

    func loadGradeWeakPoints(forGrade grade: String) {
        gradeWeakPoints = knowledgePointService.getWeakPoints(forGrade: grade)
        sortGradePoints()
    }

    func toggleSortOrder() {
        sortByCount.toggle()
        sortPoints()
        sortGradePoints()
    }

    private func sortPoints() {
        if sortByCount {
            weakPoints.sort { $0.recordCount > $1.recordCount }
        } else {
            weakPoints.sort { $0.totalScore < $1.totalScore }
        }
    }

    private func sortGradePoints() {
        if sortByCount {
            gradeWeakPoints.sort { $0.recordCount > $1.recordCount }
        } else {
            gradeWeakPoints.sort { $0.totalScore < $1.totalScore }
        }
    }

    func getStudentName(by studentId: Int64) -> String? {
        return DatabaseService.shared.getAllStudents().first { $0.id == studentId }?.name
    }

    func getStudentGrade(by studentId: Int64) -> String? {
        return DatabaseService.shared.getAllStudents().first { $0.id == studentId }?.grade
    }

    func deleteKnowledgePoint(id: Int64) {
        knowledgePointService.deleteKnowledgePoint(id: id)
    }
}
