import SwiftUI

@main
struct SwiftStoreApp: App {
    @StateObject private var buildService: BuildService
    @StateObject private var sourceService: SourceService
    @StateObject private var cloud = CloudBuildService()
    @StateObject private var github = GitHubService()

    init() {
        let persistedBuilds = PersistenceService.loadBuilds() ?? []
        let persistedSources = PersistenceService.loadSources() ?? []
        _buildService = StateObject(wrappedValue: BuildService(initial: persistedBuilds))
        _sourceService = StateObject(wrappedValue: SourceService(initial: persistedSources))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(buildService)
                .environmentObject(sourceService)
                .environmentObject(cloud)
                .environmentObject(github)
                .onOpenURL { url in
                    github.handleOpenURL(url)
                }
        }
    }
}
