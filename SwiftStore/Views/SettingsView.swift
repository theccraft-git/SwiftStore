import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var github: GitHubService
    @State private var appleID = ""
    @State private var showingOAuth = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Accounts")) {
                    if let token = github.token {
                        Text("GitHub: connected")
                        Text("Token: \(token.prefix(8))…").font(.caption)
                        Button("Disconnect GitHub") { github.token = nil }
                    } else {
                        Button("Connect GitHub") { github.startOAuth() }
                    }
                    TextField("Apple ID (optional)", text: $appleID)
                }
                Section(header: Text("Certificates")) {
                    Text("Local loopback signing status: Not configured")
                        .font(.footnote)
                }
                Section(header: Text("About")) {
                    Text("SwiftStore — personal cloud builder and sideloader.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Account & Certificate Settings")
                    .font(.title2).bold()
                Text("Manage GitHub authentication, Apple ID state, and local signing readiness.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Label("GitHub OAuth", systemImage: appModel.githubConnected ? "checkmark.seal.fill" : "person.badge.plus")
                    Label("Apple ID", systemImage: appModel.appleSigned ? "checkmark.seal.fill" : "person.crop.circle")
                    Label("Certificate Status", systemImage: "lock.shield")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button("Refresh Certificates") {
                    appModel.refreshCertificates()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Settings")
    }
}
