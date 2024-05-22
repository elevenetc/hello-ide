import Foundation

private let decoder = JSONDecoder()

func parseProject(data: String) throws  -> Project {
    let p = try decoder.decode(Project.self, from: data.data(using: .utf8)!)
    return p
}

func parseMessageId(data: String) -> String {
    do {
        let msg = try decoder.decode(Message.self, from: data.data(using: .utf8)!)
        return msg.id
    } catch {
        print("Message parse error: \(error)")
        return "error-message-id"
    }
}

func parseProjects(data: String) -> ProjectsMessage {
    do {
        let projects = try decoder.decode(ProjectsMessage.self, from: data.data(using: .utf8)!)
        return projects
    } catch {
        print("Projects parse error: \(error)")
        return ProjectsMessage()
    }
}
