//
//  SettingsView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 21.03.2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isSystemSettings = true
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Premium")) {
                    Button {
                        print("Premium Button tapped")
                    } label: {
                        Label("Master.ai PRO", systemImage: "person.crop.circle.badge.xmark")
                    }
                    
                    Button {
                        print("Restore Button tapped")
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.triangle.2.circlepath")
                    }

                }
                Section(header: Text("Appearance")) {
                    Button {
                        print("About Button tapped")
                    } label: {
                        Toggle("Dark Mode",systemImage: "moon.stars.fill", isOn: $isDarkMode)
                            
                    }
                    Button {
                        print("About Button tapped")
                    } label: {
                        Toggle("Use System Settings",systemImage: "gear", isOn: $isSystemSettings)
                    }
                }
                Section(header: Text("Support")) {
                    Button {
                        print("About Button tapped")
                    } label: {
                        Label("Send Feedback", systemImage: "at")
                            
                    }
                    Button {
                        print("About Button tapped")
                    } label: {
                        Label("Write a Review",systemImage: "heart.fill")
                            
                    }
                }
            }
            .buttonStyle(.plain)
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
