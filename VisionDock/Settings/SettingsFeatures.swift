//
//  SettingsFeatures.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI

struct SettingsFeatures: View {
    
    // Extra Subscription Features:
    // More than 5 shortcuts
    // More than 5 apps on the dock
    // Now Playing Widget
    
    @State private var optionExample = true
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    var body: some View {
        VStack {
            List {
                Toggle("Option Example", isOn: $optionExample)
                Toggle("Option Example", isOn: $optionExample)
                Toggle("Option Example", isOn: $optionExample)
                Toggle("Option Example", isOn: $optionExample)
            }.frame(minHeight: minRowHeight * 4)
        }
        .navigationTitle("More Features")
    }
}

#Preview {
    SettingsFeatures()
}
