import Foundation
import Combine

final class SourceService: ObservableObject {
    @Published private(set) var sources: [Source] = []

    init(initial: [Source] = []) {
        self.sources = initial
    }

    func addSource(name: String, urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let s = Source(name: name, url: url)
        sources.append(s)
        PersistenceService.saveSources(sources)
    }

    func toggle(_ source: Source) {
        guard let idx = sources.firstIndex(of: source) else { return }
        sources[idx].enabled.toggle()
        PersistenceService.saveSources(sources)
    }

    static func sampleService() -> SourceService {
        let items = [
            Source(name: "Official Repo", url: URL(string: "https://apps.example.org/sources.json")!),
            Source(name: "Community", url: URL(string: "https://community.example.org/sources.json")!, enabled: true),
        ]
        return SourceService(initial: items)
    }
}
