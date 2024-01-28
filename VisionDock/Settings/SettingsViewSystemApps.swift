//
//  SettingsViewSystemApps.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2024-01-28.
//

import SwiftUI

struct SettingsViewSystemApps: View {
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
                        if item.type == .system {
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
                } header: {
                    Text("Available System Apps")
                } footer: {
                    Text("More system apps will be available here through future updates. If you need to open another system app, please add them through Shortcuts for now.")
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
            .sheet(isPresented: $addAppView, content: {
                AddNewAppModal()
            })
        }
    }
}

