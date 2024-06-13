//
//  MasteringApp.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
@main
struct MasteringApp: App {
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Secrets.apiKey)
        }
    
    
    @StateObject private var viewModel = DolbyIOViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    var body: some Scene {
        WindowGroup {
            HomePageView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(viewModel)
                .presentPaywallIfNeeded(requiredEntitlementIdentifier: "Premium")
                
        }

        
    }
}
