import Foundation

final class PersistenceService {
    static let buildsFile = "builds.json"
    static let sourcesFile = "sources.json"

    static func applicationSupportDirectory() -> URL? {
        let fm = FileManager.default
        if let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let dir = url.appendingPathComponent("SwiftStore", isDirectory: true)
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
            return dir
        }
        return nil
    }

    static func saveBuilds(_ builds: [Build]) {
        guard let dir = applicationSupportDirectory() else { return }
        let url = dir.appendingPathComponent(buildsFile)
        do {
            let data = try JSONEncoder().encode(builds)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("Failed save builds: \(error)")
        }
    }

    static func loadBuilds() -> [Build]? {
        guard let dir = applicationSupportDirectory() else { return nil }
        let url = dir.appendingPathComponent(buildsFile)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Build].self, from: data)
    }

    static func saveSources(_ sources: [Source]) {
        guard let dir = applicationSupportDirectory() else { return }
        let url = dir.appendingPathComponent(sourcesFile)
        do {
            let data = try JSONEncoder().encode(sources)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("Failed save sources: \(error)")
        }
    }

    static func loadSources() -> [Source]? {
        guard let dir = applicationSupportDirectory() else { return nil }
        let url = dir.appendingPathComponent(sourcesFile)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Source].self, from: data)
    }
}
