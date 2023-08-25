import FengNiaoKit
import Foundation
import Combine
import PathKit

final class DeleteStatusViewModel: ObservableObject {
    @Published var unusedFilesToDelete: [FengNiaoKit.FileInfo] = []
    @Published var deleteAmount = 0.0
    @Published var consoleStatus: String = ""

    private let projectPath: String
    private let queue = DispatchQueue(label: "com.ldakhoa.scansweep", attributes: .concurrent)
    private let timer = Timer.publish(every: 0.1, on: .current, in: .default).autoconnect()
    private var cancellable: AnyCancellable?

    init(
        projectPath: String,
        unusedFilesToDelete: [FengNiaoKit.FileInfo]
    ) {
        self.projectPath = projectPath
        self.unusedFilesToDelete = unusedFilesToDelete
    }

    func deleteUnusedFiles() {
        let increasePercentagePerFiles = unusedFilesToDelete.count / 100

        queue.async {
            let (deleted, failed) = FengNiao.delete(self.unusedFilesToDelete)

            self.cancellable = self.timer.sink { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if self.deleteAmount < 99 {
                        self.deleteAmount += Double(increasePercentagePerFiles)
                    }
                }
            }

            guard failed.isEmpty else {
                print(failed)
                return
            }

            DispatchQueue.main.async {
                let content = self.unusedFilesToDelete.count > 1 ?
                "\(self.unusedFilesToDelete.count) unused files are deleted" :
                "\(self.unusedFilesToDelete.first?.fileName ?? "") is deleted"
                self.consoleStatus += content
            }

            let projectPath = Path(self.projectPath)
            if let children = try? projectPath.absolute().children() {
                DispatchQueue.main.async {
                    self.consoleStatus += "\nNow deleting unused reference in project.pbxproj..."
                }

                let xcodeprojFiles = children.filter { $0.lastComponent.hasSuffix("xcodeproj") }
                let pbxprojFiles = xcodeprojFiles.map { $0 + "project.pbxproj" }
                for pbxprojFile in pbxprojFiles {
                    FengNiao.deleteReference(projectFilePath: pbxprojFile, deletedFiles: deleted)
                }
            }

            DispatchQueue.main.async {
                self.consoleStatus += "\nUnused reference delete successfully"
                self.cancellable = nil
                self.deleteAmount = 100
            }
        }
    }
}
