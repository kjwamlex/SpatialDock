//
//  SettingsAvailableInstalledSystemApps.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2023-07-31.
//

/*
 
 Note:
 
 We can have a list of system and installed apps.
 
 We can use URL Scheme to find if they can be opened or not to see if they are intsalled.
 
 
 
 */

import SwiftUI

struct SettingsAvailableInstalledSystemApps: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedApps:[String]
    @State var listOfApps:[String] = ["Safari", "Messages", "Settings", "Photos"]
    @State private var appSelection = Set<String>()
    @State private var selection: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List(listOfApps, id: \.self, selection: $appSelection) { appName in
                    Text(appName)
                }
            }
            .navigationTitle("Add Shortcuts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print(appSelection)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

