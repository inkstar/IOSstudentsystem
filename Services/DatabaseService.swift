import Foundation

class DatabaseService {
    static let shared = DatabaseService()

    private let studentsKey = "students"
    private let lessonsKey = "lessons"
    private let progressKey = "progress"
    private let studentIdKey = "studentIdCounter"
    private let lessonIdKey = "lessonIdCounter"
    private let progressIdKey = "progressIdCounter"
    private let knowledgePointKey = "knowledgePoints"
    private let knowledgePointIdKey = "knowledgePointIdCounter"

    private init() {}

    // MARK: - Students

    func getAllStudents() -> [Student] {
        guard let data = UserDefaults.standard.data(forKey: studentsKey),
              let students = try? JSONDecoder().decode([Student].self, from: data) else {
            return []
        }
        return students.sorted { $0.createdAt > $1.createdAt }
    }

    func saveStudent(_ student: Student) -> Student {
        var students = getAllStudents()
        var newStudent = student

        if let index = students.firstIndex(where: { $0.id == student.id }) {
            newStudent.createdAt = students[index].createdAt
            students[index] = newStudent
        } else {
            let newId = getNextStudentId()
            newStudent.id = newId
            newStudent.createdAt = Date()
            students.append(newStudent)
        }

        saveStudents(students)
        return newStudent
    }

    func deleteStudent(id: Int64) {
        var students = getAllStudents()
        students.removeAll { $0.id == id }
        saveStudents(students)

        // Also delete related lessons and progress
        var lessons = getAllLessons()
        lessons.removeAll { $0.studentId == id }
        saveLessons(lessons)

        var progress = getAllProgressRecords()
        progress.removeAll { $0.studentId == id }
        saveProgressRecords(progress)

        // Also delete related knowledge points
        deleteKnowledgePoints(forStudentId: id)
    }

    private func saveStudents(_ students: [Student]) {
        if let data = try? JSONEncoder().encode(students) {
            UserDefaults.standard.set(data, forKey: studentsKey)
        }
    }

