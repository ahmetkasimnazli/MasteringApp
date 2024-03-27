//
//  ResultAndSaveView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 27.03.2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ResultAndSaveView: View {
    @ObservedObject var viewModel: DolbyIOViewModel
    @State var downloadURL: URL?
    @State private var isLoading = true
    @State private var isExporting = false
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if downloadURL != nil {
                        AudioPlayerView(fileName: "Mastered Media", url: downloadURL)
                    }
                    
                    
                }
                .overlay {
                    if isLoading {
                        ProgressView(viewModel.progressTitle)
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1, anchor: .center)
                            .bold()
                            .frame(width: 150, height: 150)
                            .background(.ultraThinMaterial)
                            .foregroundStyle(Color.primary)
                            .cornerRadius(20)
                        
                    }
                    
                }
                
                .navigationTitle("Result and Save")
            }
            if !isLoading {
                Button {
                    isExporting.toggle()
                } label: {
                    Label("Export Your File", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .bold()
                .controlSize(.large)
                .tint(.accentColor)
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear() {
            
            viewModel.masterMedia()
        }
        
        .onReceive(viewModel.$jobID) { jobID in
            if let jobID = jobID {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    viewModel.getJobStatus(selectedAction: "master")
                }
            }
        }
        
        .onReceive(viewModel.$jobStatus) { jobStatus in
            if jobStatus == "Success" {
                
                timer?.invalidate()
                timer = nil
                viewModel.downloadMedia(selectedAction: "mastered")
            }
        }
        
        .onReceive(viewModel.$downloadURL) { url in

                self.downloadURL = url
                
            
        }
        .onChange(of: downloadURL) {
            if downloadURL != nil {
                isLoading = false
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

#Preview {
    ResultAndSaveView(viewModel: DolbyIOViewModel())
}
