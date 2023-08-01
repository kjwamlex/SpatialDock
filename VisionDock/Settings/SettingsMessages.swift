//
//  SettingsMessages.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI

struct SettingsMessages: View {
    
    // Two ways:
    // 1. Shortcuts
    // 2. URL Scheme. Most likely to use URL Scheme for simplicity.
    
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    var body: some View {
        VStack {
            List {
                Text("hi")
                Text("hi")
                Text("hi")
            }.frame(minHeight: minRowHeight * 3)
        }
        .navigationTitle("Messages")
    }
}

#Preview {
    SettingsMessages()
}


/*
func phone(phoneNum: String) {
    if let url = URL(string: "tel://\(phoneNum)") {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
*/
