//
//  TabletopGameApp.swift
//  TabletopGame
//
//  Created by 林湘羚 on 2021/3/10.
//

import SwiftUI

@main
struct TabletopGameApp: App {
    var body: some Scene {
        let game=Game()
        WindowGroup {
            ContentView(game:game, player:game.player)
        }
    }
}
