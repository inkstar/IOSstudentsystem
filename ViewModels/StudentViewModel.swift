import Foundation
import Combine

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var searchText: String = ""
    @Published var selectedGrade: String = ""

    var filteredStudents: [Student] {
        var result = students

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        if !selectedGrade.isEmpty {
            result = result.filter { $0.grade == selectedGrade }
        }

        return result
    }

    var grades: [String] {
        Array(Set(students.map { $0.grade })).sorted()
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

    func getStudentName(by id: Int64) -> String? {
        return students.first { $0.id == id }?.name
    }
}
