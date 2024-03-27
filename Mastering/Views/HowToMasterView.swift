//
//  HowToMasterView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 26.03.2024.
//

import SwiftUI

struct HowToMasterView: View {
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Text("1. Import your file.")
                Text("2. Select your preset.")
                Text("3. Find the sweet spot of your track.")
                Text("4. Listen your preview.")
                Text("5. If you like mastered version, get the final result.")
                Text("6. Use mastered version of your tracks as you like.")
                
                
            }
            .font(.title)
            .bold()
        }
    }
}

#Preview {
    HowToMasterView()
}
