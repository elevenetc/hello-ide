import Foundation
import Shared

open class Message: Codable {
    open var id: String
        public init(id: String) {
            self.id = id
        }
    
    public convenience init() {
            self.init(id: "")
        }
}

struct Project: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let created: u_long
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class ProjectsMessage: Message {
    
    static let ID = MessageIdCompanion.shared.GET_PROJECTS
    
    private enum CodingKeys: String, CodingKey {
            case projects
        }
    
    var projects: [Project] = []
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        projects = try container.decode([Project].self, forKey: .projects)
        super.init(id: ProjectsMessage.ID)
    }
    
    init() {
        super.init(id: "invalid-projects")
    }
    
}
