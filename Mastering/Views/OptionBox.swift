//
//  OptionBox.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 19.03.2024.
//

import SwiftUI

struct OptionBox: View {
    var action: Action
    var body: some View {
        HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(action.title)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(action.description)
                        .font(.body)
                }
                Divider()
                .frame(maxHeight: 80)
                .bold()
                .background(.white)
                Image(systemName: action.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            .padding(30)
            .frame(maxWidth: .infinity, minHeight: 180)
            .foregroundColor(.white)
            .background(.linearGradient(.init(colors: [action.color.opacity(0.5), action.color]), startPoint: .top, endPoint: .bottom))
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(radius: 5)
            .padding(.horizontal)
        
    }
}

#Preview {
    OptionBox(action: actions[1])
}
