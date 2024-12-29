//
//  AheadCalApp.swift
//  AheadCal
//
//  Created by Zhichao Feng on 2024/12/29.
//

import SwiftUI

@main
struct AheadCalApp: App {

    var body: some Scene {
        MenuBarExtra("Calendar", systemImage: "calendar") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
