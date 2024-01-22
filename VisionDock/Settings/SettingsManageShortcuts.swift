//
//  SettingsManageShortcuts.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2024-01-22.
//

import SwiftUI

struct SettingsManageShortcuts: View {
    @State private var shortcutsSelection = Set<DockApp>()
    @State var listOfShortcuts:[DockApp] = []
    @State var editMode: EditMode = .active
    let fileManager = FBFileManager.init()
    
    var body: some View {
        VStack {
            Text("If you accidentally removed Shortcut to import shortcuts to VisionDock, please click on the button below to add it back.")
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(width: 500)
            Button(action: {
                UIApplication.shared.open(URL(string: "https://www.icloud.com/shortcuts/084fb7f2733c4c13af722022c198541a")!)
            }, label: {
                Text("Add Shortcut for importing Shortcuts")
            })
            
            VStack {
                Spacer()
                List {
                    Section {
                        ForEach(listOfShortcuts, id: \.self) { item in
                            if item.type == .shortcut {
                                HStack {
                                    Text(item.name)
                                }.contextMenu {

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
                        Text("Imported Shortcuts")
                    } footer: {
                        Text("To add more shortcuts or Apps, please add more by pressing + button at top right corner.")
                    }
                }
                .environment(\.editMode, $editMode)
                
                
            }.onAppear() {
                do {
                    let data = try Data(contentsOf: fileManager.shortcutStorage)
                    let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
                    listOfShortcuts = decodedData
                } catch {
                    
                }
            }
        }
    }
}
