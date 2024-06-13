//
//  PreviewView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 23.03.2024.
//

import SwiftUI

struct PreviewView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    @State var previewURL: URL?
    @State private var isLoading = true
    
    
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            ZStack {
                List {
                    if previewURL != nil {
                        AudioPlayerView(fileName: "Preview Media", url: previewURL)
                        Text("Tip: If you are not satisfied with the preview, you can go back and try different presets.")
                            .bold()
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                
                
            }
            .navigationTitle("Preview")
            
            if !isLoading {
                NavigationLink(value: DolbyIOViewModel.Destination.result) {
                    Label("Get The Final Result", systemImage: "checkmark.circle.fill")
                        .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .font(.title2)
                .foregroundStyle(.white)

                
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.path = [] }) {
                    Text("Restart")
                }
            }
        }
        
        .onReceive(viewModel.$uploadLink, perform: { uploadLink in
            if uploadLink != nil {
                
                viewModel.uploadMedia()
                print("uploadMedia() çalıştı")
                
            }        })
        .onReceive(viewModel.$uploadResponse, perform: { uploadResponse in
            if let httpResponse = uploadResponse, httpResponse.statusCode == 200 {
                viewModel.createMasterPreview()
                print("createMasterPreview() çalıştı")
            }
            
        })
        .onReceive(viewModel.$previewjobID) { jobID in
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
        
        .onReceive(viewModel.$previewURL) { url in
                print("TEST: \(previewURL)")
                self.previewURL = url
        }
        .onChange(of: previewURL) {
            if previewURL != nil {
                isLoading = false
            }
        }
        
        
        
    }
}

#Preview {
    PreviewView()
}
