//
//  SettingsAvailableSystemApps.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2024-01-28.
//

import SwiftUI

struct SettingsAvailableSystemApps: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedShortcuts:[DockApp]
    @State var listOfApps:[DockApp] = []
    @State private var shortcutsSelection = Set<DockApp>()
    @State private var selection: String?
    @State private var showDuplication = false
    let fileManager = FBFileManager.init()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List(listOfApps, id: \.self, selection: $shortcutsSelection) { item in
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
                                        .cornerRadius(20)
                                case .failure(error: let error):
                                    Image("NoIcon").resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width:40, height: 40)
                                        .cornerRadius(20)
                                }
                            }
                            Text(item.name)
                        }
                    }
                    
                }
            }
            .onAppear() {
                do {
                    let data = try Data(contentsOf: fileManager.shortcutStorage)
                    let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
                    listOfApps = decodedData
                } catch {
                    
                }
            }
            .navigationTitle("Add System Apps")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        var success = true
                        
                        do {
                            let existingShortcutData = try Data(contentsOf: fileManager.userDockConfigJSON)
                            var decodedData = try JSONDecoder().decode([DockApp].self, from: existingShortcutData)
                            
                            for addApps in shortcutsSelection {
                                for existingApps in decodedData {
                                    if addApps == existingApps {
                                        success = false
                                        break
                                    }
                                }
                                if !success {
                                    break
                                }
                            }
                            
                        } catch {
                            print(error)
                        }
                        if success {
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
                            dismiss()
                        } else {
                            showDuplication = true
                        }
                        
                    } label: {
                        Text("Add Selected App")
                    }
                }
                
            }
        }.alert(isPresented: $showDuplication) {
            Alert(
                title: Text("You already added this app."),
                message: Text("Please add a different app."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

