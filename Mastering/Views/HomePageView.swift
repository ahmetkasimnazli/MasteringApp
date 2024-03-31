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
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(actions) { action in
                        NavigationLink(destination: action.destination) {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .fontWeight(.bold)
                            .font(.title2)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitle("Choose your action")
        }
        .onAppear {
            viewModel.reset()
            
        }
    }
}
    

#Preview {
    HomePageView()
}
