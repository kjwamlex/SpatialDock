//
//  SettingsAddShortcutShortcut.swift
//  SpatialDock
//
//  Created by Joonwoo KIM on 2024-01-22.
//

import SwiftUI

struct SettingsManageShortcuts: View {
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
        }
    }
}
