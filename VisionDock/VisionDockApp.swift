//
//  VisionDockApp.swift
//  VisionDock
//
//  Created by Joonwoo KIM on 2023-06-28.
//

import SwiftUI

@main
struct VisionDockApp: App {
    init() {
        //enable battery monitoring for battery level in dock
        UIDevice.current.isBatteryMonitoringEnabled = true
        //check if cacheDirectory exists, and if not make it
        let cacheDirectory = IconUtils().getDocumentsDirectory().appendingPathComponent("cache", conformingTo: .directory)
        if !FileManager.default.fileExists(atPath: cacheDirectory.absoluteString) {
            print("cache: \(cacheDirectory)")
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } else {
            
        }
    }
    @Environment(\.openWindow) var openWindow
    @State var editingShortcut = false
    @State var shortcutToEdit: DockApp = DockApp(id: "", name: "", type: .app)
    var body: some Scene {
        WindowGroup("Dock", id: "dock") {
            ContentView()
                .frame(minWidth: 600, minHeight: 150)
                .onOpenURL(perform: { url in
                    //the url contains the shortcut
                    //specifically, url.pathComponents[2] contains the shortcut.
                    //to run the shortcut, we could just do
//                    if let shortcutURL = URL(string: "shortcuts://\(url.pathComponents[2])") {
//                        if UIApplication.shared.canOpenURL(shortcutURL) {
//                            UIApplication.shared.open(shortcutURL, options: [:], completionHandler: nil)
//                        }
//                    }
                    //we would store it in DockApp as
                    if let shortcutName = url.pathComponents[2].replacingOccurrences(of: "run-shortcut?name=", with: "").removingPercentEncoding {
                        
                        let app = DockApp(id: "shortcuts://\(url.pathComponents[2])", name: shortcutName, type: .shortcut)
                        let fileManager = FBFileManager.init()
                        AppManager.addDockAppToStore(item: app, store: fileManager.shortcutStorage)
                        shortcutToEdit = app
                        editingShortcut = true
                    } else {
                        print("couldn't get shortcut name: " + (url.pathComponents[2].replacingOccurrences(of: "run-shortcut?name=", with: "").removingPercentEncoding)!)
                    }
                    
                }).sheet(isPresented: $editingShortcut, content: {
                    EditShortcutView(item: $shortcutToEdit)
                })
        }
        .windowStyle(.plain)
        .defaultSize(width: 1.5, height: 0.11, depth: 0.0, in: .meters)
        
        WindowGroup("Settings", id: "settings") {
            Settings()
        }
    }
}
