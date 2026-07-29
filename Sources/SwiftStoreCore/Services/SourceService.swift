import Foundation
import Combine

public final class SourceService: ObservableObject {
    @Published public private(set) var sources: [Source] = []

    public init(initial: [Source] = []) {
        self.sources = initial
    }

    public func addSource(name: String, urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let s = Source(name: name, url: url)
        sources.append(s)
    }

    public func toggle(_ source: Source) {
        guard let idx = sources.firstIndex(of: source) else { return }
        sources[idx].enabled.toggle()
    }
}
