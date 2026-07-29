import SwiftUI

struct PlaygroundsView: View {
    @EnvironmentObject var buildService: BuildService
    @EnvironmentObject var cloud: CloudBuildService
    @EnvironmentObject var github: GitHubService
    @State private var projectName = "MyPlayground"
    @State private var statusMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Export Swift Package")) {
                    TextField("Project name", text: $projectName)
                    Button(action: dispatch) {
                        Label("Dispatch to Cloud Build", systemImage: "cloud.upload")
                    }
                    if let status = statusMessage {
                        Text(status).font(.caption)
                    }
                }
                Section(header: Text("Help")) {
                    Text("Playgrounds Studio will package your SwiftPM bundle and push to a cloud builder for macOS compilation.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Playgrounds Studio")
        }
    }

    private func dispatch() {
        statusMessage = "Creating repository and uploading project..."
        let files = defaultProjectFiles(name: projectName)
        cloud.dispatchProject(name: projectName, files: files, github: github) { res in
            switch res {
            case .success(let build):
                DispatchQueue.main.async {
                    buildService.addBuild(named: build.name)
                    statusMessage = "Build queued: \(build.name)"
                }
            case .failure(let err):
                DispatchQueue.main.async { statusMessage = "Dispatch failed: \(err.localizedDescription)" }
            }
        }
    }

    private func defaultProjectFiles(name: String) -> [String: String] {
        let package = """
// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "\(name)",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "\(name)", targets: ["\(name)"])
    ],
    targets: [
        .target(name: "\(name)")
    ]
)
"""
        let readme = "# \(name)\n\nCreated by SwiftStore."
        let main = "// Placeholder source file for \(name)\n"
        return ["Package.swift": package, "README.md": readme, "Sources/\(name)/main.swift": main]
    }
}
