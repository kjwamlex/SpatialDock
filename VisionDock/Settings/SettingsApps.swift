//
//  SettingsApps.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI

struct SettingsApps: View {
    // Apple Apps
    //https://medium.com/@contact.jmeyers/complete-list-of-ios-url-schemes-for-apple-apps-and-services-always-updated-800c64f450f

    // Third Party Apps
    // https://medium.com/@contact.jmeyers/complete-list-of-ios-url-schemes-for-third-party-apps-always-updated-5663ef15bdff
    
    // iOS Settings
    // https://medium.com/@contact.jmeyers/complete-list-of-ios-url-schemes-for-apple-settings-always-updated-20871139d72f
    
    
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
        .navigationTitle("Apps")
    }
}

#Preview {
    SettingsApps()
}
