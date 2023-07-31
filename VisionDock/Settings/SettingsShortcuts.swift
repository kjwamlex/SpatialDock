//
//  SettingsShortcuts.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI

struct SettingsShortcuts: View {
    
    // Add shortcut through Shortcuts app.
    // 1. Add a shortcut that copies shortcut URL into the app
    // 2. In the Shortcuts app, let user press our shortcut
    // 3. let them copy the shortcut to the clipboard.
    // 4. Let the app detect the clipboard content
    // 5. Ask if they want to add shortcut to the app
    // 6. Add it to the app
    
    // We can look into "Add shortcuts" in "Launcher" app on the App Store.
    
    @State private var showSystemApps = false
    @State private var showShortcuts = false
    @State private var selectedSystemApps: [String] = []
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.defaultMinListHeaderHeight) var listHeaderHeight
    var body: some View {
        VStack {
            List {
                Section {
                    Text("Safari")
                    Text("Photos")
                    Text("Settings")
                } header: {
                    Text("Added System Apps")
                }
                
                Section {
                    Text("Shortcut 1")
                    Text("Shortcut 2")
                    Text("Shortcut 3")
                } header: {
                    Text("Shortcuts")
                } footer: {
                    Text("To add more shortcuts, please add more by pressing + button at top right corner.")
                }
            }//.frame(minHeight: (minRowHeight * 6) + (3 * listHeaderHeight!))
        }
        .sheet(isPresented: $showSystemApps) {
            SettingsAvailableInstalledSystemApps(selectedApps: $selectedSystemApps)
                .frame(width: 1000, height: 1000)
        }
        .sheet(isPresented: $showShortcuts) {
            SettingsAvailableShortcuts(selectedShortcuts: $selectedSystemApps)
                .frame(width: 1000, height: 400)
        }
        .navigationTitle("Shortcuts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                
                Menu {
                    Section("Add...") {
                        Button("Apps") {
                            showSystemApps.toggle()
                        }
                        
                        
                        Button("Shortcuts") {
                            showShortcuts.toggle()
                        }
                        
                    }
                } label: {
                    Label("", systemImage: "plus")
                }
                
                
            }
        }
    }
    
    func addShortcuts() {
        
    }
    
    func addApps() {
        
    }
}

#Preview {
    SettingsShortcuts()
}
