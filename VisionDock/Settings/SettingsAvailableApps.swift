//
//  SettingsAvailableShortcuts.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2024-01-27.
//

import Foundation


/*
 
 Note:
 
 We should list the shortcuts user added here.
 
 */

import SwiftUI

struct SettingsAvailableApps: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedShortcuts:[DockApp]
    @State var listOfApps:[DockApp] = []
    @State private var shortcutsSelection = Set<DockApp>()
    @State private var selection: String?
    let fileManager = FBFileManager.init()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List(listOfApps, id: \.self, selection: $shortcutsSelection) { item in
                    if item.type == .app {
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
            }
            .onAppear() {
                do {
                    let data = try Data(contentsOf: fileManager.shortcutStorage)
                    let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
                    listOfApps = decodedData
                } catch {
                    
                }
            }
            .navigationTitle("Add Apps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
