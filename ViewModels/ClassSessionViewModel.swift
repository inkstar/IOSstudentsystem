import Foundation
import Combine

class ClassSessionViewModel: ObservableObject {
    @Published var sessions: [ClassSession] = []
    @Published var attendanceRecords: [Attendance] = []
    @Published var searchText: String = ""
    @Published var selectedClassName: String = ""
    @Published var selectedSubject: String = ""

    var filteredSessions: [ClassSession] {
        var result = sessions

        if !selectedClassName.isEmpty {
            result = result.filter { $0.className == selectedClassName }
        }

        if !selectedSubject.isEmpty {
            result = result.filter { $0.subject == selectedSubject }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.className.localizedCaseInsensitiveContains(searchText) ||
                $0.topic?.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        return result
    }

    var classNames: [String] {
        Array(Set(sessions.map { $0.className })).sorted()
    }

    var subjects: [String] {
        Array(Set(sessions.map { $0.subject })).sorted()
    }

    func loadSessions() {
        sessions = DatabaseService.shared.getAllClassSessions()
    }

    func loadAttendance(forSessionId sessionId: Int64) {
        attendanceRecords = DatabaseService.shared.getAttendance(forSessionId: sessionId)
    }

    func saveSession(_ session: ClassSession) {
        _ = DatabaseService.shared.saveClassSession(session)
        loadSessions()
    }

    func deleteSession(_ session: ClassSession) {
        if let id = session.id {
            DatabaseService.shared.deleteClassSession(id: id)
            loadSessions()
        }
    }

    func saveAttendance(_ record: Attendance) {
        _ = DatabaseService.shared.saveAttendance(record)
    }

    func saveAttendanceBatch(_ records: [Attendance]) {
        DatabaseService.shared.saveAttendanceBatch(records)
    }

    func getSession(by id: Int64) -> ClassSession? {
        return sessions.first { $0.id == id }
    }
}
