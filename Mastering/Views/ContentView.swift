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
    @State var fileURL: URL?
    @State private var isSheetPresented = false
    @State var selectedAction: String
    
    let times: [String] = {
        var times: [String] = []
        for hour in 0...25 {
            for minute in 0..<60 {
                let timeString = String(format: "%02d:%02d", hour, minute)
                times.append(timeString)
            }
        }
        return times
    }()
    
    
    
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
                                .padding()
                        }
                    } else {
                        AudioPlayerView(fileName: selectedFileName, url: fileURL)
                    }
                }
                if selectedAction == "Master" {
                    Section("Select your preset") {
                        Picker("Select your preset", selection: $viewModel.selectedPreset) {
                            ForEach(viewModel.masterPresets.keys.sorted(), id: \.self) { key in
                                Text(viewModel.masterPresets[key]!)
                                    .tag(key) // Key'i tag olarak kullanarak seçilen değeri atıyoruz
                            }
                        }
                        
                        .labelsHidden()
                        
                    }
                    
                    Section("Find the sweet spot") {
                        Picker(selection: $viewModel.selectedTime, label: Text("")) {
                            ForEach(0..<times.count, id: \.self) { index in
                                Text(times[index]).tag(index)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                    }
                }
                
            }
            
            
            
            NavigationLink {
                PreviewView(viewModel: viewModel)
            }   label: {
                Label("Preview Mastered Track", systemImage: "rectangle.stack")
            }
            .disabled(selectedFileName.isEmpty)
            
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .foregroundStyle(.white)
            .padding()
            .navigationTitle("Mastering")
            
            
            
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
                HowToMasterView()
                    .navigationTitle("How To Master Track?")
                    .navigationBarTitleDisplayMode(.large)
                    
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
                    fileURL = file
                    print("File URL: \(fileURL)")
                    viewModel.uploadMediaInput()
                    // Show the audio player view when a file is selected
                    
                    
                    file.stopAccessingSecurityScopedResource()
                }
            } catch {
                print("Error importing file: \(error)")
            }
        }
        
        
        
        .onAppear {
            viewModel.reset()
            viewModel.getToken()
            
        }
        .onReceive(viewModel.$token, perform: { _ in
            viewModel.uploadMediaInput()
        })
        
    }
}



