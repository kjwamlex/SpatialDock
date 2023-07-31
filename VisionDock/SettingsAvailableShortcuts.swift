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
    
    var body: some View {
        Button("Dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
    }
}

#Preview {
    SettingsAvailableShortcuts()
}
