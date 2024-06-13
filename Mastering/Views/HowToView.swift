//
//  HowToMasterView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 26.03.2024.
//

import SwiftUI

struct HowToView: View {
    @EnvironmentObject var viewModel: DolbyIOViewModel
    var navigationTitle: [String] = ["How To Master Track?","How To Enhance Media?","How to Transcode Media", "How to Analyze Media"]
    var body: some View {
        VStack(alignment: .leading) {
            List {
                switch viewModel.selectedAction {
                case .master:
                    Text("1. Import your file.")
                    Text("2. Select your preset.")
                    Text("3. Find the sweet spot of your track.")
                    Text("4. Listen your preview.")
                    Text("5. If you like mastered version, get the final result.")
                    Text("6. Use mastered version of your tracks as you like.")
                    
                        .navigationTitle(navigationTitle[0])
                case .enhance:
                    Text("1. Import your file.")
                    Text("2. Tap on enhance button.")
                    Text("3. Save your enhanced file.")
                    Text("3. Use your enhanced file as you like.")
                    
                        .navigationTitle(navigationTitle[1])
                case .transcode:
                    Text("1. Import your file.")
                    Text("2. Select your output type.")
                    Text("3. Tap on transcode button.")
                    Text("4. Save your transcoded file.")
                    Text("5. Use your transcoded file as you like.")
                        .navigationTitle(navigationTitle[2])
                case .analyze:
                    Text("1. Import your file.")
                        .navigationTitle(navigationTitle[3])
                default:
                    Text("1. Import your file.")
                }

                
            }
            .font(.title2)
            .bold()
            
            
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

#Preview {
    HowToView()
}
