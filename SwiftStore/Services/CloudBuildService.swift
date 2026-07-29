import Foundation
import Combine

final class CloudBuildService: ObservableObject {
    @Published var activeJobs: [Build] = []

    /// Dispatch a set of project files to GitHub and upload a build workflow.
    func dispatchProject(name: String, files: [String: String], github: GitHubService, completion: @escaping (Result<Build, Error>) -> Void) {
        github.createRepository(name: name) { repoRes in
            switch repoRes {
            case .failure(let err): completion(.failure(err))
            case .success(let repoURL):
                // repoURL is like https://github.com/owner/repo
                let fullName = repoURL.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let repoFullName = fullName
                // Upload files
                let group = DispatchGroup()
                var uploadError: Error?
                for (path, content) in files {
                    group.enter()
                    github.createFile(repoFullName: repoFullName, path: path, content: content) { res in
                        if case .failure(let err) = res { uploadError = err }
                        group.leave()
                    }
                }
                group.notify(queue: .global()) {
                    if let err = uploadError { completion(.failure(err)); return }
                    // Upload workflow
                    let workflow = self.buildWorkflowYAML(projectName: name)
                    github.createFile(repoFullName: repoFullName, path: ".github/workflows/build.yml", content: workflow, message: "Add build workflow") { wfRes in
                        switch wfRes {
                        case .failure(let err): completion(.failure(err))
                        case .success:
                            // Trigger a simulated cloud build
                            self.triggerCloudBuild(repoURL: repoURL) { res in
                                completion(res)
                            }
                        }
                    }
                }
            }
        }
    }

    func createRepository(for projectName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Stub: simulate creating a private GitHub repository and returning its URL
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let url = URL(string: "https://github.com/example/\(projectName)")!
            completion(.success(url))
        }
    }

    func triggerCloudBuild(repoURL: URL, completion: @escaping (Result<Build, Error>) -> Void) {
        // Stubbed cloud build: create a Build and simulate status changes
        let build = Build(name: repoURL.lastPathComponent, status: .queued)
        DispatchQueue.main.async {
            self.activeJobs.insert(build, at: 0)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            var b = build
            b.status = .running
            DispatchQueue.main.async {
                if let idx = self.activeJobs.firstIndex(where: { $0.id == build.id }) { self.activeJobs[idx] = b }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                var done = b
                done.status = .success
                done.logPreview = "Cloud build finished"
                DispatchQueue.main.async {
                    if let idx = self.activeJobs.firstIndex(where: { $0.id == build.id }) { self.activeJobs[idx] = done }
                                        completion(.success(done))
                }
            }
        }
    }

        private func buildWorkflowYAML(projectName: String) -> String {
                return """
name: Build

on:
    push:
        branches: [ main ]
    workflow_dispatch:

jobs:
    build:
        runs-on: macos-latest
        steps:
            - uses: actions/checkout@v4
            - name: Install Swift
                uses: fwal/setup-swift@v2
                with:
                    swift-version: '5.8'
            - name: Build
                run: swift build --disable-sandbox
            - name: Run tests
                run: swift test --disable-sandbox
"""
        }
}
