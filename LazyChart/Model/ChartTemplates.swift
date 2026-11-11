import Foundation

enum ChartTemplate: String, CaseIterable, Identifiable {
    case sales, expenses, weekly, survey
    var id: String { rawValue }
    var title: String {
        switch self {
        case .sales: return L.t("月別の売上", "Monthly sales")
        case .expenses: return L.t("家計の内訳", "Household expenses")
        case .weekly: return L.t("1週間の記録", "Weekly activity")
        case .survey: return L.t("アンケート結果", "Survey results")
        }
    }
    func makeDocument() -> ChartDoc {
        let labels: [String]; let values: [Double]; let kind: ChartKind
        switch self {
        case .sales:
            labels = L.isJa ? ["1月", "2月", "3月", "4月", "5月", "6月"] : ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
            values = [120, 140, 135, 160, 180, 175]; kind = .bar
        case .expenses:
            labels = L.isJa ? ["住居", "食費", "交通", "通信", "その他"] : ["Housing", "Food", "Transport", "Phone", "Other"]
            values = [40, 25, 10, 5, 20]; kind = .pie
        case .weekly:
            labels = L.isJa ? ["月", "火", "水", "木", "金", "土", "日"] : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            values = [20, 30, 25, 40, 35, 60, 45]; kind = .line
        case .survey:
            labels = L.isJa ? ["とても満足", "満足", "ふつう", "不満"] : ["Very satisfied", "Satisfied", "Neutral", "Unsatisfied"]
            values = [18, 32, 12, 3]; kind = .bar
        }
        return ChartDoc(title: title + L.t("（サンプル）", " (sample)"), kind: kind, labels: labels,
                        series: [Series(name: L.t("値", "Value"), values: values)])
    }
}

