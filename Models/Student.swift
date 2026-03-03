import Foundation

struct Student: Identifiable, Codable, Equatable {
    var id: Int64?
    var name: String
    var grade: String
    var phone: String
    var parentPhone: String
    var email: String
    var address: String
    var notes: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case grade
        case phone
        case parentPhone = "parent_phone"
        case email
        case address
        case notes
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, name: String = "", grade: String = "", phone: String = "", parentPhone: String = "", email: String = "", address: String = "", notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.grade = grade
        self.phone = phone
        self.parentPhone = parentPhone
        self.email = email
        self.address = address
        self.notes = notes
        self.createdAt = createdAt
    }
}
