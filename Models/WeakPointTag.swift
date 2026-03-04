import Foundation

// 薄弱点标签
struct WeakPointTag: Identifiable, Codable, Equatable {
    var id: Int64?
    var name: String           // 标签名称
    var subject: String?      // 所属科目（可选，不填则为通用标签）
    var isGlobal: Bool         // 是否为全局标签（所有老师可见）
    var createdBy: String?     // 创建人
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subject
        case isGlobal = "is_global"
        case createdBy = "created_by"
        case createdAt = "created_at"
    }

    init(id: Int64? = nil, name: String = "", subject: String? = nil, isGlobal: Bool = false, createdBy: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.subject = subject
        self.isGlobal = isGlobal
        self.createdBy = createdBy
        self.createdAt = createdAt
    }
}