    private func getNextStudentId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: studentIdKey)
        UserDefaults.standard.set(id + 1, forKey: studentIdKey)
        return Int64(id + 1)
    }

    // MARK: - Lessons

    func getAllLessons() -> [Lesson] {
        guard let data = UserDefaults.standard.data(forKey: lessonsKey),
              let lessons = try? JSONDecoder().decode([Lesson].self, from: data) else {
            return []
        }
        return lessons.sorted { $0.lessonDate > $1.lessonDate }
    }

    func getLessons(forStudentId studentId: Int64) -> [Lesson] {
        return getAllLessons().filter { $0.studentId == studentId }
    }

    func saveLesson(_ lesson: Lesson) -> Lesson {
        var lessons = getAllLessons()
        var newLesson = lesson

        if let index = lessons.firstIndex(where: { $0.id == lesson.id }) {
            newLesson.createdAt = lessons[index].createdAt
            lessons[index] = newLesson
        } else {
            let newId = getNextLessonId()
            newLesson.id = newId
            newLesson.createdAt = Date()
            lessons.append(newLesson)
        }

        saveLessons(lessons)
        return newLesson
    }

    func deleteLesson(id: Int64) {
        var lessons = getAllLessons()
        lessons.removeAll { $0.id == id }
        saveLessons(lessons)
    }

    private func saveLessons(_ lessons: [Lesson]) {
        if let data = try? JSONEncoder().encode(lessons) {
            UserDefaults.standard.set(data, forKey: lessonsKey)
        }
    }

    private func getNextLessonId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: lessonIdKey)
        UserDefaults.standard.set(id + 1, forKey: lessonIdKey)
        return Int64(id + 1)
    }

    // MARK: - Progress Records

    func getAllProgressRecords() -> [ProgressRecord] {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode([ProgressRecord].self, from: data) else {
            return []
        }
        return progress.sorted { $0.recordDate > $1.recordDate }
    }

    func getProgressRecords(forStudentId studentId: Int64) -> [ProgressRecord] {
        return getAllProgressRecords().filter { $0.studentId == studentId }
    }

    func saveProgressRecord(_ progress: ProgressRecord) -> ProgressRecord {
        var progressList = getAllProgressRecords()
        var newProgress = progress

        if let index = progressList.firstIndex(where: { $0.id == progress.id }) {
            newProgress.createdAt = progressList[index].createdAt
            progressList[index] = newProgress
        } else {
            let newId = getNextProgressId()
            newProgress.id = newId
            newProgress.createdAt = Date()
            progressList.append(newProgress)
        }

        saveProgressRecords(progressList)
        return newProgress
    }

    func deleteProgressRecord(id: Int64) {
        var progress = getAllProgressRecords()
        progress.removeAll { $0.id == id }
        saveProgressRecords(progress)
    }

    private func saveProgressRecords(_ progress: [ProgressRecord]) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }

    private func getNextProgressId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: progressIdKey)
        UserDefaults.standard.set(id + 1, forKey: progressIdKey)
        return Int64(id + 1)
    }

    // MARK: - Knowledge Points

    func getAllKnowledgePoints() -> [KnowledgePoint] {
        guard let data = UserDefaults.standard.data(forKey: knowledgePointKey),
              let points = try? JSONDecoder().decode([KnowledgePoint].self, from: data) else {
            return []
        }
        return points.sorted { $0.lastRecordDate > $1.lastRecordDate }
    }

    func getKnowledgePoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return getAllKnowledgePoints().filter { $0.studentId == studentId }
    }

    func getWeakPoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return getKnowledgePoints(forStudentId: studentId).filter { $0.type == .weak }
    }

    func getWeakPoints(forGrade grade: String) -> [KnowledgePoint] {
        guard !grade.isEmpty else { return getAllKnowledgePoints().filter { $0.type == .weak } }
        return getAllKnowledgePoints().filter { $0.type == .weak && $0.grade == grade }
    }

    func getMasteredPoints(forStudentId studentId: Int64) -> [KnowledgePoint] {
        return getKnowledgePoints(forStudentId: studentId).filter { $0.type == .mastered }
    }

    func saveKnowledgePoint(_ knowledgePoint: KnowledgePoint) -> KnowledgePoint {
        var points = getAllKnowledgePoints()
        var newPoint = knowledgePoint

        // Check if this student+subject+topic already exists
        if let index = points.firstIndex(where: {
            $0.studentId == knowledgePoint.studentId &&
            $0.subject == knowledgePoint.subject &&
            $0.topic == knowledgePoint.topic &&
            $0.type == knowledgePoint.type
        }) {
            // Update existing - accumulate score and count
            points[index].totalScore += knowledgePoint.totalScore
            points[index].recordCount += 1
            points[index].lastRecordDate = Date()
            newPoint = points[index]
        } else {
            // Create new
            let newId = getNextKnowledgePointId()
            newPoint.id = newId
            newPoint.createdAt = Date()
            newPoint.lastRecordDate = Date()
            points.append(newPoint)
        }

        saveKnowledgePoints(points)
        return newPoint
    }

    func deleteKnowledgePoint(id: Int64) {
        var points = getAllKnowledgePoints()
        points.removeAll { $0.id == id }
        saveKnowledgePoints(points)
    }

    func deleteKnowledgePoints(forStudentId studentId: Int64) {
        var points = getAllKnowledgePoints()
        points.removeAll { $0.studentId == studentId }
        saveKnowledgePoints(points)
    }

    private func saveKnowledgePoints(_ points: [KnowledgePoint]) {
        if let data = try? JSONEncoder().encode(points) {
            UserDefaults.standard.set(data, forKey: knowledgePointKey)
        }
    }

    private func getNextKnowledgePointId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: knowledgePointIdKey)
        UserDefaults.standard.set(id + 1, forKey: knowledgePointIdKey)
        return Int64(id + 1)
    }

    // MARK: - Statistics

    func getStudentCount() -> Int {
        return getAllStudents().count
    }

    func getLessonCount() -> Int {
        return getAllLessons().count
    }

    func getThisWeekLessonCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return 0
        }
        return getAllLessons().filter { lesson in
            lesson.lessonDate >= weekStart && lesson.lessonDate <= now
        }.count
    }

    func getAttendanceRate() -> Double {
        let lessons = getAllLessons()
        guard !lessons.isEmpty else { return 0 }
        let completed = lessons.filter { $0.status == .completed }.count
        return Double(completed) / Double(lessons.count) * 100
    }

    func getRecentLessons(limit: Int = 5) -> [Lesson] {
        return Array(getAllLessons().prefix(limit))
    }

    // MARK: - Remote Data Sync

    func saveStudentsFromRemote(_ students: [Student]) {
        var existingStudents = getAllStudents()
        for remoteStudent in students {
            if let index = existingStudents.firstIndex(where: { $0.id == remoteStudent.id }) {
                existingStudents[index] = remoteStudent
            } else {
                existingStudents.append(remoteStudent)
            }
        }
        saveStudents(existingStudents)
    }

    func saveLessonsFromRemote(_ lessons: [Lesson]) {
        var existingLessons = getAllLessons()
        for remoteLesson in lessons {
            if let index = existingLessons.firstIndex(where: { $0.id == remoteLesson.id }) {
                existingLessons[index] = remoteLesson
            } else {
                existingLessons.append(remoteLesson)
            }
        }
        saveLessons(existingLessons)
    }

    func saveProgressFromRemote(_ progressList: [ProgressRecord]) {
        var existingProgress = getAllProgressRecords()
        for remoteProgress in progressList {
            if let index = existingProgress.firstIndex(where: { $0.id == remoteProgress.id }) {
                existingProgress[index] = remoteProgress
            } else {
                existingProgress.append(remoteProgress)
            }
        }
        saveProgressRecords(existingProgress)
    }
}
