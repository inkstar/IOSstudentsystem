import Foundation
import Combine

class ExamViewModel: ObservableObject {
    @Published var exams: [Exam] = []
    @Published var examScores: [ExamScore] = []
    @Published var searchText: String = ""
    @Published var selectedClassName: String = ""
    @Published var selectedSubject: String = ""

    var filteredExams: [Exam] {
        var result = exams

        if !selectedClassName.isEmpty {
            result = result.filter { $0.className == selectedClassName }
        }

        if !selectedSubject.isEmpty {
            result = result.filter { $0.subject == selectedSubject }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.subject.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var classNames: [String] {
        Array(Set(exams.compactMap { $0.className })).sorted()
    }

    var subjects: [String] {
        Array(Set(exams.map { $0.subject })).sorted()
    }

    func loadExams() {
        exams = DatabaseService.shared.getAllExams()
    }

    func loadScores(forExamId examId: Int64) {
        examScores = DatabaseService.shared.getExamScores(forExamId: examId)
    }

    func loadScores(forStudentId studentId: Int64) {
        examScores = DatabaseService.shared.getExamScores(forStudentId: studentId)
    }

    func saveExam(_ exam: Exam) {
        _ = DatabaseService.shared.saveExam(exam)
        loadExams()
    }

    func deleteExam(_ exam: Exam) {
        if let id = exam.id {
            DatabaseService.shared.deleteExam(id: id)
            loadExams()
        }
    }

    func saveScore(_ score: ExamScore) {
        _ = DatabaseService.shared.saveExamScore(score)
    }

    func saveScoreBatch(_ scores: [ExamScore]) {
        DatabaseService.shared.saveExamScoreBatch(scores)
    }

    func getExam(by id: Int64) -> Exam? {
        return exams.first { $0.id == id }
    }

    func getStudentExamHistory(studentId: Int64) -> [(exam: Exam, score: ExamScore)] {
        let scores = DatabaseService.shared.getExamScores(forStudentId: studentId)
        return scores.compactMap { score -> (Exam, ExamScore)? in
            if let exam = exams.first(where: { $0.id == score.examId }) {
                return (exam, score)
            }
            return nil
        }.sorted { $0.exam.date < $1.exam.date }
    }

    func calculateTotalScores() {
        for i in examScores.indices {
            examScores[i].totalScore = examScores[i].scores.values.reduce(0, +)
        }
    }

    func updateRanks() {
        let sorted = examScores.sorted { $0.totalScore > $1.totalScore }
        for (index, score) in sorted.enumerated() {
            if let i = examScores.firstIndex(where: { $0.id == score.id }) {
                examScores[i].rank = index + 1
            }
        }
    }
}
