//
//  MasteringApp.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI

@main
struct MasteringApp: App {
    @StateObject private var viewModel = DolbyIOViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    var body: some Scene {
        WindowGroup {
            HomePageView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                
        }
        
        .environmentObject(viewModel)
    }
}
