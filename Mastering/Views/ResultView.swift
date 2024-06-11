//
//  ResultAndSaveView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 27.03.2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ResultView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    @State var downloadURL: URL?
    @State private var isLoading = true
    @State private var isExporting = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
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
                Button(action: { viewModel.path = [] }) {
                    Text("Restart")
                }
                
                Button {
                    isExporting.toggle()
                } label: {
                    Label("Export Your File", systemImage: "square.and.arrow.up")
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .bold()
                .controlSize(.large)
                .tint(.accentColor)
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        
            
        
        .onReceive(viewModel.$uploadLink, perform: { uploadLink in
            if uploadLink != nil {
                
                viewModel.uploadMedia()
                print("uploadMedia() çalıştı")
                
            }        })
        
        .onReceive(viewModel.$uploadResponse, perform: { uploadResponse in
            if let httpResponse = uploadResponse, httpResponse.statusCode == 200 {
                switch viewModel.selectedAction {
                case .master:
                    viewModel.masterMedia()
                case .enhance:
                    viewModel.enhanceMedia()
                case .transcode:
                    viewModel.transcodeMedia()
                default:
                    break
                }
            }
            
        })
            
            .onReceive(viewModel.$jobID) { jobID in
                if let jobID = jobID {
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        switch viewModel.selectedAction {
                        case .master:
                            viewModel.getJobStatus(selectedAction: "master")
                        case .enhance:
                            viewModel.getJobStatus(selectedAction: "enhance")
                        case .transcode:
                            viewModel.getJobStatus(selectedAction: "transcode")
                        default:
                            break
                        }
                    }
                }
            }
            
            .onReceive(viewModel.$jobStatus) { jobStatus in
                if jobStatus == "Success" {
                    
                    timer?.invalidate()
                    timer = nil
                    switch viewModel.selectedAction {
                    case .master:
                        viewModel.downloadMedia(selectedAction: "master", fileType: "wav")
                    case .enhance:
                        viewModel.downloadMedia(selectedAction: "enhance", fileType: "wav")
                    case .transcode:
                        viewModel.downloadMedia(selectedAction: "transcode", fileType: viewModel.selectedTranscode.rawValue)
                    default:
                        break
                    }
                }
            }
            
            .onReceive(viewModel.$downloadURL) { url in
                    self.downloadURL = url
                print("Download URL: \(downloadURL)")
                    
                
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
    ResultView()
}
