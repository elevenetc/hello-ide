import SwiftUI

@main
struct iOSApp: App {

    let projectsStorage = ProjectsStorage()
	
	init() {
		print("app: init")
		startBackgroundTask()
	}

    var body: some Scene {
        WindowGroup {
            ContentView(projectsStorage: projectsStorage)
        }
    }

    func startBackgroundTask() {
        print("app: startBackgroundTask")
        DispatchQueue.global(qos: .background).async {

            print("app: startBackgroundTask.async")

            do {
                try initSocketConnection(projectsStorage: projectsStorage)
            } catch {
                print("Failed to send broadcast message: \(error)")
            }
        }
    }
}

