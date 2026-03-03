import Foundation

class ExportService {
    static let shared = ExportService()

    private init() {}

    // MARK: - Export Students

    func exportStudentsToCSV() -> String {
        let students = DatabaseService.shared.getAllStudents()
        var csv = "ID,姓名,年级,电话,家长电话,邮箱,地址,备注,创建时间\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for student in students {
            let row = [
                "\(student.id ?? 0)",
                escapeCSV(student.name),
                escapeCSV(student.grade),
                escapeCSV(student.phone),
                escapeCSV(student.parentPhone),
                escapeCSV(student.email),
                escapeCSV(student.address),
                escapeCSV(student.notes),
                dateFormatter.string(from: student.createdAt)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    func exportStudentsToJSON() -> String? {
        let students = DatabaseService.shared.getAllStudents()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(students) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Export Lessons

    func exportLessonsToCSV() -> String {
        let lessons = DatabaseService.shared.getAllLessons()
        var csv = "ID,学生ID,学生姓名,日期,时间,科目,内容,作业,时长,状态,备注,创建时间\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for lesson in lessons {
            let row = [
                "\(lesson.id ?? 0)",
                "\(lesson.studentId)",
                escapeCSV(lesson.studentName ?? ""),
                dateFormatter.string(from: lesson.lessonDate),
                escapeCSV(lesson.lessonTime),
                escapeCSV(lesson.subject),
                escapeCSV(lesson.content),
                escapeCSV(lesson.homework),
                "\(lesson.duration)",
                lesson.status.rawValue,
                escapeCSV(lesson.notes),
                dateFormatter.string(from: lesson.createdAt)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    func exportLessonsToJSON() -> String? {
        let lessons = DatabaseService.shared.getAllLessons()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(lessons) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Export Progress

    func exportProgressToCSV() -> String {
        let progressList = DatabaseService.shared.getAllProgressRecords()
        var csv = "ID,学生ID,学生姓名,日期,科目,知识点,掌握程度,分数,备注,创建时间\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for progress in progressList {
            let row = [
                "\(progress.id ?? 0)",
                "\(progress.studentId)",
                escapeCSV(progress.studentName ?? ""),
                dateFormatter.string(from: progress.recordDate),
                escapeCSV(progress.subject),
                escapeCSV(progress.topic),
                progress.masteryLevel.rawValue,
                "\(progress.score)",
                escapeCSV(progress.notes),
                dateFormatter.string(from: progress.createdAt)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    func exportProgressToJSON() -> String? {
        let progressList = DatabaseService.shared.getAllProgressRecords()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(progressList) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Export All

    func exportAllToJSON() -> String? {
        let students = DatabaseService.shared.getAllStudents()
        let lessons = DatabaseService.shared.getAllLessons()
        let progressList = DatabaseService.shared.getAllProgressRecords()

        let data: [String: Any] = [
            "students": students,
            "lessons": lessons,
            "progress": progressList,
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }

    // MARK: - Helpers

    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
}
