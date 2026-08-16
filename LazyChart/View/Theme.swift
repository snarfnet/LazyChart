import SwiftUI

enum Theme {
    static let bg = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let card = Color.white
    static let accent = Color(red: 0.30, green: 0.43, blue: 0.96)
    static let ink = Color(red: 0.13, green: 0.15, blue: 0.20)
    static let subtle = Color(red: 0.55, green: 0.58, blue: 0.65)
    static let hairline = Color(red: 0.90, green: 0.91, blue: 0.94)
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
