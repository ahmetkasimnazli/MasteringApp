//
//  HomePageView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 19.03.2024.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel


    func handleActionTap(_ action: Action) {
        viewModel.selectAction(action.action)
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(actions) { action in
                        NavigationLink(value: DolbyIOViewModel.Destination.content ) {
                            OptionBox(action: action)

                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                handleActionTap(action)
                            }
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: DolbyIOViewModel.Destination.store) {
                        HStack {
                            Image(systemName: "circle.dashed.inset.filled")
                                .foregroundStyle(.yellow)
                                .frame(width: 25, height: 25)
                                .glow()
                            Text("Credits: \(Int(viewModel.credits))")

                        }
                        .padding(5)
                        .font(.headline)
                        .bold()
                        .background(.ultraThickMaterial)
                        .clipShape(.capsule)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: DolbyIOViewModel.Destination.settings) {
                        Image(systemName: "gear")
                            .fontWeight(.bold)
                            .font(.title3)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitle("Choose your action")
            .navigationDestination(for: DolbyIOViewModel.Destination.self) { destination in
                switch destination {
                case .content:
                    ContentView()
                case .preview:
                    PreviewView()
                case .result:
                    ResultView()
                case .settings:
                    SettingsView()
                case .analyzeResult:
                    AnalyzeResultView()
                case .store:
                    StoreView()
                }
            }
        }
        .onAppear {
            viewModel.reset()
        }
    }
}


#Preview {
    HomePageView()
        .environmentObject(DolbyIOViewModel())
}
