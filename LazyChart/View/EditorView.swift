import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State var doc: ChartDoc

    @State private var showImporter = false
    @State private var showPaste = false
    @State private var pasteText = ""
    @State private var shareImage: ShareableImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    preview
                    typePicker
                    dataSection
                    appearanceSection
                    importSection
                }
                .padding(16)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle(L.data)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L.done) { save(); dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                        shareImage = renderImage()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .onChange(of: doc) { _, _ in save() }
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [.commaSeparatedText, .plainText, UTType("public.comma-separated-values-text") ?? .plainText, .text],
                          allowsMultipleSelection: false) { result in
                handleImport(result)
            }
            .sheet(isPresented: $showPaste) { pasteSheet }
            .sheet(item: $shareImage) { item in
                ShareSheet(activityItems: [item.image])
            }
        }
    }

    // MARK: Preview

    private var preview: some View {
        VStack(spacing: 12) {
            TextField(L.titlePlaceholder, text: $doc.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.ink)
            ChartCanvas(doc: doc)
                .padding(.top, 4)
        }
        .padding(18)
        .cardStyle()
    }

    // MARK: Chart type

    private var typePicker: some View {
        HStack(spacing: 10) {
            ForEach(ChartKind.allCases) { kind in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { doc.kind = kind }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: kind.symbol)
                            .font(.system(size: 20))
                        Text(kind.name)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(doc.kind == kind ? Theme.accent : Theme.card)
                    .foregroundStyle(doc.kind == kind ? .white : Theme.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Data table

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(L.data, systemImage: "tablecells")
            DataTableView(doc: $doc)
            HStack(spacing: 12) {
                smallButton(L.addRow, systemImage: "plus") { addRow() }
                if doc.kind != .pie {
                    smallButton(L.addSeries, systemImage: "plus.rectangle.on.rectangle") { addSeries() }
                }
                Spacer()
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(L.appearance, systemImage: "paintpalette")
            Text(L.palette)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.subtle)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Palette.all.indices, id: \.self) { i in
                        Button { doc.paletteIndex = i } label: {
                            HStack(spacing: 3) {
                                ForEach(0..<4, id: \.self) { c in
                                    Circle().fill(Palette.color(i, c)).frame(width: 14, height: 14)
                                }
                            }
                            .padding(8)
                            .background(Theme.bg)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(doc.paletteIndex == i ? Theme.accent : .clear, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
            Toggle(L.showValues, isOn: $doc.showValues)
            Toggle(L.showLegend, isOn: $doc.showLegend)
            if doc.kind != .pie {
                Toggle(L.showGrid, isOn: $doc.showGrid)
            }
        }
        .font(.system(size: 15, design: .rounded))
        .tint(Theme.accent)
        .padding(16)
        .cardStyle()
    }

    // MARK: Import

    private var importSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(L.importCSV, systemImage: "square.and.arrow.down")
            HStack(spacing: 12) {
                smallButton(L.importCSV, systemImage: "doc.text") { showImporter = true }
                smallButton(L.paste, systemImage: "doc.on.clipboard") {
                    pasteText = UIPasteboard.general.string ?? ""
                    showPaste = true
                }
                Spacer()
            }
        }
        .padding(16)
        .cardStyle()
    }

    private var pasteSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(L.pasteHint)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Theme.subtle)
                TextEditor(text: $pasteText)
                    .font(.system(size: 15, design: .monospaced))
                    .padding(8)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
            .navigationTitle(L.paste)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L.cancel) { showPaste = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L.load) {
                        applyParsed(pasteText)
                        showPaste = false
                    }.fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Actions

    private func addRow() {
        doc.labels.append("\(doc.labels.count + 1)")
        for i in doc.series.indices { doc.series[i].values.append(0) }
    }

    private func addSeries() {
        let name = doc.series.count == 0 ? L.seriesDefault : "\(L.series) \(doc.series.count + 1)"
        doc.series.append(Series(name: name, values: Array(repeating: 0, count: doc.labels.count)))
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        let needsStop = url.startAccessingSecurityScopedResource()
        defer { if needsStop { url.stopAccessingSecurityScopedResource() } }
        guard let raw = try? String(contentsOf: url, encoding: .utf8)
                ?? (try? String(contentsOf: url, encoding: .shiftJIS)) else { return }
        applyParsed(raw, fallbackTitle: url.deletingPathExtension().lastPathComponent)
    }

    private func applyParsed(_ raw: String, fallbackTitle: String? = nil) {
        guard let parsed = TableParser.parse(raw) else { return }
        doc.labels = parsed.labels
        doc.series = parsed.series
        if doc.title.isEmpty || doc.title == L.untitled, let t = fallbackTitle, !t.isEmpty {
            doc.title = t
        }
        save()
    }

    private func save() { store.upsert(doc) }

    private func renderImage() -> ShareableImage {
        let renderer = ImageRenderer(content:
            ChartCanvas(doc: doc, forExport: true)
                .frame(width: 900)
                .environmentObject(store)
        )
        renderer.scale = 3
        let image = renderer.uiImage ?? UIImage()
        return ShareableImage(image: image)
    }

    // MARK: Small UI helpers

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).foregroundStyle(Theme.accent)
            Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(Theme.ink)
        }
    }

    private func smallButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Theme.accent.opacity(0.12))
                .foregroundStyle(Theme.accent)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
