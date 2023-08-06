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
        //enable battery monitoring for battery level in dock
        UIDevice.current.isBatteryMonitoringEnabled = true
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
                        do {
                            let existingShortcutData = try Data(contentsOf: fileManager.shortcutStorage)
                            var decodedData = try JSONDecoder().decode([DockApp].self, from: existingShortcutData)
                            decodedData.append(app)
                            print(decodedData)
                            let encodedData = try? JSONEncoder().encode(decodedData)
                            try encodedData?.write(to: fileManager.shortcutStorage)
                        } catch {
                            print(error)
                        }
                    } else {
                        print("couldn't get shortcut name: " + (url.pathComponents[2].replacingOccurrences(of: "run-shortcut?name=", with: "").removingPercentEncoding)!)
                    }
                    
                })
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
