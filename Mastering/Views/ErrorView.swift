//
//  ErrorView.swift
//  Mastering
//
//  Created by Ahmet Kasım Nazlı on 17.01.2024.
//

import SwiftUI

struct ErrorView: View {
    var error: Error
    var body: some View {
        Text("\(error.localizedDescription)")
    }
}

