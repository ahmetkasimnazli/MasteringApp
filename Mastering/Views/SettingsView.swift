//
//  SettingsView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 21.03.2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account")) {
                    Button {
                        print("Sign out Button tapped")
                    } label: {
                        Label("Sign Out", systemImage: "person.crop.circle.badge.xmark")
                    }
                }
                Section(header: Text("About")) {
                    Button {
                        print("About Button tapped")
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
