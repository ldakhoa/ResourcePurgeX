import SwiftUI

@main
struct ScanSweepApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, idealWidth: 650, minHeight: 300)
        }
        WindowGroup {
            Text("Deleting window here...")
        }
    }
}
