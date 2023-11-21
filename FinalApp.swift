import SwiftUI

@main
struct FinalApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                CustomerListView()
                    .tabItem {
                        Label("Customer List", systemImage: "list.bullet")
                    }
                
                ContentView()
                    .tabItem {
                        Label("Add Job", systemImage: "plus.circle.fill")
                    }
            }
        }
    }
}
