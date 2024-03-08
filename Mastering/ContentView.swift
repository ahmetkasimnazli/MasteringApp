//
//  ContentView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DolbyIOViewModel()
    @State private var isImporting = false
    @State var selectedFileName: String = ""
    @State var fileURL: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Pick") {
                    Button {
                        isImporting = true
                    } label: {
                        Label(selectedFileName, systemImage: "folder.fill.badge.plus")
                    }
                }
                Section("Upload") {
                    Button {
                        print("Upload Button tapped")
                        Task {
                            viewModel.uploadMediaInput()
                            viewModel.uploadMedia(localFilePath: fileURL)
                        }
                    } label: {
                        Label("Upload", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        print("Enhance Button tapped")
                        Task {
                            viewModel.enhanceMedia()
                        }
                    } label: {
                        Label("Start Enhancing", systemImage: "sparkles")
                    }
                }
                Section("Save") {
                    Button {
                        print("Status Button tapped")
                        Task {
                            viewModel.getEnhanceJobStatus()
                        }
                    } label: {
                        Label("Get Enhance Job Status", systemImage: "questionmark.circle")
                    }
                }
                
                Button {
                    print("Save Button tapped")
                    Task {
                        viewModel.downloadEnhancedMedia()
                    }
                } label: {
                    Label("Save Enhanced Media File", systemImage: "square.and.arrow.down")
                }
            }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.audio]) { result in
            do {
                let file = try result.get()
                selectedFileName = file.lastPathComponent
                fileURL = String(file.path)
                print("File URL: \(fileURL)")
                 
            } catch {
                
            }
        }
        .navigationTitle("DolbyIO")
    }
    .onAppear {
        viewModel.getToken()
        
    }
}
}
