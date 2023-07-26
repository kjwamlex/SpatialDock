//
//  SettingsAbout.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI

struct SettingsOption: Identifiable {
    let settingsOption: String
    let id = UUID()
}


struct SettingsAbout: View {
    @State private var stuff = [SettingsOption(settingsOption: "hi"),
                                SettingsOption(settingsOption: "hello"),
                                SettingsOption(settingsOption: "hello"),
                                SettingsOption(settingsOption: "hello")]
    @State private var optionExample = true
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    var body: some View {
        VStack {
            Group {
                HStack(alignment: .top) {
                    Image("Safari")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .cornerRadius(25)
                    VStack(alignment: .leading) {
                        Text("VisionDock")
                            .font(.extraLargeTitle)
                            .fontWeight(.bold)
                        HStack {
                            Text("Version 1.0")
                                .font(.title3)
                        }
                    }.padding()
                    Spacer()
                }.padding(20.0)
            }
            List {
                Section {
                    SettingsGroupRow(title: "Lead Developer", detail:"Joonwoo Kim (@iOS_App_Dev)", link: "https://twitter.com/iOS_App_Dev")
                    SettingsGroupRow(title: "Developer", detail: "Payton (@paytondev)", link: "https://twitter.com/paytondev")
                    
                } header: {
                    Text("Developers")
                }
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    SettingsAbout()
}


struct SettingsGroupRow: View {
    @State var title: String
    @State var detail: String
    @State var link: String?
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            Spacer()
            Text(detail)
            if (link != nil) {
                Link(destination: URL(string: link!)!) {
                    Image(systemName: "arrow.up.right.square")
                }
            }
        }
        
    }
}
