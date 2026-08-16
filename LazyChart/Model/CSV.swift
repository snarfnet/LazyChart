import Foundation

/// Parses tabular text (CSV / TSV / pasted spreadsheet rows) into a ChartDoc's data.
enum TableParser {
    struct Parsed {
        var labels: [String]
        var series: [Series]
    }

    /// Detects delimiter, reads an optional header row, and builds labels + numeric series.
    static func parse(_ raw: String, title: String? = nil) -> Parsed? {
        let text = raw.replacingOccurrences(of: "\r\n", with: "\n")
                      .replacingOccurrences(of: "\r", with: "\n")
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        guard !lines.isEmpty else { return nil }

        let delim: Character = detectDelimiter(lines)
        var rows = lines.map { splitRow($0, delim: delim) }
        let width = rows.map { $0.count }.max() ?? 0
        guard width >= 1 else { return nil }
        rows = rows.map { r in r + Array(repeating: "", count: max(0, width - r.count)) }

        // Header row if the cells (except first) are non-numeric.
        var headerNames: [String]? = nil
        if let first = rows.first {
            let dataCells = Array(first.dropFirst())
            let anyNumeric = dataCells.contains { toDouble($0) != nil && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            if !anyNumeric && dataCells.contains(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
                headerNames = Array(first.dropFirst())
                rows.removeFirst()
            }
        }
        guard !rows.isEmpty else { return nil }

        let seriesCount = width - 1
        if seriesCount <= 0 {
            // single column of numbers -> auto labels
            var values: [Double] = []
            var labels: [String] = []
            for (i, r) in rows.enumerated() {
                if let v = toDouble(r[0]) {
                    values.append(v)
                    labels.append("\(i + 1)")
                }
            }
            guard !values.isEmpty else { return nil }
            return Parsed(labels: labels, series: [Series(name: L.seriesDefault, values: values)])
        }

        var labels: [String] = []
        var seriesValues: [[Double]] = Array(repeating: [], count: seriesCount)
        for r in rows {
            let label = r[0].trimmingCharacters(in: .whitespaces)
            labels.append(label.isEmpty ? "\(labels.count + 1)" : label)
            for s in 0..<seriesCount {
                seriesValues[s].append(toDouble(r[s + 1]) ?? 0)
            }
        }

        var series: [Series] = []
        for s in 0..<seriesCount {
            let name = headerNames?[safe: s]?.trimmingCharacters(in: .whitespaces)
            let finalName = (name?.isEmpty == false) ? name! : (seriesCount == 1 ? L.seriesDefault : "\(L.series) \(s + 1)")
            series.append(Series(name: finalName, values: seriesValues[s]))
        }
        return Parsed(labels: labels, series: series)
    }

    private static func detectDelimiter(_ lines: [String]) -> Character {
        let sample = lines.prefix(5).joined(separator: "\n")
        let tabs = sample.filter { $0 == "\t" }.count
        let commas = sample.filter { $0 == "," }.count
        let semis = sample.filter { $0 == ";" }.count
        if tabs >= commas && tabs >= semis && tabs > 0 { return "\t" }
        if semis > commas && semis > 0 { return ";" }
        return ","
    }

    /// Splits a single row, honoring simple double-quoted fields.
    private static func splitRow(_ line: String, delim: Character) -> [String] {
        var result: [String] = []
        var field = ""
        var inQuotes = false
        for ch in line {
            if ch == "\"" {
                inQuotes.toggle()
            } else if ch == delim && !inQuotes {
                result.append(field)
                field = ""
            } else {
                field.append(ch)
            }
        }
        result.append(field)
        return result
    }

    private static func toDouble(_ s: String) -> Double? {
        let cleaned = s.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "%", with: "")
        if cleaned.isEmpty { return nil }
        return Double(cleaned)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
