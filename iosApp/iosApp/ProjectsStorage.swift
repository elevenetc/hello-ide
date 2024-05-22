import Foundation

class ProjectsStorage: ObservableObject {
    @Published private(set) var projects: Set<Project> = []

    func addProject(project: Project) {
        DispatchQueue.main.async {
            self.projects.insert(project)
        }
    }
    
    func addAll(projects: [Project]) {
        DispatchQueue.main.async {
            self.projects.removeAll()
            for project in projects {
                self.projects.insert(project)
            }
        }
    }
}
