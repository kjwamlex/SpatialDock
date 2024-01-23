//
//  SettingsManageApps.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2024-01-22.
//

import SwiftUI

struct SettingsManageApps: View {
    @State var listOfApps:[DockApp] = []
    @State private var shortcutsSelection = Set<DockApp>()
    @State var editMode: EditMode = .active
    @State private var addAppView = false
    @Environment(\.openWindow) var openWindow
    
    let fileManager = FBFileManager.init()
    var body: some View {
        VStack {
            Spacer()
            List {
                Section {
                    ForEach(listOfApps, id: \.self) { item in
                        if item.type == .shortcut {
                            HStack {
                                Text(item.name)
                            }.contextMenu {
                                //                                Button("Edit") {
                                //                                    itemBeingEdited = item
                                //                                    editingShortcutView.toggle()
                                //                                }
                            }
                        }
                        
                    }
                    .onDelete { offset in
                        //                            listOfShortcuts.remove(atOffsets: offset)
                        //                            do {
                        //                                let encodedData = try? JSONEncoder().encode(listOfShortcuts)
                        //                                try encodedData?.write(to: fileManager.shortcutStorage)
                        //                                NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        //                            } catch {
                        //                                print(error)
                        //                            }
                        //                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                    }
                } header: {
                    Text("Added Apps")
                } footer: {
                    Text("To add more shortcuts or Apps, please add more by pressing + button at top right corner.")
                }
                
                
            }
            .navigationTitle("Manage Apps")
            .environment(\.editMode, $editMode)
            .onAppear() {
                do {
                    let data = try Data(contentsOf: fileManager.shortcutStorage)
                    let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
                    listOfApps = decodedData
                } catch {
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if StoreController.shared.purchased.isEmpty {
                            if (AppManager.getAppsFromStore().count - 4) < 4 {
                                addAppView.toggle()
                            } else {
                                openWindow(id: "productsview")
                            }
                        } else {
                            addAppView.toggle()
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })

                }
            }
            .sheet(isPresented: $addAppView, content: {
                AddNewAppModal()
            })
        }
    }
}
