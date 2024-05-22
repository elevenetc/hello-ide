import SwiftUI
import Shared
import SwiftData

struct ContentView: View {
    
    @ObservedObject var projectsStorage: ProjectsStorage
    
    init(projectsStorage: ProjectsStorage) {
        self.projectsStorage = projectsStorage
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                //ForEach(items) { item in
                ForEach(projectsStorage.projects.sorted(by: { a, b in
                    a.created > b.created
                })) { project in
                    NavigationLink {
                        Text(project.id)
                    } label: {
                        Text(project.name)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }.onAppear {
                //onViewAppear()
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
        
    }
    
    private func deleteItems(offsets: IndexSet) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(projectsStorage: ProjectsStorage())
    }
}
