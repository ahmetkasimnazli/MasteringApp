//
//  PreviewView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 23.03.2024.
//

import SwiftUI

struct PreviewView: View {
    @ObservedObject var viewModel: DolbyIOViewModel
    @State var previewURL: URL?
    @State private var isLoading = true
    
    
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if previewURL != nil {
                        AudioPlayerView(fileName: "Preview Media", url: previewURL)
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
                NavigationLink {
                    ResultAndSaveView(viewModel: viewModel)
                }   label: {
                    Label("Get The Final Result", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(AppPrimaryButton())
                .font(.title2)
                .foregroundStyle(.white)
                .padding()
                
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: HomePageView()) {
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
            if uploadResponse != nil {
                
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
    PreviewView(viewModel: DolbyIOViewModel())
}
