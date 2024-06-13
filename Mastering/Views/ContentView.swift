//
//  ContentView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI
import RevenueCatUI


struct ContentView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    @State private var isImporting = false
    @State var selectedFileName: String = ""
    @State var fileURL: URL?
    @State private var isSheetPresented = false
    @State private var showingActionAlert = false
    @State private var showingNoCreditAlert = false
    @State private var displayPaywall = false

    var body: some View {
        VStack {
            switch viewModel.selectedAction {
            case .master:
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
                                if viewModel.selectedAction == .master {
                                    Text("Maximum file size: 10 min")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if viewModel.selectedAction == .enhance {
                                    Text("Maximum file size: N/A")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            AudioPlayerView( fileName: selectedFileName, url: fileURL)
                            Text("Tip: Put the slider to sweet spot of your track to get the best preview result.")
                                .bold()
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                    }
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
                Button {
                        showingActionAlert.toggle()
                }label: {
                    Label("Preview Mastered Track ", systemImage: "checkmark.circle.fill")
                        .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .disabled(selectedFileName.isEmpty)
                .font(.title2)
                .navigationTitle("Mastering")

            case .enhance:
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
                                Text("Maximum file size: N/A")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            AudioPlayerView( fileName: selectedFileName, url: fileURL)
                        }

                    }
                }
                Button {
                    if viewModel.credits >= 50 {
                        showingActionAlert.toggle()
                    } else {
                        showingNoCreditAlert.toggle()
                    }
                }label: {
                    Label("Enhance your media", systemImage: "checkmark.circle.fill")
                        .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .disabled(selectedFileName.isEmpty)
                .font(.title2)
                .navigationTitle("Enhance")
            case .transcode:
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
                                Text("Maximum file size: N/A")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            AudioPlayerView( fileName: selectedFileName, url: fileURL)
                        }

                    }
                    Section("Select output file type") {
                        Picker("Select Transcode", selection: $viewModel.selectedTranscode) {
                            ForEach(Transcode.allCases, id: \.self) { transcode in
                                Text(transcode.rawValue.uppercased()).tag(transcode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }
                }

                Button {
                    if viewModel.credits >= 50 {
                        showingActionAlert.toggle()
                    } else {
                        showingNoCreditAlert.toggle()
                    }
                }label: {
                    Label("Transcode your media", systemImage: "checkmark.circle.fill")
                        .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .disabled(selectedFileName.isEmpty)
                .font(.title2)
                .navigationTitle("Transcode")
            case .analyze:
                Form{
                    Section{
                        if selectedFileName.isEmpty {
                            Button {
                                isImporting.toggle()
                            } label: {
                                Label("Import Media", systemImage: "square.and.arrow.down")
                                    .frame(minWidth: 400, maxWidth: .infinity,minHeight: 100, alignment: .center)
                                    .font(.title3)
                                    .bold()
                                    .padding()
                                Text("Maximum file size: N/A")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            AudioPlayerView( fileName: selectedFileName, url: fileURL)
                        }

                    }
                }
                Button {
                    if viewModel.credits >= 50 {
                        showingActionAlert.toggle()
                    } else {
                        showingNoCreditAlert.toggle()
                    }
                }label: {
                    Label("Analyze your media", systemImage: "checkmark.circle.fill")
                        .padding(10)
                }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .disabled(selectedFileName.isEmpty)
                .font(.title2)
                .navigationTitle("Analyze")
            case .none:
                EmptyView()
            }

        }
        .alert(isPresented: $showingActionAlert){
            switch viewModel.selectedAction {
            case .enhance:
                Alert(title: Text("Important message"), message: Text("200 Credits will be used for this action. Do you want to continue?"), primaryButton: .default(Text("Use")){
                    viewModel.path.append(DolbyIOViewModel.Destination.result)
                }, secondaryButton: .destructive(Text("Cancel")))
            case .transcode:
                Alert(title: Text("Important message"), message: Text("100 Credits will be used for this action. Do you want to continue?"), primaryButton: .default(Text("Use")){
                    viewModel.path.append(DolbyIOViewModel.Destination.result)
                }, secondaryButton: .destructive(Text("Cancel")))
            case .analyze:
                Alert(title: Text("Important message"), message: Text("100 Credits will be used for this action. Do you want to continue?"), primaryButton: .default(Text("Use")){
                    viewModel.path.append(DolbyIOViewModel.Destination.analyzeResult)
                }, secondaryButton: .destructive(Text("Cancel")))
            default:
                Alert(title: Text("Important message"), message: Text("100 Credits will be used for this action. Do you want to continue?"), primaryButton: .default(Text("Use")), secondaryButton: .destructive(Text("Cancel")))
            }
        }
        .alert("Not enough credit🥲",  isPresented: $showingNoCreditAlert) {
                    Button("OK", role: .cancel) {
                        displayPaywall.toggle()
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
        .sheet(isPresented: self.$displayPaywall, onDismiss: {
            viewModel.path.append(DolbyIOViewModel.Destination.store)
        }) {
            PaywallView(displayCloseButton: true)
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

#Preview {
    ContentView()
        .environmentObject(DolbyIOViewModel())
}


