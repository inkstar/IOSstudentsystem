import Foundation
import Combine

class ProgressViewModel: ObservableObject {
    @Published var progressRecords: [ProgressRecord] = []
    @Published var selectedStudentId: Int64?

    var filteredProgressRecords: [ProgressRecord] {
        if let studentId = selectedStudentId {
            return progressRecords.filter { $0.studentId == studentId }
        }
        return progressRecords
    }

    func loadProgressRecords() {
        progressRecords = DatabaseService.shared.getAllProgressRecords()
    }

    func saveProgressRecord(_ record: ProgressRecord) {
        _ = DatabaseService.shared.saveProgressRecord(record)
        loadProgressRecords()
    }

    func deleteProgressRecord(_ record: ProgressRecord) {
        if let id = record.id {
            DatabaseService.shared.deleteProgressRecord(id: id)
            loadProgressRecords()
        }
    }
}
