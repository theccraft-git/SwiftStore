import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            switch appModel.selectedTab {
            case .dashboard:
                DashboardView()
            case .playgrounds:
                PlaygroundsView()
            case .sources:
                SourcesView()
            case .settings:
                SettingsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct SidebarView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        List(AppTab.allCases, selection: $appModel.selectedTab) { tab in
            Label(tab.rawValue, systemImage: tab.systemImage)
                .tag(tab)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.connectGitHub()
                } label: {
                    Image(systemName: appModel.githubConnected ? "checkmark.shield.fill" : "link")
                        .foregroundStyle(appModel.githubConnected ? .green : .blue)
                }
            }
        }
        .navigationTitle("SwiftStore")
    }
}
