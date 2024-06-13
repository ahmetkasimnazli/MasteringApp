//
//  GlowViewModifier+Extention.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 12.06.2024.
//

import Foundation
import SwiftUI

struct Glow: ViewModifier {
    @State private var throb = false

    func body(content: Content) -> some View {
        ZStack{
            content
                .blur(radius: throb ? 25 : 5)
                .opacity(throb ? 0.8 : 0.5)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        throb = true
                    }
                }
                .onDisappear {
                    throb = false
                }
            content
        }
    }
}

extension View {
    func glow() -> some View {
        modifier(Glow())
    }
}
