import Foundation
import Combine

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var searchText: String = ""
    @Published var selectedGrade: String = ""
    @Published var selectedClassName: String = ""
    @Published var showArchived: Bool = false

    var filteredStudents: [Student] {
        var result = students

        // Filter by archived status
        if !showArchived {
            result = result.filter { !$0.archived }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        if !selectedGrade.isEmpty {
            result = result.filter { $0.grade == selectedGrade }
        }

        if !selectedClassName.isEmpty {
            result = result.filter { $0.className == selectedClassName }
        }

        return result
    }

    var grades: [String] {
        Array(Set(students.map { $0.grade })).sorted()
    }

    var classNames: [String] {
        Array(Set(students.compactMap { $0.className })).sorted()
    }

    var activeStudents: [Student] {
        students.filter { !$0.archived }
    }

    func loadStudents() {
        students = DatabaseService.shared.getAllStudents()
    }

    func saveStudent(_ student: Student) {
        _ = DatabaseService.shared.saveStudent(student)
        loadStudents()
    }

    func deleteStudent(_ student: Student) {
        if let id = student.id {
            DatabaseService.shared.deleteStudent(id: id)
            loadStudents()
        }
    }

    func archiveStudent(_ student: Student) {
        var updatedStudent = student
        updatedStudent.archived = true
        saveStudent(updatedStudent)
    }

    func unarchiveStudent(_ student: Student) {
        var updatedStudent = student
        updatedStudent.archived = false
        saveStudent(updatedStudent)
    }

    func getStudentName(by id: Int64) -> String? {
        return students.first { $0.id == id }?.name
    }

    func getStudentsByClassName(_ className: String) -> [Student] {
        return students.filter { $0.className == className && !$0.archived }
    }
}
