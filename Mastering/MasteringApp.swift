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
    
    var body: some Scene {
        WindowGroup {
            HomePageView()
        }
        .environmentObject(viewModel)
    }
}
