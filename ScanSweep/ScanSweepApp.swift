import SwiftUI

@main
struct ScanSweepApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .frame(minWidth: 300, idealWidth: 650, minHeight: 300)
        }
    }
}
