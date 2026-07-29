import Foundation
import Combine

final class BuildService: ObservableObject {
    @Published private(set) var builds: [Build] = []

    init(initial: [Build] = []) {
        self.builds = initial
    }

    func addBuild(named name: String) {
        let build = Build(name: name, status: .queued)
        builds.insert(build, at: 0)
        PersistenceService.saveBuilds(builds)
        // simulate work
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            self.update(build.id) { $0.status = .running }
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                let success = Bool.random()
                self.update(build.id) { $0.status = success ? .success : .failed }
                self.update(build.id) { $0.logPreview = success ? "Build completed" : "Error: compile failed" }
                PersistenceService.saveBuilds(self.builds)
            }
        }
    }

    func update(_ id: UUID, mutation: @escaping (inout Build) -> Void) {
        DispatchQueue.main.async {
            guard let idx = self.builds.firstIndex(where: { $0.id == id }) else { return }
            var copy = self.builds[idx]
            mutation(&copy)
            self.builds[idx] = copy
            PersistenceService.saveBuilds(self.builds)
        }
    }

    static func sampleService() -> BuildService {
        let items = [
            Build(name: "ExampleApp", status: .success, logPreview: "Signed and packaged"),
            Build(name: "PlaygroundDemo", status: .failed, logPreview: "Missing dependency"),
        ]
        return BuildService(initial: items)
    }
}
