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
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        ScrollView(.vertical, showsIndicators: true) {
            //            VStack(alignment: .leading, spacing: 20) {
            //                Group {
            //                    HStack(alignment: .top) {
            //                        Image("Safari")
            //                            .resizable()
            //                            .scaledToFit()
            //                            .frame(width: 130, height: 130)
            //                            .cornerRadius(25)
            //                        VStack(alignment: .leading) {
            //                            Text("infiniteX3I")
            //                                .font(.largeTitle)
            //                                .fontWeight(.bold)
            //                            
            //                            HStack {
            //                                Text("3.0")
            //                                    .font(.title3)
            //                                Image(systemName: "chevron.right")
            //                                    .foregroundColor(Color(.systemGray4))
            //                            }
            //                        }.padding()
            //                        Spacer()
            //                    }.padding(40.0)
            //                }
            //                
            //                
            //            }
            //            
            //            
            //
            //        }
            
            //        Table(stuff) {
            //            TableColumn("", value: \.settingsOption)
            //        }
            VStack {
                Group {
                    HStack(alignment: .top) {
                        Image("Safari")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .cornerRadius(25)
                        VStack(alignment: .leading) {
                            Text("infiniteX3I")
                                .font(.largeTitle) //xrOS gets extraLargeTitle
                                .fontWeight(.bold)
                            
                            HStack {
                                Text("Version 3.0")
                                    .font(.title3)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(.systemGray4))
                            }
                        }.padding()
                        Spacer()
                    }.padding(40.0)
                }
            }
            
            List {
                Text("hi")
                Text("hi")
                Text("hi")
                Toggle("Option Example", isOn: $optionExample)
            }.frame(minHeight: minRowHeight * 4)
        }
        .navigationTitle("About")
    }
}

#Preview {
    SettingsAbout()
}
