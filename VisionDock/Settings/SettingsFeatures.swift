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
    @State var editMode: EditMode = .active
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @State var widgets:[String] = ["Time", "Date", "Battery"]
    @State var widgetOptions:[String:Bool] = [:]
    
    var body: some View {
        VStack {
            List {
                
                ForEach(widgets, id: \.self) { item in
                    HStack {
                        WidgetToggle(widgetID: item)
                    }
                }
                .onMove { from, to in
                    widgets.move(fromOffsets: from, toOffset: to)
                    UserDefaults.standard.set(widgets, forKey: "widgetOrder")
                    NotificationCenter.default.post(name: NSNotification.Name("refreshWidget"), object: nil, userInfo: nil)
                }
            }
            .environment(\.editMode, $editMode)
            .onAppear() {
                for widget in widgets {
                    widgetOptions.removeAll()
                    var option = UserDefaults.standard.bool(forKey: widget)
                    widgetOptions[widget] = option
                }
            }
        }
        .navigationTitle("More Features")
    }
}

#Preview {
    SettingsFeatures()
}

struct WidgetToggle: View {
    
    var widgetID: String
    @State private var widgetToggle = false
    
    var body: some View {
        VStack(spacing: 0) {
            Toggle(widgetID, isOn: $widgetToggle)
                .onChange(of: widgetToggle) {
                    UserDefaults.standard.set(widgetToggle, forKey: widgetID)
                    NotificationCenter.default.post(name: NSNotification.Name("refreshWidget"), object: nil, userInfo: nil)
                }
                .onAppear() {
                    var widgetSetting = UserDefaults.standard.bool(forKey: widgetID)
                    widgetToggle = widgetSetting
                }
        }
        .padding(.horizontal)
    }
}
