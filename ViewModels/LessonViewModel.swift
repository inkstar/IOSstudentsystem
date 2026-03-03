import Foundation
import Combine

class LessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var selectedStudentId: Int64?

    var filteredLessons: [Lesson] {
        if let studentId = selectedStudentId {
            return lessons.filter { $0.studentId == studentId }
        }
        return lessons
    }

    func loadLessons() {
        lessons = DatabaseService.shared.getAllLessons()
    }

    func saveLesson(_ lesson: Lesson) {
        _ = DatabaseService.shared.saveLesson(lesson)
        loadLessons()
    }

    func deleteLesson(_ lesson: Lesson) {
        if let id = lesson.id {
            DatabaseService.shared.deleteLesson(id: id)
            loadLessons()
        }
    }
}
