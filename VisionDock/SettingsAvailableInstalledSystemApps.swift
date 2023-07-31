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
    var body: some View {
        Button("Dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
    }
}

