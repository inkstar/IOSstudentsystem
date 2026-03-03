import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var studentCount: Int = 0
    @Published var lessonCount: Int = 0
    @Published var weekLessonCount: Int = 0
    @Published var attendanceRate: Double = 0
    @Published var recentLessons: [Lesson] = []

    func loadData() {
        studentCount = DatabaseService.shared.getStudentCount()
        lessonCount = DatabaseService.shared.getLessonCount()
        weekLessonCount = DatabaseService.shared.getThisWeekLessonCount()
        attendanceRate = DatabaseService.shared.getAttendanceRate()
        recentLessons = DatabaseService.shared.getRecentLessons()
    }
}

