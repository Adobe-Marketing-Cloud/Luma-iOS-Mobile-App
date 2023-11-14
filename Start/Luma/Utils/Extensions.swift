//
//  Extensions.swift
//  Luma
//
//  Created by Rob In der Maur on 30/05/2022.
//

import SwiftUI
import AEPEdgeIdentity
import AEPOptimize

extension Text {
    /// Modifier for monospaced
    /// - Returns: font in monospaced character font
    func monospaced() -> Text {
        self
            .font(.system(size: 10, weight: .regular, design: .monospaced))
    }
}

extension Binding {
    /// Handles onChange for a binding
    /// - Parameter handler: handler
    /// - Returns: binding
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

extension IdentityMap {
    /// Returns jSON representation of identity map
    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Task where Success == Never, Failure == Never {
    /// Implements sleep in seconds (rather than nanoseconds) for tasks
    /// - Parameter seconds: number of seconds
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

extension String {
    /// Checks whether email is a valid email
    var isValidEmail: Bool {
        let name = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let domain = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegEx = name + "@" + domain + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}

extension String {
    /// Checks wheter URL is a valid URL
    var isValidURL: Bool {
        let urlRegEx = "((?:http|https)://)?(?:[\\w\\d\\-_]+\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlPredicate.evaluate(with: self)
    }
}

extension String {
    /// Checks wherther environment file id is a valid environment file id
    var isValidEnvironmentFileId: Bool {
        let environmentFileIdRegEx = ".*/launch-.*"
        let environmentFileIdPredicate = NSPredicate(format: "SELF MATCHES %@", environmentFileIdRegEx)
        return environmentFileIdPredicate.evaluate(with: self)
    }
}

extension Date {
    /// Formats date to string
    /// - Returns: string representation of date
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
}

extension Dictionary {
    /// Switch keys in a dictionary
    /// - Parameters:
    ///   - fromKey: from key
    ///   - toKey: to key
    mutating func switchKeys(fromKey: Key, toKey: Key) {
        for _ in self {
            if let entry = removeValue(forKey: fromKey) {
                self[toKey] = entry
                
            }
        }
    }
}

#if os(iOS)
extension UIApplication {
    
    /// Retrieves app version
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// Retrieves build number
    static var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
#endif

extension Color {
    static subscript(name: String) -> Color {
        switch name {
        case "green":
            return Color.green
        case "white":
            return Color.white
        case "black":
            return Color.black
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "pink":
            return Color.pink
        case "purple":
            return Color.purple
        case "blue":
            return Color.blue
        case "brown":
            return Color.brown
        case "cyan":
            return Color.cyan
        case "grey":
            return Color.gray
        case "gray":
            return Color.gray
        case "indigo":
            return Color.indigo
        case "mint":
            return Color.mint
        case "yellow":
            return Color.yellow
        default:
            return Color.clear
        }
    }
}


public extension View {
    /// Extension to define modifier to ensure code is only run on first appearance
    /// - Parameter action: action
    /// - Returns: view
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
}

// modifier to apply to the .onAppear of a view
private struct FirstAppear: ViewModifier {
    let action: () -> ()
    
    // Use this to only fire your block one time
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

