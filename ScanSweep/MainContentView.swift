import SwiftUI
import FengNiaoKit
import Cocoa
import PathKit

struct MainContentView: View {
    @StateObject private var viewModel: MainContentViewModel = MainContentViewModel()
    @Environment(\.openWindow) var openWindow

    // MARK: Text Field
    
    @State private var projectPath: String = ""
    @State private var excludePaths: String = ""
    @State private var resourcesExtensions: String = Constants.defaultResourcesExtension
    @FocusState private var focusedField: FocusedField?

    // MARK: Show alert
    
    @State private var showDeleteAllAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showDeleteAllView: Bool = false
    @State private var showDeleteView: Bool = false

    // MARK: Table

    @State private var selected = Set<FengNiaoKit.FileInfo.ID>()
    @State private var fileNameSortOrder = [
        KeyPathComparator(\FengNiaoKit.FileInfo.fileName),
        KeyPathComparator(\FengNiaoKit.FileInfo.size),
        KeyPathComparator(\FengNiaoKit.FileInfo.path)
    ]

    // MARK: Checkbox

    @State private var toggleStates = [
        ToggleState(fileExtension: "h", isOn: true),
        ToggleState(fileExtension: "m", isOn: true),
        ToggleState(fileExtension: "mm", isOn: true),
        ToggleState(fileExtension: "swift", isOn: true),
        ToggleState(fileExtension: "xib", isOn: true),
        ToggleState(fileExtension: "storyboard", isOn: true),
        ToggleState(fileExtension: "plist", isOn: true)
    ]

    // MARK: - View

    var body: some View {
        VStack {
            configView

            Divider()

            VStack(alignment: .leading) {
                Text("Unused Files")
                    .font(.headline)
                ZStack {
                    Table(
                        viewModel.unusedFiles,
                        selection: $selected,
                        sortOrder: $fileNameSortOrder
                    ) {
                        TableColumn("File Name", value: \.fileName)
                            .width(min: 150, ideal: 150, max: 300)
                        TableColumn("Size", value: \.size) {
                            Text($0.size.fn_readableSize)
                        }
                        .width(min: 50, max: 150)
                        TableColumn("Full Path", value: \.path.string)
                    }
                    .animation(.default, value: viewModel.unusedFiles)
                    .onChange(of: fileNameSortOrder) { sortOrder in
                        viewModel.unusedFiles.sort(using: sortOrder)
                    }

                    if viewModel.contentState == .loading {
                        VStack(spacing: 8) {
                            ProgressView()
                            Text("Searching unused file. This may take a while...")
                        }
                    }
                }
            }

            Spacer(minLength: 16)

            if viewModel.contentState == .content {
                HStack {
                    if viewModel.unusedFiles.isEmpty {
                        Text("🎉 You have no unused resources in path: \(Path(projectPath).absolute().string)")
                    } else {
                        let size = viewModel.unusedFiles
                            .reduce(0) { $0 + $1.size }.fn_readableSize
                        Text("\(viewModel.unusedFiles.count) files are found. Total Size: \(size)")
                    }

                    Spacer()

                    Button("Delete") {
                        showDeleteAlert.toggle()
                    }
                    .disabled(selected.isEmpty)

                    Button("Delete All") {
                        showDeleteAllAlert.toggle()
                    }
                }
            }
        }
        .animation(.default, value: viewModel.contentState)
        .padding()
        .sheet(isPresented: $showDeleteAllView) {
            deleteView(filesToDelete: viewModel.unusedFiles)
                .onDisappear {
                    fetchUnusedFiles()
                }
        }
        .sheet(isPresented: $showDeleteView) {
            let fileToDelete = viewModel.unusedFiles.filter { selected.contains($0.id) }
            deleteView(filesToDelete: fileToDelete)
                .onDisappear {
                    viewModel.unusedFiles.removeAll(where: { fileToDelete.contains($0) } )
                }
        }
        .alert(
            deleteItemTitle,
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                showDeleteView.toggle()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This item will be delete immediately.\nYou can't undo this action.")
        }
        .alert(
            "Are you sure you want to delete all items?",
            isPresented: $showDeleteAllAlert
        ) {
            Button("Delete All") {
                showDeleteAllView.toggle()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can't undo this action.")
        }
    }

    @ViewBuilder
    private var configView: some View {
        VStack(alignment: .leading) {
            Text("Configurations")
                .font(.headline)

            HStack {
                Text("Project Path")
                TextField("Root path of your Xcode project", text: $projectPath)
                    .focused($focusedField, equals: .project)
                Button("Browse...") {
                    handleOpenFile()
                }
                .disabled(viewModel.isLoading)
            }

            HStack {
                Text("Exclude Paths")
                TextField(
                    "Exclude paths from search, separates with space. Example: Pods Carthage",
                    text: $excludePaths
                )
                .focused($focusedField, equals: .excludes)
            }

            HStack {
                Text("File Extensions")
                ForEach(toggleStates.indices, id: \.self) { index in
                    Toggle(toggleStates[index].fileExtension, isOn: $toggleStates[index].isOn)
                }
            }

            HStack {
                Text("Resources Extensions")
                TextField(
                    "Resource file extensions, separates with space. Default is 'imageset jpg png gif pdf'",
                    text: $resourcesExtensions
                )
                .focused($focusedField, equals: .resources)
            }
            HStack {
                Spacer()
                Button(viewModel.isLoading ? "Searching... " : "Search...") {
                    if projectPath.isEmpty {
                        focusedField = .project
                        return
                    }
                    fetchUnusedFiles()
                    focusedField = nil
                }
                .disabled(viewModel.isLoading)
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    @ViewBuilder
    func deleteView(filesToDelete: [FengNiaoKit.FileInfo]) -> some View {
        DeleteStatusView(
            projectPath: self.projectPath,
            filesToDelete: filesToDelete
        )
        .frame(width: 500, height: 200)
    }

    // MARK: Side Effects - Private

    private var deleteItemTitle: String {
        if selected.count == 1 {
            if let firstItem = selected.first,
               let selectedUnusedFile = viewModel.unusedFiles.first(where: { $0.id == firstItem } ) {
                return "Are you sure you want to delete \"\(selectedUnusedFile.fileName)\""
            }
        } else {
            return "Are you sure you want to delete the \(selected.count) selected items?"
        }
        return ""
    }

    private func handleOpenFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            if let chosenFile = panel.url {
                let path = chosenFile.path
                projectPath = path
            }
        }
    }

    private func fetchUnusedFiles() {
        let fileExtensions: [String] = toggleStates
            .filter { $0.isOn }
            .map { $0.fileExtension }

        viewModel.fetchUnusedFiles(
            from: projectPath,
            excludePaths: excludePaths,
            fileExtensions: fileExtensions,
            resourcesExtensions: resourcesExtensions
        )
    }
}

// MARK: - FocusedField

extension MainContentView {
    enum FocusedField {
        case project, excludes, resources
    }
}

// MARK: - Constants

enum Constants {
    static let defaultResourcesExtension: String = "imageset jpg png gif pdf heic"
}

// MARK: - Preview

#Preview {
    MainContentView()
        .frame(width: 800, height: 800)
}
