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
    case subscription
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
                    Label("About SpatialDock", systemImage: "info.circle")
                }
                .tag(SettingsNavigation.about)
                NavigationLink(destination: SettingsFeatures()) {
                    Label("More Features", systemImage: "bubbles.and.sparkles.fill")
                }
                .tag(SettingsNavigation.MoreFeatures)
                NavigationLink(destination: SettingsShortcuts()) {
                    Label("Shortcuts", systemImage: "dock.rectangle")
                }
                .tag(SettingsNavigation.shortcuts)
                NavigationLink(destination: SettingsMessages()) {
                    Label("Messages", systemImage: "bubble.left.fill")
                }
                
                NavigationLink(destination: SettingsSubscription()) {
                    Label("Subscription", systemImage: "rays")
                }
                .tag(SettingsNavigation.messages)
                NavigationLink(destination: SettingsReset()) {
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
