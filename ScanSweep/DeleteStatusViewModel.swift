import FengNiaoKit
import Foundation

final class DeleteStatusViewModel: ObservableObject {
    @Published var unusedFilesToDelete: [FengNiaoKit.FileInfo] = []
    @Published var deleteAmount = 0.0

    init(unusedFilesToDelete: [FengNiaoKit.FileInfo]) {
        self.unusedFilesToDelete = unusedFilesToDelete
    }
}
