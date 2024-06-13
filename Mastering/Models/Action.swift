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
    var action: ActionType
}

let actions: [Action] = [
    Action(title: "Music Mastering", description: "Select Music Mastering to master your tracks.", icon: "music.quarternote.3", color: .indigo, action: .master),
    Action(title: "Enhance Media", description: "Select Enhance to enhance your audio.", icon: "wand.and.stars.inverse", color: .purple, action: .enhance),
    Action(title: "Transcode Media", description: "Select Transcode to change your file type.", icon: "rectangle.2.swap", color: .teal, action: .transcode),
    Action(title: "Analyze Media", description: "Select Analyze to analyze your audio.", icon: "waveform.badge.magnifyingglass", color: .pink, action: .analyze),
]

enum ActionType {
    case master, enhance, transcode, analyze
}

