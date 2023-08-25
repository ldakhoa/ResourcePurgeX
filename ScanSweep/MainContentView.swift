import SwiftUI
import FengNiaoKit
import Cocoa

struct MainContentView: View {
    @StateObject private var viewModel: MainContentViewModel = MainContentViewModel()
    @Environment(\.openWindow) var openWindow

    // MARK: Text Field
    
    @State private var projectPath: String = ""
    @State private var excludePaths: String = ""
    @State private var fileExtensions: String = Constants.defaultFileExtensions
    @State private var resourcesExtensions: String = Constants.defaultResourcesExtension
    @FocusState private var focusedField: FocusedField?

    // MARK: Show alert
    
    @State private var showDeleteAllAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showDeleteStatusView: Bool = false

    // MARK: Table

    @State private var selected = Set<FengNiaoKit.FileInfo.ID>()
    @State private var fileNameSortOrder = [
        KeyPathComparator(\FengNiaoKit.FileInfo.fileName),
        KeyPathComparator(\FengNiaoKit.FileInfo.size),
        KeyPathComparator(\FengNiaoKit.FileInfo.path)
    ]

    // MARK: View

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
                    }.onChange(of: fileNameSortOrder) { sortOrder in
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
                    let size = viewModel.unusedFiles
                        .reduce(0) { $0 + $1.size }.fn_readableSize
                    Text("\(viewModel.unusedFiles.count) files are found. Total Size: \(size)")

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
        .sheet(isPresented: $showDeleteStatusView) {
            DeleteStatusView(
                projectPath: self.projectPath,
                filesToDelete: viewModel.unusedFiles
            )
            .frame(width: 500, height: 200)
            .onDisappear {
                fetchUnusedFiles()
            }
        }
        .alert(
            deleteItemTitle,
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This item will be delete immediately.\nYou can't undo this action.")
        }
        .alert(
            "Are you sure you want to delete all items?",
            isPresented: $showDeleteAllAlert
        ) {
            Button("Delete All") {
                showDeleteStatusView.toggle()
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
                TextField(
                    "Types of files, separates with space. Default is 'm mm swift xib storyboard'",
                    text: $fileExtensions
                )
                .focused($focusedField, equals: .files)
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
        case project, excludes, files, resources
    }
}

// MARK: - Constants

enum Constants {
    static let defaultFileExtensions: String = "h m mm swift xib storyboard plist"
    static let defaultResourcesExtension: String = "imageset jpg png gif pdf heic"
}

// MARK: - Preview

#Preview {
    MainContentView()
        .frame(width: 800, height: 800)
}
