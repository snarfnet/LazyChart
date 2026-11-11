import Foundation
for template in ChartTemplate.allCases {
 let a = template.makeDocument(), b = template.makeDocument()
 assert(a.id != b.id && !a.labels.isEmpty && a.series.count == 1)
 assert(a.labels.count == a.series[0].values.count)
 assert(a.series[0].values.allSatisfy { $0.isFinite && $0 >= 0 })
 let copy = try JSONDecoder().decode(ChartDoc.self, from: JSONEncoder().encode(a))
 assert(copy == a)
}
assert(ChartTemplate.expenses.makeDocument().kind == .pie)
assert(ChartTemplate.weekly.makeDocument().labels.count == 7)
print("PASS: template dimensions, unique document identity, JSON persistence")
