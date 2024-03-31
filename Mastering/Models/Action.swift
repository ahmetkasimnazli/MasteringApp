//
//  Action.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 29.03.2024.
//

import Foundation
import SwiftUI

struct Action: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var color: Color
    var destination: ContentView
    var action: String
}

let actions: [Action] = [
    Action(title: "Music Mastering", description: "Select Music Mastering to master your tracks.", icon: "music.quarternote.3", color: .indigo, destination: ContentView(), action: "master"),
    Action(title: "Enhance Media", description: "Select Enhance to enhance your audio.", icon: "wand.and.stars.inverse", color: .purple, destination: ContentView(), action: "enhance"),
    Action(title: "Transcode Media", description: "Select Transcode to change your file type.", icon: "rectangle.2.swap", color: .teal, destination: ContentView(), action: "transcode"),
    Action(title: "Analyze Media", description: "Select Analyze to analyze your audio.", icon: "waveform.badge.magnifyingglass", color: .pink, destination: ContentView(), action: "analyze"),
]

