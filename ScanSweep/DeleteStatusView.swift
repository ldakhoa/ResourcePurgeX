import SwiftUI
import FengNiaoKit

struct DeleteStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDetailStatus: Bool = false
    @StateObject private var viewModel: DeleteStatusViewModel

    init(filesToDelete: [FengNiaoKit.FileInfo]) {
        _viewModel = StateObject(wrappedValue: DeleteStatusViewModel(unusedFilesToDelete: []))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: showDetailStatus ? "chevron.down" : "chevron.right")
                    .font(.subheadline)
                Text("Deleting unused files...")
                    .font(.body)
                    .bold()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showDetailStatus.toggle()
            }
            .animation(.spring(duration: 0.15), value: showDetailStatus)

            if showDetailStatus {
                Text("""
            3 unused files are deleted
            Now deleting unused reference in project.pbxproj...
            Unused reference delete successfully
            """)
                .font(.subheadline)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
                .animation(.spring(duration: 0.3), value: showDetailStatus)
            }

            Spacer()

            ProgressView(
                viewModel.deleteAmount == 100 ? "Finished!" : "Deleting...",
                value: viewModel.deleteAmount,
                total: 100
            )
            .foregroundColor(Color(NSColor.secondaryLabelColor))

            Spacer()

            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .tint(Color.accentColor)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {

        }
    }
}

#Preview {
    DeleteStatusView(filesToDelete: [])
        .frame(width: 500, height: 200)
}
