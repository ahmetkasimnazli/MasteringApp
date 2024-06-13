//
//  AnalyzeResultView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 15.05.2024.
//

import SwiftUI

struct AnalyzeResultView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    @State private var isLoading = true
    @State private var timer: Timer?
    @State private var data: Analyze?

    var body: some View {
        VStack {
            Spacer()
            ZStack{
                VStack {
                    if data != nil {
                        VStack (spacing: 30) {
                            VStack {
                                Text(data?.key ?? "No Data")
                                    .font(.title)
                                    .bold()
                                Text("Key")
                            }

                            VStack {
                                Text(String(format: "%.2f", data!.bpm))
                                    .font(.title)
                                    .bold()
                                Text("BPM")

                            }

                            VStack {
                                Text(String(format: "%.2f", data!.loudness))
                                    .font(.title)
                                    .bold()
                                Text("Loudness")
                            }

                        }.padding()
                            .frame(minWidth: 270)
                            .background(.ultraThickMaterial)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                ))
                    }
                }
                .overlay{
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
                .navigationTitle("Analysis Result")
            }
            Spacer()
            if !isLoading{
                Button(action: { viewModel.path = [] }) {
                    Text("Restart")
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onReceive(viewModel.$uploadLink, perform: { uploadLink in
            if uploadLink != nil {
                viewModel.uploadMedia()
                print("uploadMedia() çalıştı")
            }})
        .onReceive(viewModel.$uploadResponse, perform: { uploadResponse in
            if let httpResponse = uploadResponse, httpResponse.statusCode == 200 {
                viewModel.analyzeMedia()
            }})
        .onReceive(viewModel.$jobID) { jobID in
            if let jobID = jobID {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    viewModel.getJobStatus(selectedAction: "analyze/music")
                }
            }
        }
        .onReceive(viewModel.$jobStatus) { jobStatus in
            if jobStatus == "Success" {

                timer?.invalidate()
                timer = nil
                viewModel.getAnalysisResult()
            }
        }
        .onReceive(viewModel.$analyzeResult) { data in
            if let data = data {
                self.data = data
            }
        }
        .onChange(of: data) {
            if data != nil {
                isLoading = false
            }
        }
    }
}
#Preview {
    AnalyzeResultView()
        .environmentObject(DolbyIOViewModel())
}
