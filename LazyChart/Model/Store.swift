import SwiftUI
import Combine

/// Persists charts as a single JSON file in the Documents directory.
final class Store: ObservableObject {
    @Published var charts: [ChartDoc] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("charts.json")
    }()

    init() {
        if ScreenshotMode.isActive {
            charts = ChartDoc.demoSet()
            return
        }
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ChartDoc].self, from: data) else {
            charts = [ChartDoc.sample()]
            save()
            return
        }
        charts = decoded.sorted { $0.updatedAt > $1.updatedAt }
    }

    func save() {
        let sorted = charts.sorted { $0.updatedAt > $1.updatedAt }
        charts = sorted
        if let data = try? JSONEncoder().encode(sorted) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func upsert(_ doc: ChartDoc) {
        var d = doc
        d.updatedAt = Date()
        if let idx = charts.firstIndex(where: { $0.id == d.id }) {
            charts[idx] = d
        } else {
            charts.append(d)
        }
        save()
    }

    func delete(_ doc: ChartDoc) {
        charts.removeAll { $0.id == doc.id }
        save()
    }

    func duplicate(_ doc: ChartDoc) {
        var copy = doc
        copy.id = UUID()
        copy.title = doc.title + L.t("（コピー）", " (copy)")
        copy.updatedAt = Date()
        charts.append(copy)
        save()
    }
}
