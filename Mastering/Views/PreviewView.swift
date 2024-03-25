//
//  PreviewView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 23.03.2024.
//

import SwiftUI

struct PreviewView: View {
    @ObservedObject var viewModel: DolbyIOViewModel
    @State var previewURLs: [URL] = []
    
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                Form {
                    Section("Status") {
                        Button {
                            print("Master Preview Button tapped")
                            Task {
                                viewModel.getMasterPreviewJobStatus()
                            }
                        } label: {
                            Label("Check Status", systemImage: "questionmark.circle")
                        }
                    }
                    Section("Pick your preset") {
                        ForEach(previewURLs, id: \.self) { previewURL in
                            AudioPlayerView(fileName: "Master Preview", url: previewURL )
                        }
                    }
                    
                    .navigationTitle("Previews")
                }
                
            }
            
                                       }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: nil, dismissButton: .default(Text("OK")))
            }
        
        .onReceive(viewModel.$uploadLink, perform: { uploadLink in
            if uploadLink != nil {
                viewModel.uploadMedia()
                print("uploadMedia() çalıştı")

            }        })
        .onReceive(viewModel.$uploadResponse, perform: { uploadResponse in
            if uploadResponse != nil {
                viewModel.createMasterPreview()
                print("createMasterPreview() çalıştı")
            }
            
        })
        .onReceive(viewModel.$jobID) { jobID in
                    if let jobID = jobID {
                        // Timer başlat
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            viewModel.getMasterPreviewJobStatus()
                        }
                    }
                }

        .onReceive(viewModel.$previewStatus) { status in
                    if status == "Success" {
                        // Timer'i durdur
                        timer?.invalidate()
                        timer = nil
                        // downloadMasterPreview fonksiyonunu çağır
                        viewModel.downloadMasterPreview()
                    }
                }
        
        .onReceive(viewModel.$previewURLs) { urls in
            previewURLs = urls
            print("previewURLs: \(previewURLs)")
        }

        
        
    }
}

#Preview {
    PreviewView(viewModel: DolbyIOViewModel())
}
