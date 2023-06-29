//
//  ContentView.swift
//  VisionDock
//
//  Created by Joonwoo KIM on 2023-06-28.
//

import SwiftUI

struct ContentView: View {
    
    let systemApps:[String] = ["Safari", "Settings", "Files"]
    let appsCorrespondingURL:[String : String] = ["Safari" : "x-web-search://", "Settings": UIApplication.openSettingsURLString, "Files" : "shareddocuments://"]
    var body: some View {
        VStack {
            HStack {
                ForEach(systemApps, id: \.self) { app in
                    VStack {
                        Button {
                            if let url = URL(string: appsCorrespondingURL[app] ?? "") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else {
                                    print("cant")
                                }
                            }
                        } label: {
                            Image(app)
                        }
                        .buttonStyle(.borderless)
                        .buttonBorderShape(.circle)
                        Text(app)
                    }
                }
            }
        }
        .padding(10)
        Spacer()
        //VStack {
            // Photos app - photos-navigation://
            // Maps app - map://
            // Safari - x-web-search://
            // Files - shareddocuments://
            // Home - homeutil://
            // News - applenews://
            // Shortcuts - pocketapp36486://
    }
}

#Preview {
    ContentView()
}
