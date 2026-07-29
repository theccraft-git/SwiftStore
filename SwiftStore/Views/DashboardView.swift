import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var buildService: BuildService

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Active Builds")) {
                    ForEach(buildService.builds) { build in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(build.name).font(.headline)
                                Text(build.logPreview ?? build.status.rawValue.capitalized).font(.caption)
                            }
                            Spacer()
                            StatusBadge(status: build.status)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { buildService.addBuild(named: "ManualBuild-") }) {
                        Label("New Build", systemImage: "plus")
                    }
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: BuildStatus
    var color: Color {
        switch status {
        case .queued: return .gray
        case .running: return .blue
        case .success: return .green
        case .failed: return .red
        }
    }
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption).bold()
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.15)))
            .foregroundColor(color)
    }
}
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeaderCardView()

                HStack(spacing: 16) {
                    StatusCard(title: "GitHub", value: appModel.githubConnected ? "Connected" : "Connect", icon: "network")
                    StatusCard(title: "Signing", value: appModel.appleSigned ? "Ready" : "Needs setup", icon: "signature")
                    StatusCard(title: "Certificates", value: appModel.certificateStatus.rawValue, icon: "lock.shield")
                }
                .frame(maxWidth: .infinity)

                Section(header: Text("Recent Builds")) {
                    ForEach(appModel.recentBuilds) { build in
                        BuildRow(build: build)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
    }
}

struct HeaderCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cloud sideloading, signing, and repository management")
                .font(.title2).bold()
            Text("SwiftStore orchestrates your builds, certificates, and app sources in one place.")
                .foregroundStyle(.secondary)
            HStack {
                Button("Create Build") { }
                    .buttonStyle(.borderedProminent)
                Button("Refresh Certificates") { }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct BuildRow: View {
    let build: BuildJob

    var body: some View {
        HStack {
            Circle()
                .fill(build.status.color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading) {
                Text(build.name)
                    .font(.headline)
                Text(build.platform)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(build.updatedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
