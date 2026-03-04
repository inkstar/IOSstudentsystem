import Foundation
import Combine

class WeakPointViewModel: ObservableObject {
    @Published var tags: [WeakPointTag] = []
    @Published var knowledgePoints: [KnowledgePoint] = []

    // Tag management
    func loadTags() {
        tags = DatabaseService.shared.getAllWeakPointTags()
    }

    func saveTag(_ tag: WeakPointTag) {
        _ = DatabaseService.shared.saveWeakPointTag(tag)
        loadTags()
    }

    func deleteTag(_ tag: WeakPointTag) {
        if let id = tag.id {
            DatabaseService.shared.deleteWeakPointTag(id: id)
            loadTags()
        }
    }

    func getTags(forSubject subject: String?) -> [WeakPointTag] {
        return DatabaseService.shared.getWeakPointTags(forSubject: subject)
    }

    // Knowledge points enhanced
    func loadKnowledgePoints() {
        knowledgePoints = DatabaseService.shared.getAllKnowledgePoints()
    }

    func getWeakPoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return DatabaseService.shared.getWeakPoints(forStudentId: studentId)
    }

    func getWeakPointsGroupedByFrequency(forStudentId studentId: Int64) -> [(topic: String, count: Int)] {
        let weakPoints = getWeakPoints(forStudentId: studentId)
        var topicCounts: [String: Int] = [:]

        for point in weakPoints {
            topicCounts[point.topic, default: 0] += 1
        }

        return topicCounts.map { (topic: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    func getWeakPointsGroupedByFrequency(forClassName className: String) -> [(topic: String, count: Int, studentCount: Int)] {
        let students = DatabaseService.shared.getStudents(forClassName: className)
        var topicCounts: [String: (count: Int, students: Set<Int64>)] = [:]

        for student in students {
            let weakPoints = DatabaseService.shared.getWeakPoints(forStudentId: student.id ?? 0)
            for point in weakPoints {
                var entry = topicCounts[point.topic] ?? (count: 0, students: [])
                entry.count += 1
                entry.students.insert(student.id ?? 0)
                topicCounts[point.topic] = entry
            }
        }

        return topicCounts.map { (topic: $0.key, count: $0.value.count, studentCount: $0.value.students.count) }
            .sorted { $0.count > $1.count }
    }

    func getWeakPointStats(forStudentId studentId: Int64) -> (total: Int, topics: [String]) {
        let weakPoints = getWeakPoints(forStudentId: studentId)
        let topics = Array(Set(weakPoints.map { $0.topic }))
        return (weakPoints.count, topics)
    }

    func getClassWeakPointStats(className: String) -> (totalWeakPoints: Int, uniqueTopics: Int, studentCount: Int) {
        let students = DatabaseService.shared.getStudents(forClassName: className)
        var allTopics: Set<String> = []
        var studentWithWeakPoints = 0

        for student in students {
            let weakPoints = DatabaseService.shared.getWeakPoints(forStudentId: student.id ?? 0)
            if !weakPoints.isEmpty {
                studentWithWeakPoints += 1
                for point in weakPoints {
                    allTopics.insert(point.topic)
                }
            }
        }

        return (students.count * 5, allTopics.count, studentWithWeakPoints)
    }
}
