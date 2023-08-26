import FengNiaoKit
import SwiftUI

final class MainContentViewModel: ObservableObject {
    @Published var unusedFiles: [FengNiaoKit.FileInfo] = []
    @Published var contentState: ContentState = .idling
    @Published var error: Error?

    var isLoading: Bool {
        contentState == .loading
    }

    private let queue = DispatchQueue(label: "com.ldakhoa.scansweep", attributes: .concurrent)

    func fetchUnusedFiles(
        from path: String,
        excludePaths: String,
        fileExtensions: [String],
        resourcesExtensions: String
    ) {
        contentState = .loading

        queue.async {
            let fengNiao = FengNiao(
                projectPath: path,
                excludedPaths: excludePaths.split(separator: " ").map(String.init),
                resourceExtensions: resourcesExtensions.split(separator: " ").map(String.init),
                searchInFileExtensions: fileExtensions
            )

            do {
                let files = try fengNiao.unusedFiles()

                DispatchQueue.main.async {
                    self.unusedFiles = files
                    self.contentState = .content
                }
            } catch {
                DispatchQueue.main.async {
                    self.contentState = .error
                    self.error = error
                }
            }
        }
    }
}

extension MainContentViewModel {
    enum ContentState {
        case idling
        case loading
        case content
        case error
    }
}
