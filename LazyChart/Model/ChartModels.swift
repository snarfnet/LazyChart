import SwiftUI

enum ChartKind: String, Codable, CaseIterable, Identifiable {
    case bar, line, pie
    var id: String { rawValue }
    var name: String {
        switch self {
        case .bar: return L.bar
        case .line: return L.line
        case .pie: return L.pie
        }
    }
    var symbol: String {
        switch self {
        case .bar: return "chart.bar.fill"
        case .line: return "chart.xyaxis.line"
        case .pie: return "chart.pie.fill"
        }
    }
}

/// One column of numbers with a name (e.g. "Sales").
struct Series: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var values: [Double]
}

/// A saved chart document.
struct ChartDoc: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var kind: ChartKind
    var labels: [String]        // category labels, one per row
    var series: [Series]        // one or more numeric columns
    var paletteIndex: Int
    var showValues: Bool
    var showLegend: Bool
    var showGrid: Bool
    var updatedAt: Date

    init(id: UUID = UUID(),
         title: String,
         kind: ChartKind = .bar,
         labels: [String],
         series: [Series],
         paletteIndex: Int = 0,
         showValues: Bool = true,
         showLegend: Bool = true,
         showGrid: Bool = true,
         updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.kind = kind
        self.labels = labels
        self.series = series
        self.paletteIndex = paletteIndex
        self.showValues = showValues
        self.showLegend = showLegend
        self.showGrid = showGrid
        self.updatedAt = updatedAt
    }

    var rowCount: Int { labels.count }

    /// Flattened points for Swift Charts.
    struct Point: Identifiable {
        let id = UUID()
        let label: String
        let series: String
        let value: Double
        let colorIndex: Int
    }

    /// For bar/line: point per (row, series). For pie: point per row using first series.
    func points() -> [Point] {
        var out: [Point] = []
        if kind == .pie {
            guard let first = series.first else { return [] }
            for (i, label) in labels.enumerated() where i < first.values.count {
                out.append(Point(label: label, series: first.name,
                                 value: first.values[i], colorIndex: i))
            }
        } else {
            for (si, s) in series.enumerated() {
                for (i, label) in labels.enumerated() where i < s.values.count {
                    out.append(Point(label: label, series: s.name,
                                     value: s.values[i], colorIndex: si))
                }
            }
        }
        return out
    }

    var seriesNames: [String] { series.map { $0.name } }

    static func sample() -> ChartDoc {
        let labels = L.isJa ? ["1月", "2月", "3月", "4月", "5月"] : ["Jan", "Feb", "Mar", "Apr", "May"]
        let s = Series(name: L.seriesDefault, values: [42, 55, 48, 73, 66])
        return ChartDoc(title: L.sampleTitle, kind: .bar, labels: labels, series: [s])
    }

    static func empty() -> ChartDoc {
        let labels = ["A", "B", "C"]
        let s = Series(name: L.seriesDefault, values: [10, 20, 15])
        return ChartDoc(title: L.untitled, kind: .bar, labels: labels, series: [s])
    }

    /// Populated demo charts used only when capturing App Store screenshots.
    static func demoSet() -> [ChartDoc] {
        let bar = ChartDoc(
            title: L.t("店舗別の売上", "Sales by Store"),
            kind: .bar,
            labels: L.isJa ? ["4月", "5月", "6月", "7月", "8月"] : ["Apr", "May", "Jun", "Jul", "Aug"],
            series: [
                Series(name: L.t("新宿店", "Shinjuku"), values: [42, 58, 50, 74, 66]),
                Series(name: L.t("渋谷店", "Shibuya"), values: [30, 44, 62, 55, 71]),
            ],
            paletteIndex: 0)
        let pie = ChartDoc(
            title: L.t("売上の内訳", "Revenue Share"),
            kind: .pie,
            labels: L.isJa ? ["食品", "雑貨", "衣料", "家電"] : ["Food", "Goods", "Apparel", "Home"],
            series: [Series(name: L.t("割合", "Share"), values: [42, 26, 20, 12])],
            paletteIndex: 2)
        let line = ChartDoc(
            title: L.t("会員数の推移", "Member Growth"),
            kind: .line,
            labels: L.isJa ? ["1月", "2月", "3月", "4月", "5月", "6月"] : ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
            series: [Series(name: L.t("会員数", "Members"), values: [120, 180, 240, 300, 360, 430])],
            paletteIndex: 1)
        return [bar, pie, line]
    }
}

/// Color palettes. Each is an ordered set of pleasant colors.
enum Palette {
    static let all: [[Color]] = [
        // Fresh
        [rgb(0x4C6EF5), rgb(0x51CF66), rgb(0xFFD43B), rgb(0xFF6B6B), rgb(0x845EF7),
         rgb(0x22B8CF), rgb(0xFF922B), rgb(0xF06595)],
        // Ocean
        [rgb(0x1C7ED6), rgb(0x1098AD), rgb(0x0CA678), rgb(0x66A80F), rgb(0x74C0FC),
         rgb(0x3BC9DB), rgb(0x38D9A9), rgb(0xA9E34B)],
        // Sunset
        [rgb(0xFF6B6B), rgb(0xFF922B), rgb(0xFCC419), rgb(0xF06595), rgb(0xE64980),
         rgb(0xFFA94D), rgb(0xFFE066), rgb(0xFAA2C1)],
        // Muted
        [rgb(0x495057), rgb(0x868E96), rgb(0xADB5BD), rgb(0x5C7CFA), rgb(0x748FFC),
         rgb(0x63E6BE), rgb(0xFFC078), rgb(0xFFA8A8)],
        // Mono blue
        [rgb(0x0B3D91), rgb(0x1C64C7), rgb(0x3B82F6), rgb(0x60A5FA), rgb(0x93C5FD),
         rgb(0xBFDBFE), rgb(0x1E40AF), rgb(0x2563EB)],
    ]

    static let names: [String] = L.isJa
        ? ["フレッシュ", "オーシャン", "サンセット", "ミュート", "ブルー"]
        : ["Fresh", "Ocean", "Sunset", "Muted", "Blue"]

    static func colors(_ index: Int) -> [Color] {
        all[max(0, min(index, all.count - 1))]
    }

    static func color(_ paletteIndex: Int, _ colorIndex: Int) -> Color {
        let c = colors(paletteIndex)
        return c[((colorIndex % c.count) + c.count) % c.count]
    }

    private static func rgb(_ hex: Int) -> Color {
        Color(red: Double((hex >> 16) & 0xFF) / 255.0,
              green: Double((hex >> 8) & 0xFF) / 255.0,
              blue: Double(hex & 0xFF) / 255.0)
    }
}

extension Double {
    /// Compact display: drops trailing .0, keeps up to 2 decimals.
    var chartLabel: String {
        if self == rounded() { return String(Int(self)) }
        return String(format: "%.2f", self)
    }
}
