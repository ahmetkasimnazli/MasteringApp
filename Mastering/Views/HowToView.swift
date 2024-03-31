//
//  HowToMasterView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 26.03.2024.
//

import SwiftUI

struct HowToView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    var body: some View {
        VStack(alignment: .leading) {
            List {
                if viewModel.selectedAction == "master" {
                    Text("1. Import your file.")
                    Text("2. Select your preset.")
                    Text("3. Find the sweet spot of your track.")
                    Text("4. Listen your preview.")
                    Text("5. If you like mastered version, get the final result.")
                    Text("6. Use mastered version of your tracks as you like.")
                    
                        .navigationTitle("How To Master Track?")
                }
                if viewModel.selectedAction == "enhance" {
                    Text("1. Import your file.")
                    Text("2. Tap on enhance button.")
                    Text("3. Save your enhanced file.")
                    Text("3. Use your enhanced file as you like.")
                    
                        .navigationTitle("How To Enhance Media?")
                }
                
            }
            .font(.title)
            .bold()
            
            
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HowToView()
}
