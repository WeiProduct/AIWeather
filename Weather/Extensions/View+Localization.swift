import SwiftUI
import Combine

/// A view modifier that forces the view to refresh when language changes
struct LocalizationModifier: ViewModifier {
    @State private var languageUpdateId = UUID()
    
    func body(content: Content) -> some View {
        content
            .id(languageUpdateId)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                languageUpdateId = UUID()
            }
    }
}

extension View {
    /// Forces view to update when language changes
    func localizedView() -> some View {
        self.modifier(LocalizationModifier())
    }
}

/// A localized text view that automatically updates when language changes
struct LocalizedTextView: View {
    let key: String
    @State private var currentText: String
    
    init(_ key: String) {
        self.key = key
        self._currentText = State(initialValue: LocalizedText.get(key))
    }
    
    var body: some View {
        Text(currentText)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                currentText = LocalizedText.get(key)
            }
    }
}