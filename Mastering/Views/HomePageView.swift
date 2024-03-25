//
//  HomePageView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 19.03.2024.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    NavigationLink(destination: ContentView(selectedAction: "Master")) {
                        OptionBox(title: "Music Mastering", description: "Use Music Mastering API to master your tracks.", icon: "music.quarternote.3", color: .yellow)
                            .frame(width: 500, height: 200)
                    }
                    NavigationLink(destination: ContentView(selectedAction: "Enhance")) {
                        OptionBox(title: "Enhance Media", description: "Use Enhance API to enhance your audio.", icon: "sparkles", color: .purple)
                            .frame(width: 500, height: 200)
                
                    }
                    NavigationLink(destination: ContentView(selectedAction: "Transcode")) {
                        OptionBox(title: "Transcode Media", description: "Use Transcode API to transcode your audio.", icon: "pencil.and.list.clipboard", color: .green)
                            .frame(width: 500, height: 200)
                
                    }
                    NavigationLink(destination: ContentView(selectedAction: "Analyze")) {
                        OptionBox(title: "Analyze Media", description: "Use Analyze API to analyze your audio.", icon: "waveform.badge.magnifyingglass", color: .red)
                            .frame(width: 500, height: 200)
                
                    }
                }
            }
            .padding(.vertical, 10)
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
        
    }
}

#Preview {
    HomePageView()
}
