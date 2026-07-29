import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var selectedTab: AppTab = .dashboard
    @Published var githubConnected = true
    @Published var appleSigned = true
    @Published var certificateStatus: CertificateStatus = .active
    @Published var recentBuilds: [BuildJob] = [
        .init(id: "build-001", name: "CanvasKit", status: .succeeded, updatedAt: Date().addingTimeInterval(-1800), platform: "iPadOS"),
        .init(id: "build-002", name: "Pulse Notes", status: .building, updatedAt: Date().addingTimeInterval(-600), platform: "iPadOS"),
        .init(id: "build-003", name: "Flow Studio", status: .queued, updatedAt: Date().addingTimeInterval(-120), platform: "iPadOS")
    ]
    @Published var sources: [RepositorySource] = [
        .init(name: "SideStore Community", url: "https://side.store/sources.json", isEnabled: true),
        .init(name: "AltStore Test", url: "https://example.com/test.json", isEnabled: false)
    ]

    func connectGitHub() {
        githubConnected.toggle()
    }

    func refreshCertificates() {
        certificateStatus = .active
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case playgrounds = "Playgrounds"
    case sources = "Sources"
    case settings = "Settings"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .playgrounds: return "play.circle"
        case .sources: return "globe"
        case .settings: return "gearshape"
        }
    }
}

enum CertificateStatus: String, CaseIterable {
    case active = "Active"
    case refreshing = "Refreshing"
    case expired = "Expired"
}

struct BuildJob: Identifiable, Hashable {
    let id: String
    let name: String
    let status: BuildStatus
    let updatedAt: Date
    let platform: String
}

enum BuildStatus: String, CaseIterable {
    case succeeded
    case building
    case queued
    case failed

    var color: Color {
        switch self {
        case .succeeded: return .green
        case .building: return .blue
        case .queued: return .orange
        case .failed: return .red
        }
    }
}

struct RepositorySource: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: String
    let isEnabled: Bool
}
