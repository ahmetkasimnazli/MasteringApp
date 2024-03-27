//
//  AppPrimaryButton.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 27.03.2024.
//

import Foundation
import SwiftUI

struct AppPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(Color.white)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.green.cornerRadius(8))
    }
}
