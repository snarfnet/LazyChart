import SwiftUI

/// Editable spreadsheet-like grid: first column is the row label,
/// remaining columns are numeric series (with editable header names).
struct DataTableView: View {
    @Binding var doc: ChartDoc

    private let labelWidth: CGFloat = 96
    private let cellWidth: CGFloat = 84

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 6) {
                headerRow
                ForEach(doc.labels.indices, id: \.self) { row in
                    dataRow(row)
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 6) {
            Text(L.label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.subtle)
                .frame(width: labelWidth, alignment: .leading)
            ForEach(doc.series.indices, id: \.self) { s in
                TextField(L.series, text: Binding(
                    get: { doc.series[s].name },
                    set: { doc.series[s].name = $0 }
                ))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.accent)
                .multilineTextAlignment(.center)
                .frame(width: cellWidth)
                if doc.series.count > 1 {
                    Button {
                        doc.series.remove(at: s)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.subtle.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dataRow(_ row: Int) -> some View {
        HStack(spacing: 6) {
            TextField(L.label, text: Binding(
                get: { doc.labels[safe: row] ?? "" },
                set: { if doc.labels.indices.contains(row) { doc.labels[row] = $0 } }
            ))
            .font(.system(size: 14, design: .rounded))
            .frame(width: labelWidth, alignment: .leading)
            .padding(.horizontal, 8).padding(.vertical, 7)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            ForEach(doc.series.indices, id: \.self) { s in
                TextField("0", text: Binding(
                    get: {
                        guard doc.series[s].values.indices.contains(row) else { return "" }
                        return doc.series[s].values[row].chartLabel
                    },
                    set: { newValue in
                        let v = Double(newValue.replacingOccurrences(of: ",", with: "")) ?? 0
                        if doc.series[s].values.indices.contains(row) {
                            doc.series[s].values[row] = v
                        }
                    }
                ))
                .keyboardType(.numbersAndPunctuation)
                .font(.system(size: 14, design: .rounded))
                .multilineTextAlignment(.trailing)
                .frame(width: cellWidth)
                .padding(.horizontal, 8).padding(.vertical, 7)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                if doc.series.count > 1 {
                    Spacer().frame(width: 20)
                }
            }

            Button {
                removeRow(row)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.red.opacity(0.6))
            }
            .buttonStyle(.plain)
            .disabled(doc.labels.count <= 1)
            .opacity(doc.labels.count <= 1 ? 0.3 : 1)
        }
    }

    private func removeRow(_ row: Int) {
        guard doc.labels.count > 1 else { return }
        if doc.labels.indices.contains(row) { doc.labels.remove(at: row) }
        for i in doc.series.indices where doc.series[i].values.indices.contains(row) {
            doc.series[i].values.remove(at: row)
        }
    }
}
