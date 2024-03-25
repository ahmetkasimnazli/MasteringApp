//
//  ContentView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @StateObject private var viewModel = DolbyIOViewModel()
    //@StateObject private var audioViewModel = AudioPlayerViewModel()
    @State private var isImporting = false
    @State var selectedFileName: String = ""
    @State var fileURL: String = ""
    @State private var isExporting = false
    @State var selectedAction: String
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section("Pick") {
                        if selectedFileName.isEmpty {
                            Button {
                                isImporting.toggle()
                            } label: {
                                Label("Import Media", systemImage: "square.and.arrow.down")
                                    .frame(minWidth: 400, maxWidth: .infinity,minHeight: 100, alignment: .center)
                                    .padding()
                            }
                        } else {
                            AudioPlayerView(fileName: selectedFileName, url: URL(fileURLWithPath: fileURL))
                            
                        }
                    }
                if selectedAction == "Master" {
                    Section("Upload") {
                        
                        NavigationLink(destination: PreviewView(viewModel: viewModel)) {
                                Button {
                                    print("Master Preview Button tapped")

                                        viewModel.isLoading = true
                                        
                                    
                                } label: {
                                    Label("Preview Different Presets", systemImage: "rectangle.stack")
                                }
                            }
                        }
                }
                    }

            }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.audio]) { result in
                do {
                    let file = try result.get()
                    
                    if file.startAccessingSecurityScopedResource() {
                        // Perform operations with the file URL
                        selectedFileName = file.lastPathComponent
                        viewModel.fileURL = file.path
                        fileURL = file.path
                        print("File URL: \(fileURL)")
                        viewModel.uploadMediaInput()
                        // Show the audio player view when a file is selected
                        
                        
                        file.stopAccessingSecurityScopedResource()
                    }
                } catch {
                    print("Error importing file: \(error)")
                }
            }


                .fileExporter(isPresented: $isExporting, document: Doc(url: viewModel.fileURL ?? "//"), contentType: .audio, onCompletion: { result in
                    
                    do {
                        let file = try result.get()
                        print("File: \(file)")
                    } catch {
                        print("Error: \(error)")
                    }
                })
                .navigationTitle("DolbyIO")
            }
            .onAppear {
                viewModel.getToken()
                
            }
            .onReceive(viewModel.$token, perform: { _ in
                viewModel.uploadMediaInput()
            })
            
        }
    }
    
    struct Doc: FileDocument {
        var url: String
        
        static var readableContentTypes: [UTType]{[.audio]}
        
        init(url : String) {
            self.url = url
        }
        
        init(configuration: ReadConfiguration) throws {
            
            url = ""
        }
        
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            let file = try! FileWrapper(url: URL(string: url)!, options: .immediate)
            
            return file
        }
    }

