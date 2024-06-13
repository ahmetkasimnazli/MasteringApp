//
//  Transcode.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 11.05.2024.
//

import Foundation

enum Transcode: String, CaseIterable, Identifiable {
    case mp3 = "mp3"
    case wav = "wav"
    case aac = "aac"
    case ogg = "ogg"
    
    var id: String { self.rawValue }
}


