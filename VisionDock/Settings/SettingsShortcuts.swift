//
//  SettingsShortcuts.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI

struct SettingsShortcuts: View {
    
    // Add shortcut through Shortcuts app.
    // 1. Add a shortcut that copies shortcut URL into the app
    // 2. In the Shortcuts app, let user press our shortcut
    // 3. let them copy the shortcut to the clipboard.
    // 4. Let the app detect the clipboard content
    // 5. Ask if they want to add shortcut to the app
    // 6. Add it to the app
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    var body: some View {
        VStack {
            List {
                Text("hi")
                Text("hi")
                Text("hi")
            }.frame(minHeight: minRowHeight * 3)
        }
        .navigationTitle("Shortcuts")
    }
}

#Preview {
    SettingsShortcuts()
}
