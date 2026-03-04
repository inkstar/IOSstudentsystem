import Foundation

struct ImportResult {
    var successCount: Int = 0
    var errorCount: Int = 0
    var errors: [(row: Int, message: String)] = []
}

class ImportService {
    static let shared = ImportService()

    private init() {}

    // CSV import template: 姓名,性别,年级,学校,电话,家长电话,班级
    func importStudentsFromCSV(_ content: String) -> ImportResult {
        var result = ImportResult()
        let lines = content.components(separatedBy: .newlines)

        // Skip header row
        for (index, line) in lines.dropFirst().enumerated() {
            let rowNumber = index + 2 // 1-indexed, skipping header
            let fields = parseCSVLine(line)

            // Validate required fields
            guard fields.count >= 7 else {
                result.errors.append((row: rowNumber, message: "字段数量不足，需要7个字段"))
                result.errorCount += 1
                continue
            }

            let name = fields[0].trimmingCharacters(in: .whitespaces)
            let gender = fields[1].trimmingCharacters(in: .whitespaces)
            let grade = fields[2].trimmingCharacters(in: .whitespaces)
            let school = fields[3].trimmingCharacters(in: .whitespaces)
            let phone = fields[4].trimmingCharacters(in: .whitespaces)
            let parentPhone = fields[5].trimmingCharacters(in: .whitespaces)
            let className = fields[6].trimmingCharacters(in: .whitespaces)

            // Validate required fields
            if name.isEmpty {
                result.errors.append((row: rowNumber, message: "姓名为必填项"))
                result.errorCount += 1
                continue
            }

            // Validate gender
            if !gender.isEmpty && gender != "男" && gender != "女" {
                result.errors.append((row: rowNumber, message: "性别必须为'男'或'女'"))
                result.errorCount += 1
                continue
            }

            // Create student
            let student = Student(
                name: name,
                grade: grade,
                gender: gender,
                school: school,
                className: className.isEmpty ? nil : className,
                phone: phone,
                parentPhone: parentPhone
            )

            _ = DatabaseService.shared.saveStudent(student)
            result.successCount += 1
        }

        return result
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        result.append(currentField)

        return result
    }

    func generateStudentCSVTemplate() -> String {
        return "姓名,性别,年级,学校,电话,家长电话,班级\n张三,男,高三,第一中学,13800138000,13900139000,高三一班"
    }

    func exportStudentsToCSV(_ students: [Student]) -> String {
        var csv = "姓名,性别,年级,学校,电话,家长电话,班级,归档状态\n"

        for student in students {
            let archivedStatus = student.archived ? "已归档" : "在读"
            let row = [
                escapeCSV(student.name),
                escapeCSV(student.gender),
                escapeCSV(student.grade),
                escapeCSV(student.school),
                escapeCSV(student.phone),
                escapeCSV(student.parentPhone),
                escapeCSV(student.className ?? ""),
                escapeCSV(archivedStatus)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
