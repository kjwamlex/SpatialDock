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
    @Binding var selectedShortcuts:[String]
    @State var listOfShortcuts:[String] = ["Safari", "Messages", "Settings", "Photos"]
    @State private var shortcutsSelection = Set<String>()
    @State private var selection: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List(listOfShortcuts, id: \.self, selection: $shortcutsSelection) { appName in
                    Text(appName)
                }
            }
            .navigationTitle("Add System Apps")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
