import SwiftUI

struct DeleteStatusView: View {
    @State private var deleteAmount = 0.0
    @Environment(\.dismiss) private var dismiss
    @State private var showDetailStatus: Bool = false

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
                deleteAmount == 100 ? "Finished!" : "Deleting...",
                value: deleteAmount,
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
    }
}

#Preview {
    DeleteStatusView()
        .frame(width: 500, height: 200)
}
