import FengNiaoKit
import SwiftUI

final class MainContentViewModel: ObservableObject {
    @Published var unusedFiles: [FengNiaoKit.FileInfo] = []
    @Published private(set) var contentState: ContentState = .idling
    @Published private(set) var error: Error?
    /// Scanning project path to display info in result text.
    private(set) var scanningProjectPath: String = ""

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

        scanningProjectPath = path
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
                    self.contentState = .content(type: .unused)
                }
            } catch {
                DispatchQueue.main.async {
                    self.contentState = .error
                    self.error = error
                }
            }
        }
    }

    func fetchAllResourceFiles(
        from path: String,
        excludePaths: String,
        fileExtensions: [String],
        resourcesExtensions: String
    ) {
        contentState = .loading

        scanningProjectPath = path
        queue.async {
            let fengNiao = FengNiao(
                projectPath: path,
                excludedPaths: excludePaths.split(separator: " ").map(String.init),
                resourceExtensions: resourcesExtensions.split(separator: " ").map(String.init),
                searchInFileExtensions: fileExtensions
            )

            let files = fengNiao.allResourceFiles()
                .flatMap { $0.value }
                .map(FileInfo.init)

            DispatchQueue.main.async {
                self.unusedFiles = files
                self.contentState = .content(type: .all)
            }
        }
    }
}

extension MainContentViewModel {
    enum ContentState: Equatable {
        case idling
        case loading
        case content(type: ContentType)
        case error
    }

    enum ContentType {
        case unused
        case all
    }
}
