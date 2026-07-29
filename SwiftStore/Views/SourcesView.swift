import SwiftUI

struct SourcesView: View {
    @EnvironmentObject var sourceService: SourceService
    @State private var newName = ""
    @State private var newURL = ""

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Repositories")) {
                    ForEach(sourceService.sources) { source in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(source.name).font(.headline)
                                Text(source.url.absoluteString).font(.caption)
                            }
                            Spacer()
                            Toggle(isOn: Binding(get: { source.enabled }, set: { _ in sourceService.toggle(source) })) {
                                EmptyView()
                            }
                            .labelsHidden()
                        }
                    }
                }
                Section(header: Text("Add Source")) {
                    TextField("Name", text: $newName)
                    TextField("https://example.org/sources.json", text: $newURL)
                    Button(action: {
                        sourceService.addSource(name: newName, urlString: newURL)
                        newName = ""
                        newURL = ""
                    }) {
                        Label("Add Repository", systemImage: "plus")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Sources")
        }
    }
}
import SwiftUI

struct SourcesView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Sources & Community Apps")
                    .font(.title2).bold()
                Text("Add repositories in the standard sources.json format and browse community apps.")
                    .foregroundStyle(.secondary)

                ForEach(appModel.sources) { source in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(source.name)
                                .font(.headline)
                            Text(source.url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: .constant(source.isEnabled))
                            .labelsHidden()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Sources")
    }
}
