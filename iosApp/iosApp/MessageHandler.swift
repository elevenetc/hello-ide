import Foundation
import Shared

class MessageHandler {
    
    let projectsStorage: ProjectsStorage
    
    init(projectsStorage: ProjectsStorage) {
        self.projectsStorage = projectsStorage
    }
    
    func handle(messageId: String, rawMessage: String) {
        MessageIdCompanion.shared.GET_PROJECTS
        if(ProjectsMessage.ID == messageId) {
            let projects = parseProjects(data: rawMessage)
            projectsStorage.addAll(projects: projects.projects)
        }
    }
}
