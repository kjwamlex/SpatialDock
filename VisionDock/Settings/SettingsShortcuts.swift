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
    @State private var selectedShortcuts: [DockApp] = []
    @State private var itemsInDock: [DockApp] = []
    @State var editMode: EditMode = .active
    let fileManager = FBFileManager.init()
    let reloadNotification = NotificationCenter.default.publisher(for: NSNotification.Name("reloadDockItems"))
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.defaultMinListHeaderHeight) var listHeaderHeight
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(itemsInDock, id: \.self) { item in
                        HStack {
                            Image("Photos")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:40, height: 40)
                                
                            Text(item.name)
                        }
                    }
                    .onMove { from, to in
                        itemsInDock.move(fromOffsets: from, toOffset: to)
                        do {
                            let encodedData = try? JSONEncoder().encode(itemsInDock)
                            try encodedData?.write(to: fileManager.userDockConfigJSON)
                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        } catch {
                            print(error)
                        }
                    }
                    .onDelete { offset in
                        itemsInDock.remove(atOffsets: offset)
                        do {
                            let encodedData = try? JSONEncoder().encode(itemsInDock)
                            try encodedData?.write(to: fileManager.userDockConfigJSON)
                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        } catch {
                            print(error)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                    }
                } header: {
                    Text("Added Shortcuts and Apps in Dock")
                } footer: {
                    Text("To add more shortcuts or Apps, please add more by pressing + button at top right corner.")
                }
            }
            .environment(\.editMode, $editMode)//.frame(minHeight: (minRowHeight * 6) + (3 * listHeaderHeight!))
        }
        .onReceive(reloadNotification) { _ in
            refreshList()
        }
        .onAppear {
            refreshList()
        }
        .sheet(isPresented: $showShortcuts) {
            SettingsAvailableShortcuts(selectedShortcuts: $selectedShortcuts)
                .frame(width: 500, height: 500)
        }
        .navigationTitle("Shortcuts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShortcuts.toggle()
                } label: {
                    Label("", systemImage: "plus")
                }
            }
        }
    }
    
    func refreshList() {
        do {
            let data = try Data(contentsOf: fileManager.userDockConfigJSON)
            let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
            itemsInDock = decodedData
        } catch {
            print(error)
        }
    }
}

#Preview {
    SettingsShortcuts()
}
