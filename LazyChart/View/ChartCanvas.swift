import SwiftUI
import Charts

/// Renders a ChartDoc. Reused for on-screen preview and for image export.
struct ChartCanvas: View {
    let doc: ChartDoc
    var forExport: Bool = false

    private var points: [ChartDoc.Point] { doc.points() }
    private var total: Double { (doc.series.first?.values ?? []).reduce(0, +) }

    private var seriesRange: [Color] {
        doc.series.indices.map { Palette.color(doc.paletteIndex, $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: forExport ? 18 : 12) {
            if forExport && !doc.title.isEmpty {
                Text(doc.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
            }
            chart
                .frame(maxWidth: .infinity)
            if doc.showLegend {
                legend
            }
            if forExport {
                HStack {
                    Spacer()
                    Text(L.appTitle)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.subtle)
                }
            }
        }
        .padding(forExport ? 28 : 0)
        .background(forExport ? Theme.card : Color.clear)
    }

    @ViewBuilder
    private var chart: some View {
        switch doc.kind {
        case .bar: barChart
        case .line: lineChart
        case .pie: pieChart
        }
    }

    // MARK: Bar

    private var barChart: some View {
        Chart(points) { p in
            BarMark(
                x: .value(L.label, p.label),
                y: .value(L.value, p.value)
            )
            .position(by: .value(L.series, p.series))
            .foregroundStyle(color(for: p))
            .cornerRadius(4)
            .annotation(position: .top) {
                if doc.showValues {
                    Text(p.value.chartLabel)
                        .font(.system(size: forExport ? 13 : 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.subtle)
                }
            }
        }
        .chartLegend(.hidden)
        .modifier(AxisStyle(showGrid: doc.showGrid, forExport: forExport))
        .frame(height: chartHeight)
    }

    // MARK: Line

    private var lineChart: some View {
        Chart(points) { p in
            LineMark(
                x: .value(L.label, p.label),
                y: .value(L.value, p.value)
            )
            .foregroundStyle(by: .value(L.series, p.series))
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: forExport ? 3 : 2))
            PointMark(
                x: .value(L.label, p.label),
                y: .value(L.value, p.value)
            )
            .foregroundStyle(by: .value(L.series, p.series))
            .symbolSize(forExport ? 60 : 30)
            .annotation(position: .top) {
                if doc.showValues {
                    Text(p.value.chartLabel)
                        .font(.system(size: forExport ? 13 : 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.subtle)
                }
            }
        }
        .chartForegroundStyleScale(domain: doc.seriesNames, range: seriesRange)
        .chartLegend(.hidden)
        .modifier(AxisStyle(showGrid: doc.showGrid, forExport: forExport))
        .frame(height: chartHeight)
    }

    // MARK: Pie

    private var pieChart: some View {
        Chart(points) { p in
            SectorMark(
                angle: .value(L.value, p.value),
                innerRadius: .ratio(0.55),
                angularInset: 1.5
            )
            .cornerRadius(4)
            .foregroundStyle(Palette.color(doc.paletteIndex, p.colorIndex))
            .annotation(position: .overlay) {
                if doc.showValues && total > 0 {
                    Text("\(Int((p.value / total * 100).rounded()))%")
                        .font(.system(size: forExport ? 14 : 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .chartLegend(.hidden)
        .frame(height: chartHeight)
    }

    // MARK: Legend

    private var legend: some View {
        let items: [(String, Color)] = doc.kind == .pie
            ? doc.labels.enumerated().map { ($0.element, Palette.color(doc.paletteIndex, $0.offset)) }
            : doc.series.enumerated().map { ($0.element.name, Palette.color(doc.paletteIndex, $0.offset)) }
        return FlowLayout(spacing: 10, runSpacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.1)
                        .frame(width: 12, height: 12)
                    Text(item.0)
                        .font(.system(size: forExport ? 15 : 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
    }

    // MARK: Helpers

    private var chartHeight: CGFloat { forExport ? 420 : 260 }

    private func color(for p: ChartDoc.Point) -> Color {
        if doc.series.count <= 1 {
            let idx = doc.labels.firstIndex(of: p.label) ?? 0
            return Palette.color(doc.paletteIndex, idx)
        }
        let idx = doc.series.firstIndex(where: { $0.name == p.series }) ?? 0
        return Palette.color(doc.paletteIndex, idx)
    }
}

/// Applies axis label styling and optional grid lines.
private struct AxisStyle: ViewModifier {
    let showGrid: Bool
    let forExport: Bool
    func body(content: Content) -> some View {
        content
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: forExport ? 14 : 10, design: .rounded))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    if showGrid { AxisGridLine() }
                    AxisValueLabel()
                        .font(.system(size: forExport ? 14 : 10, design: .rounded))
                }
            }
    }
}

/// Simple wrapping flow layout for legend chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var runSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + runSpacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.minX + maxWidth && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + runSpacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
