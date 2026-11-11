import SwiftUI

struct TemplatePicker: View {
    let select: (ChartDoc) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(L.t("空のグラフから", "Start with a blank chart")) { select(ChartDoc.empty()); dismiss() }
                }
                Section {
                    ForEach(ChartTemplate.allCases) { template in
                        Button(template.title) { select(template.makeDocument()); dismiss() }
                    }
                } header: { Text(L.t("用途別テンプレート", "Templates")) }
                footer: { Text(L.t("数値は見本です。作成後、ご自身のデータに置き換えてください。", "Values are examples. Replace them with your own data after creating the chart.")) }
            }.navigationTitle(L.t("グラフを作る", "Create chart"))
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button(L.cancel) { dismiss() } } }
        }
    }
}
