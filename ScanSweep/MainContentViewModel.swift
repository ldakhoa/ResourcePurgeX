import FengNiaoKit
import SwiftUI

final class MainContentViewModel: ObservableObject {
    @Published var unusedFiles: [FengNiaoKit.FileInfo] = []
    @Published var contentState: ContentState = .idling
    @Published var isDeleting: Bool = false
    @Published var consoleStatus: String = ""

    var isLoading: Bool {
        contentState == .loading
    }

    private let queue = DispatchQueue(label: "com.ldakhoa.scansweep", attributes: .concurrent)

    func fetchUnusedFiles(
        from path: String,
        excludePaths: String,
        fileExtensions: String,
        resourcesExtensions: String
    ) {
        contentState = .loading

        queue.async {
            let fengNiao = FengNiao(
                projectPath: path,
                excludedPaths: [],
                resourceExtensions: resourcesExtensions.split(separator: " ").map(String.init),
                searchInFileExtensions: fileExtensions.split(separator: " ").map(String.init)
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
                }
            }
        }
    }

    func deleteAllItems() {
        isDeleting = true
//        let (deleted, failed) = FengNiao.delete(self.unusedFiles)
        // TODO: Handle error
    }
}

extension MainContentViewModel {
    enum ContentState {
        case idling
        case loading
        case content
        case deleting
        case error
    }
}
