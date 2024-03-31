//
//  ContentView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    @State private var isImporting = false
    @State var selectedFileName: String = ""
    @State var fileURL: URL?
    @State private var isSheetPresented = false
    
    var body: some View {
        NavigationStack {
                Form {
                Section("Select your file") {
                    if selectedFileName.isEmpty {
                        Button {
                            isImporting.toggle()
                        } label: {
                            Label("Import Media", systemImage: "square.and.arrow.down")
                                .frame(minWidth: 400, maxWidth: .infinity,minHeight: 100, alignment: .center)
                                .font(.title3)
                                .bold()
                                .padding()
                            if viewModel.selectedAction == "master" {
                                Text("Maximum file size: 10 min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if viewModel.selectedAction == "enhance" {
                                Text("Maximum file size: N/A")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        AudioPlayerView( fileName: selectedFileName, url: fileURL)
                        if viewModel.selectedAction == "master" {
                            Text("Tip: Put the slider to sweet spot of your track to get the best preview result.")
                                .bold()
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                }
                    if viewModel.selectedAction == "master" {
                    Section("Select your preset") {
                        Picker("Select your preset", selection: $viewModel.selectedPreset) {
                            ForEach(viewModel.masterPresets.keys.sorted(), id: \.self) { key in
                                Text(viewModel.masterPresets[key]!)
                                    .tag(key) // Key'i tag olarak kullanarak seçilen değeri atıyoruz
                            }
                        }
                        
                        .labelsHidden()
                        
                    }
                }

            }
            
            
            if viewModel.selectedAction == "master" {
                NavigationLink {
                    PreviewView()
                }   label: {
                    Label("Preview Mastered Track", systemImage: "rectangle.stack")
                        .padding(10)
                }
                .disabled(selectedFileName.isEmpty)
                .buttonStyle(.borderedProminent)
                .bold()
                .font(.title2)
                .padding()
                .navigationTitle("Mastering")
                
            }
            if viewModel.selectedAction == "enhance" {
                NavigationLink {
                    ResultAndSaveView()
                    
                }   label: {
                    Label("Enhance your media", systemImage: "checkmark.circle.fill")
                        .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .disabled(selectedFileName.isEmpty)
                .font(.title2)

                
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isSheetPresented.toggle()
                } label: {
                    Label("How To Master Track?", systemImage: "questionmark.circle.fill")
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            NavigationStack {
                HowToView()
                    
                    
            }
            .presentationDetents([.medium])
        }
        
        
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.audio]) { result in
            do {
                let file = try result.get()
                
                if file.startAccessingSecurityScopedResource() {
                    // Perform operations with the file URL
                    selectedFileName = file.lastPathComponent
                    viewModel.fileURL = file.path
                    self.fileURL = file
                    print("File URL: \(fileURL)")
                    viewModel.uploadMediaInput()
                }
            } catch {
                print("Error importing file: \(error)")
            }
        }
        
        
        
        .onAppear {
            viewModel.reset()
            viewModel.getToken()
            
        }
        
    
        
                
    }
}



