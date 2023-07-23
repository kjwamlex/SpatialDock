//
//  IconUtils.swift
//  SpatialDock
//
//  Created by Payton Curry on 7/23/23.
//

import Foundation
import SwiftUI

//retrieve & cache files from image server

class IconUtils: NSObject {
    //if forceImageRequest is on, the app will send a request to the server even for system apps that are included in the app or cached locally. not on by default because there's really no need for it other than debugging
    func getIcon(name: String, endpoint: URL = URL(string: "http://localhost:3000")!, forceImageRequest: Bool = false, _ completion: @escaping (Image) -> Void) {
//        print("getting icon for \(name)")
        let systemApps:[String] = ["Safari", "Settings", "Files", "Photos"]
        if !forceImageRequest && systemApps.contains(name) {
            completion(Image(name))
            return
        }
        var image = Image("NoIcon")
        if !forceImageRequest && checkIfInCache(appName: name.lowercased()) {
//            print("\(name) is cached! using it")
            let path = self.getCachePath(appName: name)
            let imgData = try? Data(contentsOf: path)
            if imgData == nil {
                completion(image)
                return
            }
            image = Image(uiImage: UIImage(data: imgData!)!)
            completion(image)
            return
        }
        var request = URLRequest(url: endpoint.appendingPathComponent("/image"))
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(IconRequest(name: name))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            if err != nil {
                print("there was an error getting \(name) icon: \(err!.localizedDescription)")
                completion(image)
                return
            }
            if let data = data {
                let response = try! JSONDecoder().decode(IconResponse.self, from: data)
                if !response.found {
//                    print("No image found for \(name). using default")
                    completion(image)
                    return
                }
//                print("Got image for \(name)! using it!")
                let imgData = Data(base64Encoded: response.image!)!
                image = Image(uiImage: UIImage(data: imgData)!)
                
                let cacheDirectory = self.getCachePath(appName: name.lowercased())
//                print("writing \(name) to cache at \(cacheDirectory.absoluteString)")
                do {
                    do {
                        try FileManager.default.removeItem(at: cacheDirectory)
                    } catch {
                        print("error removing \(name).png: \(error)")
                    }
                    try imgData.write(to: cacheDirectory, options: .noFileProtection)
//                    print("successfully wrote \(name) to cache at \(cacheDirectory.absoluteString)")
                } catch {
                    print("there was an error writing \(name) to cache: \(error)")
                }
            }
            completion(image)
        }.resume()
    }
    //checks if app icon is in local cache & if it should be updated. returns true if it's cached, returns false if needs to be downloaded
    private func checkIfInCache(appName: String) -> Bool {
//        print("checking \(appName) cache status")
        let path = self.getCachePath(appName: appName)
        
        if doesFileExist(url: path) {
//            print("\(path.absoluteString) exists!")
            let imgAttributes = try? FileManager.default.attributesOfItem(atPath: path.path()) as NSDictionary
            //checks if file is less than 30 days old. if so, we're good to go!
            if imgAttributes == nil {
//                print("imgAttributes nil!")
                return false
            }
            if imgAttributes!.fileCreationDate()!.timeIntervalSince(Date()) < ((60*60)*24)*30 {
//                print("\(appName) is less than 30 days old! \(-imgAttributes!.fileCreationDate()!.timeIntervalSince(Date())), \(((60*60)*24)*30)")
                return true
            } else {
//                print("\(appName) is more than 30 days old.")
                return false
            }
        } else {
//            print("\(appName) cache record does NOT exist! \(path.path())")
        }
        return false
    }
    private func getCachePath(appName: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent("cache", conformingTo: .directory).appendingPathComponent("\(appName.lowercased())", conformingTo: .png)
    }
    //just returns app documents directory. makes life so much easier
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func doesFileExist(url: URL) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: url.path())
    }
}

extension IconUtils: FileManagerDelegate {
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAt path: URL) -> Bool {
        return true
    }
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, removingItemAt URL: URL) -> Bool {
        return true
    }
    
}
struct IconRequest: Codable {
    var name: String
}
struct IconResponse: Codable {
    var found: Bool
    var name: String
    var image: String?
}
