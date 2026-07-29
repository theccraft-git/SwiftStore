import Foundation
import Combine

public final class BuildService: ObservableObject {
    @Published public private(set) var builds: [Build] = []

    public init(initial: [Build] = []) {
        self.builds = initial
    }

    public func addBuild(named name: String) {
        let build = Build(name: name, status: .queued)
        builds.insert(build, at: 0)
        // simulate work
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            self.update(build.id) { $0.status = .running }
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                let success = Bool.random()
                self.update(build.id) { $0.status = success ? .success : .failed }
                self.update(build.id) { $0.logPreview = success ? "Build completed" : "Error: compile failed" }
            }
        }
    }

    public func update(_ id: UUID, mutation: @escaping (inout Build) -> Void) {
        DispatchQueue.main.async {
            guard let idx = self.builds.firstIndex(where: { $0.id == id }) else { return }
            var copy = self.builds[idx]
            mutation(&copy)
            self.builds[idx] = copy
        }
    }
}
