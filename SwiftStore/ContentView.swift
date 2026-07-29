import SwiftUI

struct ContentView: View {
    @EnvironmentObject var buildService: BuildService
    @EnvironmentObject var sourceService: SourceService
    @State private var selection: SidebarItem? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section(header: Text("SwiftStore")) {
                    NavigationLink(value: SidebarItem.dashboard) { Label("Dashboard", systemImage: "house") }
                    NavigationLink(value: SidebarItem.playgrounds) { Label("Playgrounds", systemImage: "hammer") }
                    NavigationLink(value: SidebarItem.sources) { Label("Sources", systemImage: "server.rack") }
                    NavigationLink(value: SidebarItem.settings) { Label("Settings", systemImage: "gear") }
                }
            }
            .navigationTitle("SwiftStore")
        } detail: {
            Group {
                switch selection {
                case .dashboard, .none:
                    DashboardView()
                case .playgrounds:
                    PlaygroundsView()
                case .sources:
                    SourcesView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }
}

enum SidebarItem: Hashable {
    case dashboard, playgrounds, sources, settings
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BuildService.sampleService())
            .environmentObject(SourceService.sampleService())
    }
}
