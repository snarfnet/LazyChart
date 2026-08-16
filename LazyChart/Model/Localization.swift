import Foundation

/// Minimal bilingual helper. Picks Japanese when the device prefers Japanese.
enum L {
    static let isJa: Bool = {
        let code = Locale.preferredLanguages.first ?? "en"
        return code.hasPrefix("ja")
    }()

    static func t(_ ja: String, _ en: String) -> String { isJa ? ja : en }

    static var appTitle: String { t("ズボラグラフ", "Lazy Chart") }
    static var myCharts: String { t("マイグラフ", "My Charts") }
    static var newChart: String { t("新しいグラフ", "New Chart") }
    static var noCharts: String { t("まだグラフがありません", "No charts yet") }
    static var noChartsHint: String { t("右上の＋から数字を入れるだけ。", "Tap ＋ and just type your numbers.") }

    static var untitled: String { t("無題のグラフ", "Untitled Chart") }
    static var title: String { t("タイトル", "Title") }
    static var titlePlaceholder: String { t("グラフのタイトル", "Chart title") }

    static var data: String { t("データ", "Data") }
    static var chartType: String { t("グラフの種類", "Chart Type") }
    static var bar: String { t("棒グラフ", "Bar") }
    static var line: String { t("折れ線", "Line") }
    static var pie: String { t("円グラフ", "Pie") }

    static var label: String { t("ラベル", "Label") }
    static var value: String { t("値", "Value") }
    static var addRow: String { t("行を追加", "Add row") }
    static var addSeries: String { t("系列を追加", "Add series") }
    static var series: String { t("系列", "Series") }

    static var appearance: String { t("見た目", "Appearance") }
    static var palette: String { t("配色", "Colors") }
    static var showValues: String { t("数値を表示", "Show values") }
    static var showLegend: String { t("凡例を表示", "Show legend") }
    static var showGrid: String { t("目盛り線", "Grid lines") }

    static var share: String { t("画像を共有", "Share image") }
    static var shareHint: String { t("メールやLINEにそのまま送れます", "Send it straight to Mail or messages") }
    static var importCSV: String { t("CSVを読み込む", "Import CSV") }
    static var paste: String { t("貼り付けて取り込み", "Paste data") }
    static var pasteHint: String { t("Excelやメモからコピーした表を貼り付け（タブ・カンマ区切り）", "Paste rows copied from a sheet (tab or comma separated)") }
    static var load: String { t("取り込む", "Load") }

    static var done: String { t("完了", "Done") }
    static var cancel: String { t("キャンセル", "Cancel") }
    static var close: String { t("閉じる", "Close") }
    static var delete: String { t("削除", "Delete") }
    static var edit: String { t("編集", "Edit") }
    static var rename: String { t("名前を変更", "Rename") }
    static var duplicate: String { t("複製", "Duplicate") }
    static var save: String { t("保存", "Save") }

    static var seriesDefault: String { t("値", "Value") }
    static var sampleTitle: String { t("今月の売上", "Monthly Sales") }

    static func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: isJa ? "ja_JP" : "en_US")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}
