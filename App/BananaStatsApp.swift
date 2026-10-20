import SwiftUI
import UIKit

@main
struct BananaStatsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // The widget's tap URL lands here: hand it straight to Safari.
                .onOpenURL { url in UIApplication.shared.open(url) }
        }
    }
}
