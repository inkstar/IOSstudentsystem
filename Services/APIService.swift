import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case serverError(Int)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的 URL"
        case .noData: return "没有数据"
        case .decodingError: return "数据解析失败"
        case .networkError(let error): return "网络错误: \(error.localizedDescription)"
        case .serverError(let code): return "服务器错误: \(code)"
        case .unauthorized: return "未授权，请重新登录"
        }
    }
}

class APIService {
    static let shared = APIService()

    private let settingsKey = "serverURL"
    private let tokenKey = "authToken"

    var baseURL: String {
        get {
            UserDefaults.standard.string(forKey: settingsKey) ?? "http://localhost:8080"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: settingsKey)
        }
    }

    var authToken: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }

    var isLoggedIn: Bool {
        return authToken != nil
    }

    private init() {}

    // MARK: - Dashboard

    func fetchDashboard(completion: @escaping (Result<DashboardData, APIError>) -> Void) {
        request(endpoint: "/api/dashboard", method: "GET", completion: completion)
    }

    // MARK: - Students

    func fetchStudents(completion: @escaping (Result<[Student], APIError>) -> Void) {
        request(endpoint: "/api/students", method: "GET", completion: completion)
    }

    func createStudent(_ student: Student, completion: @escaping (Result<Student, APIError>) -> Void) {
        request(endpoint: "/api/students", method: "POST", body: student, completion: completion)
    }

    func updateStudent(_ student: Student, completion: @escaping (Result<Student, APIError>) -> Void) {
        guard let id = student.id else { return }
        request(endpoint: "/api/students/\(id)", method: "PUT", body: student, completion: completion)
    }

    func deleteStudent(id: Int64, completion: @escaping (Result<Void, APIError>) -> Void) {
        request(endpoint: "/api/students/\(id)", method: "DELETE", completion: completion)
    }

    // MARK: - Lessons

    func fetchLessons(completion: @escaping (Result<[Lesson], APIError>) -> Void) {
        request(endpoint: "/api/lessons", method: "GET", completion: completion)
    }

    func createLesson(_ lesson: Lesson, completion: @escaping (Result<Lesson, APIError>) -> Void) {
        request(endpoint: "/api/lessons", method: "POST", body: lesson, completion: completion)
    }

    func deleteLesson(id: Int64, completion: @escaping (Result<Void, APIError>) -> Void) {
        request(endpoint: "/api/lessons/\(id)", method: "DELETE", completion: completion)
    }

    // MARK: - Progress

    func fetchProgress(completion: @escaping (Result<[ProgressRecord], APIError>) -> Void) {
        request(endpoint: "/api/progress", method: "GET", completion: completion)
    }

    func createProgress(_ progress: ProgressRecord, completion: @escaping (Result<ProgressRecord, APIError>) -> Void) {
        request(endpoint: "/api/progress", method: "POST", body: progress, completion: completion)
    }

    func deleteProgress(id: Int64, completion: @escaping (Result<Void, APIError>) -> Void) {
        request(endpoint: "/api/progress/\(id)", method: "DELETE", completion: completion)
    }

    // MARK: - Auth

    func login(username: String, password: String, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        let body = ["username": username, "password": password]
        request(endpoint: "/api/auth/login", method: "POST", body: body, completion: completion)
    }

    func logout() {
        authToken = nil
    }

    // MARK: - Private

    private func request<T: Decodable>(endpoint: String, method: String, body: Encodable? = nil, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        completion(.failure(.unauthorized))
                        return
                    }
                    if httpResponse.statusCode >= 400 {
                        completion(.failure(.serverError(httpResponse.statusCode)))
                        return
                    }
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}

// MARK: - API Response Models

struct DashboardData: Codable {
    let studentCount: Int
    let lessonCount: Int
    let attendanceRate: Double
    let recentLessons: [Lesson]?

    enum CodingKeys: String, CodingKey {
        case studentCount = "student_count"
        case lessonCount = "lesson_count"
        case attendanceRate = "attendance_rate"
        case recentLessons = "recent_lessons"
    }
}

struct LoginResponse: Codable {
    let token: String
    let user: User?

    struct User: Codable {
        let id: Int64
        let username: String
    }
}
