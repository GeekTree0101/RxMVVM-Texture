import Foundation

class Repository: RxModel {
    var id: Int
    var user: User?
    var repositoryName: String?
    var desc: String?
    var isPrivate: Bool = false
    var isForked: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case user = "owner"
        case repositoryName = "full_name"
        case desc = "description"
        case isPrivate = "private"
        case isForked = "fork"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.user = try? container.decode(User.self, forKey: .user)
        self.repositoryName = try? container.decode(String.self, forKey: .repositoryName)
        self.desc = try? container.decode(String.self, forKey: .desc)
        self.isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        self.isForked = try container.decode(Bool.self, forKey: .isForked)
        
        super.init()
    }
}

