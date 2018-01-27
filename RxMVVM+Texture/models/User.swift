import Foundation

class User: RxModel {
    var username: String?
    var profileImageAbsoluteURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case username = "login"
        case profileImageAbsoluteURL = "avatar_url"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self,
                                             forKey: .username)
        self.profileImageAbsoluteURL = try container.decode(String.self,
                                                            forKey: .profileImageAbsoluteURL)
        
        super.init()
    }
}

