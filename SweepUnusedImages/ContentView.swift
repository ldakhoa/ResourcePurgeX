//
//  ContentView.swift
//  SweepUnusedImages
//
//  Created by Khoa Le on 24/08/2023.
//

import SwiftUI
import FengNiaoKit
import Cocoa

struct ContentView: View {
    @StateObject private var viewModel: ViewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Browse File") {
                viewModel.handleOpenFile()
            }
            VStack(alignment: .leading) {
                Text("Unused Files")
                    .font(.headline)
                    .padding(.leading, 16)
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
                        ProgressView()
                    }
                }
            }

            Spacer(minLength: 16)

            if viewModel.contentState != .idling {
                let size = viewModel.unusedFiles.reduce(0) { $0 + $1.size }.fn_readableSize
                Text("\(viewModel.unusedFiles.count) files are found. Total Size: \(size)")
            }
        }
        .animation(.default, value: viewModel.contentState)
        .padding()
    }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 800)
}
