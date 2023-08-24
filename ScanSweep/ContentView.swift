import SwiftUI
import FengNiaoKit
import Cocoa

struct ContentView: View {
    @StateObject private var viewModel: ViewModel = ViewModel()
    @State private var projectPath: String = ""
    @State private var excludePaths: String = ""
    @State private var fileExtensions: String = Constants.defaultFileExtensions
    @State private var resourcesExtensions: String = Constants.defaultResourcesExtension
    @State private var showDeleteAlert: Bool = false
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack {
            configView

            Divider()

            VStack(alignment: .leading) {
                Text("Unused Files")
                    .font(.headline)
                ZStack {
                    Table(viewModel.unusedFiles) {
                        TableColumn("File Name", value: \.fileName)
                            .width(min: 150, ideal: 150, max: 300)
                        TableColumn("Size") {
                            Text($0.size.fn_readableSize)
                        }
                        .width(min: 50, max: 150)
                        TableColumn("Full Path", value: \.path.string)
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
                    let size = viewModel.unusedFiles.reduce(0) { $0 + $1.size }.fn_readableSize
                    Text("\(viewModel.unusedFiles.count) files are found. Total Size: \(size)")

                    Spacer()

                    Button("Delete") {
                        showDeleteAlert.toggle()
                    }

                    Button("Delete All") {
                    }
                }
            }
        }
        .animation(.default, value: viewModel.contentState)
        .padding()
        .alert("Delete file", isPresented: $showDeleteAlert) {
            Button("Delete", role: .none) {}
            Button("Cancel", role: .cancel) {}
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

                    viewModel.fetchUnusedFiles(
                        from: projectPath,
                        excludePaths: excludePaths,
                        fileExtensions: fileExtensions,
                        resourcesExtensions: resourcesExtensions
                    )
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
}

enum FocusedField {
    case project, excludes, files, resources
}

enum Constants {
    static let defaultFileExtensions: String = "h m mm swift xib storyboard plist"
    static let defaultResourcesExtension: String = "imageset jpg png gif pdf heic"
}

#Preview {
    ContentView()
        .frame(width: 800, height: 800)
}
