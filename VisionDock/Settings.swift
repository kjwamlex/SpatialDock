//
//  Settings.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-06-30.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var openedSettings: observableBoolean
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button("Close Settings") {
            openedSettings.boolean = false
            dismiss()
        }
    }
}

#Preview {
    Settings()
}
