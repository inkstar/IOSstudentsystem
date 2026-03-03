import Foundation
import Combine

enum SyncMode {
    case localOnly
    case remoteOnly
    case both
}

class SyncService: ObservableObject {
    static let shared = SyncService()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var syncMode: SyncMode = .both

    private let api = APIService.shared
    private let db = DatabaseService.shared

    private init() {}

    func syncAll(completion: @escaping (Bool) -> Void) {
        guard syncMode != .localOnly else {
            completion(true)
            return
        }

        isSyncing = true
        syncError = nil

        let group = DispatchGroup()
        var hasError = false

        // Sync students
        group.enter()
        api.fetchStudents { [weak self] result in
            switch result {
            case .success(let students):
                self?.db.saveStudentsFromRemote(students)
            case .failure(let error):
                hasError = true
                self?.syncError = error.localizedDescription
            }
            group.leave()
        }

        // Sync lessons
        group.enter()
        api.fetchLessons { [weak self] result in
            switch result {
            case .success(let lessons):
                self?.db.saveLessonsFromRemote(lessons)
            case .failure(let error):
                hasError = true
                self?.syncError = error.localizedDescription
            }
            group.leave()
        }

        // Sync progress
        group.enter()
        api.fetchProgress { [weak self] result in
            switch result {
            case .success(let progress):
                self?.db.saveProgressFromRemote(progress)
            case .failure(let error):
                hasError = true
                self?.syncError = error.localizedDescription
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.isSyncing = false
            if !hasError {
                self?.lastSyncDate = Date()
            }
            completion(!hasError)
        }
    }

    func syncStudents(completion: @escaping (Bool) -> Void) {
        guard syncMode != .localOnly else {
            completion(true)
            return
        }

        api.fetchStudents { [weak self] result in
            switch result {
            case .success(let students):
                self?.db.saveStudentsFromRemote(students)
                completion(true)
            case .failure(let error):
                self?.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func syncLessons(completion: @escaping (Bool) -> Void) {
        guard syncMode != .localOnly else {
            completion(true)
            return
        }

        api.fetchLessons { [weak self] result in
            switch result {
            case .success(let lessons):
                self?.db.saveLessonsFromRemote(lessons)
                completion(true)
            case .failure(let error):
                self?.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func syncProgress(completion: @escaping (Bool) -> Void) {
        guard syncMode != .localOnly else {
            completion(true)
            return
        }

        api.fetchProgress { [weak self] result in
            switch result {
            case .success(let progress):
                self?.db.saveProgressFromRemote(progress)
                completion(true)
            case .failure(let error):
                self?.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func uploadStudent(_ student: Student, completion: @escaping (Bool) -> Void) {
        if student.id == nil || student.id == 0 {
            api.createStudent(student) { result in
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.syncError = error.localizedDescription
                    completion(false)
                }
            }
        } else {
            api.updateStudent(student) { result in
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.syncError = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func deleteStudentRemote(id: Int64, completion: @escaping (Bool) -> Void) {
        api.deleteStudent(id: id) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                self.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func uploadLesson(_ lesson: Lesson, completion: @escaping (Bool) -> Void) {
        api.createLesson(lesson) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                self.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func deleteLessonRemote(id: Int64, completion: @escaping (Bool) -> Void) {
        api.deleteLesson(id: id) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                self.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func uploadProgress(_ progress: ProgressRecord, completion: @escaping (Bool) -> Void) {
        api.createProgress(progress) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                self.syncError = error.localizedDescription
                completion(false)
            }
        }
    }

    func deleteProgressRemote(id: Int64, completion: @escaping (Bool) -> Void) {
        api.deleteProgress(id: id) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                self.syncError = error.localizedDescription
                completion(false)
            }
        }
    }
}
