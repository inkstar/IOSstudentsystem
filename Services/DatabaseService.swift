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
    private let classSessionKey = "classSessions"
    private let classSessionIdKey = "classSessionIdCounter"
    private let attendanceKey = "attendance"
    private let attendanceIdKey = "attendanceIdCounter"
    private let examKey = "exams"
    private let examIdKey = "examIdCounter"
    private let examScoreKey = "examScores"
    private let examScoreIdKey = "examScoreIdCounter"
    private let weakPointTagKey = "weakPointTags"
    private let weakPointTagIdKey = "weakPointTagIdCounter"

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

    // Student helper methods
    func getStudents(forClassName className: String) -> [Student] {
        return getAllStudents().filter { $0.className == className }
    }

    func getActiveStudents() -> [Student] {
        return getAllStudents().filter { !$0.archived }
    }

    func getArchivedStudents() -> [Student] {
        return getAllStudents().filter { $0.archived }
    }

    func getUniqueClassNames() -> [String] {
        let classNames = getAllStudents().compactMap { $0.className }
        return Array(Set(classNames)).sorted()
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

    // MARK: - Class Sessions

    func getAllClassSessions() -> [ClassSession] {
        guard let data = UserDefaults.standard.data(forKey: classSessionKey),
              let sessions = try? JSONDecoder().decode([ClassSession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.date > $1.date }
    }

    func getClassSessions(forClassName className: String) -> [ClassSession] {
        return getAllClassSessions().filter { $0.className == className }
    }

    func saveClassSession(_ session: ClassSession) -> ClassSession {
        var sessions = getAllClassSessions()
        var newSession = session

        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            newSession.createdAt = sessions[index].createdAt
            sessions[index] = newSession
        } else {
            let newId = getNextClassSessionId()
            newSession.id = newId
            newSession.createdAt = Date()
            sessions.append(newSession)
        }

        saveClassSessions(sessions)
        return newSession
    }

    func deleteClassSession(id: Int64) {
        var sessions = getAllClassSessions()
        sessions.removeAll { $0.id == id }
        saveClassSessions(sessions)

        // Also delete related attendance records
        var attendance = getAllAttendance()
        attendance.removeAll { $0.sessionId == id }
        saveAttendance(attendance)
    }

    private func saveClassSessions(_ sessions: [ClassSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: classSessionKey)
        }
    }

    private func getNextClassSessionId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: classSessionIdKey)
        UserDefaults.standard.set(id + 1, forKey: classSessionIdKey)
        return Int64(id + 1)
    }

    // MARK: - Attendance

    func getAllAttendance() -> [Attendance] {
        guard let data = UserDefaults.standard.data(forKey: attendanceKey),
              let records = try? JSONDecoder().decode([Attendance].self, from: data) else {
            return []
        }
        return records.sorted { $0.createdAt > $1.createdAt }
    }

    func getAttendance(forSessionId sessionId: Int64) -> [Attendance] {
        return getAllAttendance().filter { $0.sessionId == sessionId }
    }

    func getAttendance(forStudentId studentId: Int64) -> [Attendance] {
        return getAllAttendance().filter { $0.studentId == studentId }
    }

    func saveAttendance(_ record: Attendance) -> Attendance {
        var records = getAllAttendance()
        var newRecord = record

        if let index = records.firstIndex(where: { $0.id == record.id }) {
            newRecord.createdAt = records[index].createdAt
            records[index] = newRecord
        } else {
            let newId = getNextAttendanceId()
            newRecord.id = newId
            newRecord.createdAt = Date()
            records.append(newRecord)
        }

        saveAttendance(records)
        return newRecord
    }

    func saveAttendanceBatch(_ records: [Attendance]) {
        var allRecords = getAllAttendance()

        for record in records {
            if let index = allRecords.firstIndex(where: { $0.id == record.id }) {
                allRecords[index] = record
            } else {
                var newRecord = record
                newRecord.id = getNextAttendanceId()
                newRecord.createdAt = Date()
                allRecords.append(newRecord)
            }
        }

        saveAttendance(allRecords)
    }

    func deleteAttendance(id: Int64) {
        var records = getAllAttendance()
        records.removeAll { $0.id == id }
        saveAttendance(records)
    }

    private func saveAttendance(_ records: [Attendance]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: attendanceKey)
        }
    }

    private func getNextAttendanceId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: attendanceIdKey)
        UserDefaults.standard.set(id + 1, forKey: attendanceIdKey)
        return Int64(id + 1)
    }

    // MARK: - Exams

    func getAllExams() -> [Exam] {
        guard let data = UserDefaults.standard.data(forKey: examKey),
              let exams = try? JSONDecoder().decode([Exam].self, from: data) else {
            return []
        }
        return exams.sorted { $0.date > $1.date }
    }

    func getExams(forClassName className: String) -> [Exam] {
        return getAllExams().filter { $0.className == className }
    }

    func getExams(forStudentId studentId: Int64) -> [Exam] {
        let examIds = getAllExamScores().filter { $0.studentId == studentId }.map { $0.examId }
        return getAllExams().filter { examIds.contains($0.id ?? 0) }
    }

    func saveExam(_ exam: Exam) -> Exam {
        var exams = getAllExams()
        var newExam = exam

        if let index = exams.firstIndex(where: { $0.id == exam.id }) {
            newExam.createdAt = exams[index].createdAt
            exams[index] = newExam
        } else {
            let newId = getNextExamId()
            newExam.id = newId
            newExam.createdAt = Date()
            exams.append(newExam)
        }

        saveExams(exams)
        return newExam
    }

    func deleteExam(id: Int64) {
        var exams = getAllExams()
        exams.removeAll { $0.id == id }
        saveExams(exams)

        // Also delete related exam scores
        var scores = getAllExamScores()
        scores.removeAll { $0.examId == id }
        saveExamScores(scores)
    }

    private func saveExams(_ exams: [Exam]) {
        if let data = try? JSONEncoder().encode(exams) {
            UserDefaults.standard.set(data, forKey: examKey)
        }
    }

    private func getNextExamId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: examIdKey)
        UserDefaults.standard.set(id + 1, forKey: examIdKey)
        return Int64(id + 1)
    }

    // MARK: - Exam Scores

    func getAllExamScores() -> [ExamScore] {
        guard let data = UserDefaults.standard.data(forKey: examScoreKey),
              let scores = try? JSONDecoder().decode([ExamScore].self, from: data) else {
            return []
        }
        return scores.sorted { $0.createdAt > $1.createdAt }
    }

    func getExamScores(forExamId examId: Int64) -> [ExamScore] {
        return getAllExamScores().filter { $0.examId == examId }
    }

    func getExamScores(forStudentId studentId: Int64) -> [ExamScore] {
        return getAllExamScores().filter { $0.studentId == studentId }
    }

    func saveExamScore(_ score: ExamScore) -> ExamScore {
        var scores = getAllExamScores()
        var newScore = score

        if let index = scores.firstIndex(where: { $0.id == score.id }) {
            newScore.createdAt = scores[index].createdAt
            scores[index] = newScore
        } else {
            let newId = getNextExamScoreId()
            newScore.id = newId
            newScore.createdAt = Date()
            scores.append(newScore)
        }

        saveExamScores(scores)
        return newScore
    }

    func saveExamScoreBatch(_ scores: [ExamScore]) {
        var allScores = getAllExamScores()

        for score in scores {
            if let index = allScores.firstIndex(where: { $0.id == score.id }) {
                allScores[index] = score
            } else {
                var newScore = score
                newScore.id = getNextExamScoreId()
                newScore.createdAt = Date()
                allScores.append(newScore)
            }
        }

        saveExamScores(allScores)
    }

    func deleteExamScore(id: Int64) {
        var scores = getAllExamScores()
        scores.removeAll { $0.id == id }
        saveExamScores(scores)
    }

    private func saveExamScores(_ scores: [ExamScore]) {
        if let data = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(data, forKey: examScoreKey)
        }
    }

    private func getNextExamScoreId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: examScoreIdKey)
        UserDefaults.standard.set(id + 1, forKey: examScoreIdKey)
        return Int64(id + 1)
    }

    // MARK: - Weak Point Tags

    func getAllWeakPointTags() -> [WeakPointTag] {
        guard let data = UserDefaults.standard.data(forKey: weakPointTagKey),
              let tags = try? JSONDecoder().decode([WeakPointTag].self, from: data) else {
            return []
        }
        return tags.sorted { $0.createdAt > $1.createdAt }
    }

    func getWeakPointTags(forSubject subject: String?) -> [WeakPointTag] {
        if let subject = subject, !subject.isEmpty {
            return getAllWeakPointTags().filter { $0.subject == subject || $0.isGlobal }
        }
        return getAllWeakPointTags()
    }

    func getGlobalWeakPointTags() -> [WeakPointTag] {
        return getAllWeakPointTags().filter { $0.isGlobal }
    }

    func saveWeakPointTag(_ tag: WeakPointTag) -> WeakPointTag {
        var tags = getAllWeakPointTags()
        var newTag = tag

        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            newTag.createdAt = tags[index].createdAt
            tags[index] = newTag
        } else {
            let newId = getNextWeakPointTagId()
            newTag.id = newId
            newTag.createdAt = Date()
            tags.append(newTag)
        }

        saveWeakPointTags(tags)
        return newTag
    }

    func deleteWeakPointTag(id: Int64) {
        var tags = getAllWeakPointTags()
        tags.removeAll { $0.id == id }
        saveWeakPointTags(tags)
    }

    private func saveWeakPointTags(_ tags: [WeakPointTag]) {
        if let data = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(data, forKey: weakPointTagKey)
        }
    }

    private func getNextWeakPointTagId() -> Int64 {
        let id = UserDefaults.standard.integer(forKey: weakPointTagIdKey)
        UserDefaults.standard.set(id + 1, forKey: weakPointTagIdKey)
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
