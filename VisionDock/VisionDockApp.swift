//
//  VisionDockApp.swift
//  VisionDock
//
//  Created by Joonwoo KIM on 2023-06-28.
//

import SwiftUI

@main
struct VisionDockApp: App {
    @StateObject var openedSettings = observableBoolean()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(openedSettings)
                .frame(minWidth: 600, minHeight: 150)
        }
        
        WindowGroup("Settings", id: "settings") {
            Settings()
                .environmentObject(openedSettings)
        }
    }
}

class observableBoolean: ObservableObject {
    @Published var boolean = false
}
