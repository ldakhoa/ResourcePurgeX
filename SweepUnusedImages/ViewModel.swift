import FengNiaoKit
import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var unusedFiles: [FengNiaoKit.FileInfo] = []
    @Published var contentState: ContentState = .idling

    enum ContentState {
        case idling
        case loading
        case content
        case error
    }

    func handleOpenFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            if let chosenFile = panel.url {
                let path = chosenFile.path
                fetchUnusedFiles(from: path)
            }
        }
    }

    private func fetchUnusedFiles(from path: String) {
        contentState = .loading
        let fengNiao = FengNiao(
            projectPath: path,
            excludedPaths: [],
            resourceExtensions: Constants.defaultResourcesExtension,
            searchInFileExtensions: Constants.defaultFileExtensions
        )
        do {
            let files = try fengNiao.unusedFiles()
            self.unusedFiles = files
            self.contentState = .content
        } catch {
            self.contentState = .error
        }
    }

    enum Constants {
        static let defaultFileExtensions: [String] = ["h", "m", "mm", "swift", "xib", "storyboard", "plist"]
        static let defaultResourcesExtension: [String] = ["imageset", "jpg", "png", "gif", "pdf", "heic"]
    }
}
