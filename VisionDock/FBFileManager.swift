//
//  FBFileManager.swift
//  SpatialDock
//
//  Created by Joonwoo Kim on 2022/03/01.
//


import UIKit

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

class FBFileManager {
    var fileManager: FileManager
    var mainPath: URL
    var userDockConfigJSON: URL
    var shortcutStorage: URL
    var shortcutImageStorage: URL
    var userCustomDockSystemAppImageStorage: URL
    
    init() {
        self.fileManager = FileManager.default
        self.mainPath = self.fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("SpatialDock")
        self.userDockConfigJSON = self.mainPath.appendingPathComponent("SpatialDockSaved.json")
        self.shortcutStorage = self.mainPath.appendingPathComponent("SpatialDockImportedShortcuts.json")
        self.shortcutImageStorage = self.mainPath.appendingPathComponent("SpatialDockShortcutImage")
        self.userCustomDockSystemAppImageStorage = self.mainPath.appendingPathComponent("SpatialDockSystemAppImage")
    }
    
    func createBasicDirectory() {
        self.createFolder(name: "SpatialDock", atPath: self.fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0])
        self.createFolder(name: "SpatialDockShortcutImage", atPath: self.mainPath)
        self.createFolder(name: "SpatialDockSystemAppImage", atPath: self.mainPath)
    }
    
    func createFolder(name: String, atPath: URL) {
        if !self.fileManager.fileExists(atPath: atPath.appendingPathComponent(name).path) {
            do {
                try fileManager.createDirectory(atPath: atPath.appendingPathComponent(name).path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create folder")
            }
        }
    }
    
    func removeItem(atPath: URL) {
        if self.fileManager.fileExists(atPath: atPath.path) {
            do {
                try fileManager.removeItem(at: atPath)
            } catch {
                print("Failed to remove Item")
            }
        }
    }
    
    func renameItem(oldName: String, newName: String, atPath: URL) {
        if self.fileManager.fileExists(atPath: atPath.appendingPathComponent(oldName).path) {
            do {
                try self.fileManager.moveItem(at: atPath.appendingPathComponent(oldName), to: atPath.appendingPathComponent(newName))
            } catch {
                print("Failed to rename an item")
            }
        }
    }
    
    func createFile(name: String, atPath: URL) {
        if !self.fileManager.fileExists(atPath: atPath.appendingPathComponent(name).path) {
            self.fileManager.createFile(atPath: atPath.appendingPathComponent(name).path, contents: nil)
        }
    }
    
//    func addFileFromOtherApps(from: URL) {
//        do {
//            let fileName = from.lastPathComponent
//            try self.fileManager.copyItem(at: from, to: self.documentsPath.appendingPathComponent(fileName))
//        } catch {
//            print(error)
//        }
//    }
    
    func moveItem(oldPath: URL, newPath: URL) {
        do {
            try self.fileManager.moveItem(at: oldPath, to: newPath.appendingPathComponent(oldPath.lastPathComponent))
        } catch {
            print("Failed to move an item")
        }
    }
    
    func copyItem(oldPath: URL, newPath: URL) {
        do {
            try self.fileManager.copyItem(at: oldPath, to: newPath.appendingPathComponent(oldPath.lastPathComponent))
        } catch {
            print(error)
            print("Failed to copy an item")
        }
    }
    
    func isDirectory(atPath: URL) -> Bool {
        return atPath.isDirectory
    }
    
    func getList(atPath: URL) -> [URL] {
        var tmp: [URL] = [URL]()
        
        do {
            let dir = try self.fileManager.contentsOfDirectory(at: atPath, includingPropertiesForKeys: nil)
            for f in dir {
                tmp.append(f)
            }
            return tmp
        } catch {
            return tmp
        }
    }
    
    func getListOfDirectories(atPath: URL) -> [URL] {
        var tmp: [URL] = [URL]()
        
        do {
            let dir = try self.fileManager.contentsOfDirectory(at: atPath, includingPropertiesForKeys: nil)
            for f in dir {
                if f.isDirectory {
                    tmp.append(f)
                }
            }
            return tmp
        } catch {
            return tmp
        }
    }
    
    func validateFilename(atPath: URL, name: String, withExtension: String? = "") -> String {
        var tmp = name
        var count = 1
        
        while (self.fileManager.fileExists(atPath: atPath.appendingPathComponent((withExtension != "") ? tmp + "." + withExtension! : tmp).path)) {
            count += 1
            tmp = "\(name) \(count)"
        }
        
        return tmp
    }
    
}
