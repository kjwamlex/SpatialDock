//
//  Settings.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-06-30.
//

import SwiftUI

enum SettingsNavigation {
    case about
    case MoreFeatures
    case apps
    case shortcuts
    case messages
    case reset
}

struct Settings: View {
    @EnvironmentObject var openedSettings: observableBoolean
    @Environment(\.dismiss) var dismiss
    @State var selectedNavigation: Set<SettingsNavigation> = [.about]
    
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
                NavigationLink(destination: SettingsAbout()) {
                    Label("Subscription", systemImage: "bubbles.and.sparkles.fill")
                }
                .tag(SettingsNavigation.MoreFeatures)
                NavigationLink(destination: SettingsAbout()) {
                    Label("Apps", systemImage: "dock.rectangle")
                }
                .tag(SettingsNavigation.apps)
                NavigationLink(destination: SettingsAbout()) {
                    Label("Shortcuts", systemImage: "arrow.up.left")
                }
                .tag(SettingsNavigation.shortcuts)
                NavigationLink(destination: SettingsAbout()) {
                    Label("Messages", systemImage: "bubble.left.fill")
                }
                .tag(SettingsNavigation.messages)
                NavigationLink(destination: SettingsAbout()) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .tag(SettingsNavigation.reset)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
