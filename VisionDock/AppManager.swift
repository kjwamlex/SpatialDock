//
//  AppManager.swift
//  SpatialDock
//
//  Created by Payton Curry on 8/20/23.
//
//  just some utils for adding & remove things from stores

import Foundation

class AppManager {
    static func addDockAppToStore(item: DockApp, store: URL) {
        do {
            let existingShortcutData = try Data(contentsOf: store)
            var decodedData = try JSONDecoder().decode([DockApp].self, from: existingShortcutData)
            decodedData.append(item)
            print(decodedData)
            let encodedData = try? JSONEncoder().encode(decodedData)
            try encodedData?.write(to: store)
        } catch {
            print("error adding dockapp to store \(store): \(error)")
        }
    }
    static func removeAppFromStore(item: DockApp, store: URL) {
        do {
            let existingShortcutData = try Data(contentsOf: store)
            var decodedData = try JSONDecoder().decode([DockApp].self, from: existingShortcutData)
            decodedData.removeAll { app in
                item.uuid == app.uuid
            }
            print(decodedData)
            let encodedData = try? JSONEncoder().encode(decodedData)
            try encodedData?.write(to: store)
        } catch {
            print(error)
        }
    }
    static func getAppsFromStore() -> [DockApp] {
        let dockSavedPath = FBFileManager().userDockConfigJSON
        do {
            let savedData = try Data(contentsOf: dockSavedPath)
            let decodedData = try JSONDecoder().decode([DockApp].self, from: savedData)
            return decodedData
        } catch {
            print(error)
            return []
        }
    }
}
