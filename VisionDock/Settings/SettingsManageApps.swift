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
                                AsyncView {
                                    await IconUtils().getIcon(name: item.name)
                                } content: { phase in
                                    switch phase {
                                    case .loading:
                                        ProgressView().frame(width: 40, height: 40)
                                    case .success(value: let value):
                                        value
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:40, height: 40)
                                            .cornerRadius(20)
                                    case .failure(error: let error):
                                        Image("NoIcon").resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:40, height: 40)
                                    }
                                }
                                Text(item.name)
                            }
                        }
                        
                    }
                    .onDelete { offset in
                        print(listOfApps)
                        print(offset)
                        listOfApps.remove(atOffsets: offset)
                        print(listOfApps)
                        do {
                            let encodedData = try? JSONEncoder().encode(listOfApps)
                            try encodedData?.write(to: fileManager.shortcutStorage)
                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        } catch {
                            print(error)
                        }
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
                                addAppView.toggle()
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
