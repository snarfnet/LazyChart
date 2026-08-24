import Foundation

/// Drives deterministic sample data and deep-linking when capturing App Store
/// screenshots. Activated only when the app is launched with `-screenshot <n>`.
enum ScreenshotMode {
    static let value: String? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }()

    static var isActive: Bool { value != nil }

    /// Chart to auto-open in the editor for a given screen, if any.
    static var autoEditKind: ChartKind? {
        switch value {
        case "2": return .bar
        case "3": return .pie
        default: return nil
        }
    }
}
