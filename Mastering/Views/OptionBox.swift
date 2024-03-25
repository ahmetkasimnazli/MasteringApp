//
//  OptionBox.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 19.03.2024.
//

import SwiftUI

struct OptionBox: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .bold()
            HStack {
                Text(description)
                    .font(.custom("Helvetica Neue Italic", size: 20))
                    .frame(width: 180, height: 100, alignment: .leading)
                    .padding(.trailing)
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(10))
            }
                
        }
        .frame(width: 300, height: 150)
        .padding()
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

#Preview {
    OptionBox(title: "Music Mastering", description: "Use Music Mastering API to master your tracks.", icon: "music.quarternote.3", color: .yellow)
        .frame(width: 1000, height: 200)
}
