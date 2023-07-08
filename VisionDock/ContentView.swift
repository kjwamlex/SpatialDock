//
//  ContentView.swift
//  VisionDock
//
//  Created by Joonwoo KIM on 2023-06-28.
//

import SwiftUI

struct ContentView: View {
    
    let systemApps:[String] = ["Safari", "Settings", "Files", "Photos"]
    let appsCorrespondingURL:[String : String] = ["Safari" : "x-web-search://", "Settings": UIApplication.openSettingsURLString, "Files" : "shareddocuments://", "Photos" : "photos-navigation://"]
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State var currentHour = "--"
    @State var currentMinute = "--"
    @State var currentAMorPM = ""
    @State var currentDate = ""
    @State var editDock = false
    @State private var isPresented = false
    @StateObject private var model = Model()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @EnvironmentObject var openedSettings: observableBoolean
    
    var body: some View {
        VStack {
            VStack {
                DemoDragRelocateView(editButton: $editDock)
                VStack {
                    HStack {
                        Text("\(currentHour):\(currentMinute) \(currentAMorPM)")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                            .onReceive(timer) { input in
                                currentHour = TimeManagement().getHour(twelveHourTime: false)
                                currentMinute = TimeManagement().getMinute()
                                currentAMorPM = TimeManagement().getAMorPM()
                            }
                        Text(currentDate)
                            .fontWeight(.light)
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                            .onReceive(timer) { input in
                                currentDate = TimeManagement().getDate()
                            }
                        Spacer()
                        Text("\(Int(UIDevice.current.batteryLevel * 100))%")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                        Image(systemName: "battery.100")
                            .symbolEffect(.bounce, value: 50.0)
                            .font(.system(size: 40))
                        Button("Edit") {
                            withTransaction(\.dismissBehavior, .destructive) {
                                dismissWindow(id: "settings")
                            }
                            openWindow(id: "settings")
                        }
                    }.frame(width: 500)
                        .onAppear() {
                            UIDevice.current.isBatteryMonitoringEnabled = true
                        }
                }
                .padding(5)
            }
            .padding(20)
            Spacer()
            
        }
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


struct FullScreenModalView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("This is a modal view")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
