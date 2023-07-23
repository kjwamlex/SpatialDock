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
    init() {
        //check if cacheDirectory exists, and if not make it
        let cacheDirectory = IconUtils().getDocumentsDirectory().appendingPathComponent("cache", conformingTo: .directory)
        var directory: ObjCBool = true //weird FileManager stuff
        FileManager.default.fileExists(atPath: cacheDirectory.absoluteString, isDirectory: &directory)
        if !directory.boolValue {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } else {
        }
    }
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
