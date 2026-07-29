import Foundation

public struct Source: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var url: URL
    public var enabled: Bool

    public init(id: UUID = UUID(), name: String, url: URL, enabled: Bool = true) {
        self.id = id
        self.name = name
        self.url = url
        self.enabled = enabled
    }
}
