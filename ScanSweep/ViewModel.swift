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

    func fetchUnusedFiles(
        from path: String,
        excludePaths: String,
        fileExtensions: String,
        resourcesExtensions: String
    ) {
        contentState = .loading
        let fengNiao = FengNiao(
            projectPath: path,
            excludedPaths: [],
            resourceExtensions: resourcesExtensions.split(separator: " ").map(String.init),
            searchInFileExtensions: fileExtensions.split(separator: " ").map(String.init)
        )

        do {
            let files = try fengNiao.unusedFiles()
            self.unusedFiles = files
            self.contentState = .content
        } catch {
            self.contentState = .error
        }
    }
}
