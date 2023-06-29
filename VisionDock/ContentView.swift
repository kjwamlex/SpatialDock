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
    
    var body: some View {
        VStack {
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
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }.padding(5)
                            .buttonStyle(.borderless)
                            .buttonBorderShape(.circle)
                            //Text(app)
                        }.frame(height:130)
                    }
                }
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
                    }.frame(width: 500)
                        .onAppear() {
                            UIDevice.current.isBatteryMonitoringEnabled = true
                        }
                }
                .padding(5)
            }
            .padding(10)
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



class TimeManagement: NSObject {
    
    func getDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        let day = String(describing: calendar.component(.day, from: date))
        //let year = String(describing: calendar.component(.year, from: date))
        
        let monthFormatted = date.getFormattedDate(format: "MMM")
        let dayFormatted = date.getFormattedDate(format: "EEE")
        
        return dayFormatted + " " + monthFormatted + " " + day
    }
    
    func getAMorPM() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        var hoursSinceStartOfDay = floor((currentTime - startOfDay) / 3600)
        
        return hoursSinceStartOfDay >= 12 ? "PM" : "AM"
    }
    
    func getHour(twelveHourTime: Bool) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        var hoursSinceStartOfDay = floor((currentTime - startOfDay) / 3600)
        
        if !twelveHourTime {
            if hoursSinceStartOfDay > 12 {
                hoursSinceStartOfDay -= 12
            }
        }
        
        return String(Int(hoursSinceStartOfDay))
    }
    
    func getMinute() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        let hoursSinceStartOfDay = floor((currentTime - startOfDay) / 3600)
        let minuteSinceHour = ((currentTime - startOfDay - (hoursSinceStartOfDay * 3600)) / 60)
        if minuteSinceHour < 10 {
            return "0" + String(Int(minuteSinceHour))
        }
        
        
        return String(Int(minuteSinceHour))
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
