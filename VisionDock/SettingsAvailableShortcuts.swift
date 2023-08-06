//
//  SettingsAvailableShortcuts.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2023-07-31.
//


/*
 
 Note:
 
 We should list the shortcuts user added here.
 
 */

import SwiftUI

struct SettingsAvailableShortcuts: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedShortcuts:[DockApp]
    @State var listOfShortcuts:[DockApp] = []
    @State private var shortcutsSelection = Set<DockApp>()
    @State private var selection: String?
    let fileManager = FBFileManager.init()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List(listOfShortcuts, id: \.self, selection: $shortcutsSelection) { appName in
                    Text(appName.name)
                }
            }
            .onAppear() {
                do {
                    let data = try Data(contentsOf: fileManager.shortcutStorage)
                    let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
                    listOfShortcuts = decodedData
                } catch {
                    
                }
            }
            .navigationTitle("Add Imported Shortcuts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        do {
                            let existingShortcutData = try Data(contentsOf: fileManager.userDockConfigJSON)
                            var decodedData = try JSONDecoder().decode([DockApp].self, from: existingShortcutData)
                            
                            for addApps in shortcutsSelection {
                                decodedData.insert(addApps, at: 0)
                            }
                            
                            let encodedData = try? JSONEncoder().encode(decodedData)
                            try encodedData?.write(to: fileManager.userDockConfigJSON)
                        } catch {
                            print(error)
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        
                        print(shortcutsSelection)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
