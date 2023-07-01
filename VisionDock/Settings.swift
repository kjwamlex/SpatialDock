//
//  Settings.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-06-30.
//

import SwiftUI

enum SettingsNavigation {
    case about
}

struct Settings: View {
    @EnvironmentObject var openedSettings: observableBoolean
    @Environment(\.dismiss) var dismiss
    @State var selectedNavigation: Set<SettingsNavigation>?
    
    var body: some View {
        
        NavigationSplitView {
//            Button("Close Settings") {
//                openedSettings.boolean = false
//                dismiss()
//            }
//            
            List(selection: $selectedNavigation) {
                NavigationLink(destination: SettingsAbout()) {
                    Label("About infiniteX3I", systemImage: "info.circle")
                }
                .tag(SettingsNavigation.about)
                .onAppear() {
                    selectedNavigation = [.about]
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        openedSettings.boolean = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    
                }
            }
            
        } detail: {
            SettingsAbout()
        }
    }
}

#Preview {
    Settings()
}
