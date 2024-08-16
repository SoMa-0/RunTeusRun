//
//  GameOverView.swift
//  RetoSpriteKit
//
//  Created by Ricardo Jorge Rodriguez Trevino on 13/08/24.
//

import SwiftUI

struct GameOverView: View {
    var body: some View {
        ZStack {
            Image("blueBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .offset(y: -25)
        }
    }
}

#Preview {
    GameOverView()
}
