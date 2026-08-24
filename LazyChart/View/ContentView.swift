import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var editing: ChartDoc?
    @State private var renaming: ChartDoc?
    @State private var renameText = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.charts.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle(L.appTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let doc = ChartDoc.empty()
                        store.upsert(doc)
                        editing = doc
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .fullScreenCover(item: $editing) { doc in
                EditorView(doc: doc)
                    .environmentObject(store)
            }
            .onAppear {
                if let kind = ScreenshotMode.autoEditKind,
                   let doc = store.charts.first(where: { $0.kind == kind }) {
                    editing = doc
                }
            }
            .alert(L.rename, isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
                TextField(L.titlePlaceholder, text: $renameText)
                Button(L.cancel, role: .cancel) { renaming = nil }
                Button(L.save) {
                    if var d = renaming {
                        d.title = renameText.isEmpty ? L.untitled : renameText
                        store.upsert(d)
                    }
                    renaming = nil
                }
            }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(store.charts) { doc in
                    Button {
                        editing = doc
                    } label: {
                        ChartRow(doc: doc)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button { editing = doc } label: { Label(L.edit, systemImage: "pencil") }
                        Button {
                            renameText = doc.title
                            renaming = doc
                        } label: { Label(L.rename, systemImage: "textformat") }
                        Button { store.duplicate(doc) } label: { Label(L.duplicate, systemImage: "plus.square.on.square") }
                        Button(role: .destructive) { store.delete(doc) } label: { Label(L.delete, systemImage: "trash") }
                    }
                }
            }
            .padding(16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 54))
                .foregroundStyle(Theme.accent.opacity(0.7))
            Text(L.noCharts)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text(L.noChartsHint)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.subtle)
            Button {
                let doc = ChartDoc.empty()
                store.upsert(doc)
                editing = doc
            } label: {
                Label(L.newChart, systemImage: "plus")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 22).padding(.vertical, 12)
                    .background(Theme.accent, in: Capsule())
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)
        }
        .padding(40)
    }
}

private struct ChartRow: View {
    let doc: ChartDoc

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: doc.kind.symbol)
                    .foregroundStyle(Theme.accent)
                Text(doc.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Spacer()
                Text(L.shortDate(doc.updatedAt))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Theme.subtle)
            }
            ChartCanvas(doc: doc)
                .frame(height: 200)
                .allowsHitTesting(false)
        }
        .padding(16)
        .cardStyle()
    }
}
