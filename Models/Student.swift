import Foundation

struct Student: Identifiable, Codable, Equatable {
    var id: Int64?
    var name: String
    var grade: String
    var gender: String        // "男" / "女"
    var school: String        // 学校名称
    var classId: Int64?      // 班级ID
    var className: String?   // 班级名称
    var phone: String
    var parentPhone: String
    var email: String
    var address: String
    var notes: String
    var archived: Bool       // 归档状态
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case grade
        case gender
        case school
        case classId = "class_id"
        case className = "class_name"
        case phone
        case parentPhone = "parent_phone"
        case email
        case address
        case notes
        case archived
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, name: String = "", grade: String = "", gender: String = "", school: String = "", classId: Int64? = nil, className: String? = nil, phone: String = "", parentPhone: String = "", email: String = "", address: String = "", notes: String = "", archived: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.grade = grade
        self.gender = gender
        self.school = school
        self.classId = classId
        self.className = className
        self.phone = phone
        self.parentPhone = parentPhone
        self.email = email
        self.address = address
        self.notes = notes
        self.archived = archived
        self.createdAt = createdAt
    }
}
