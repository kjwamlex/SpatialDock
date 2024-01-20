//
//  DragAndDrop.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-07.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct DockApp: Codable, Identifiable, Equatable, Hashable {
    var uuid: UUID = UUID()
    var id: String //deep link
    var name: String
    var type: ShortcutType
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

enum ShortcutType: Int, Codable {
    case shortcut = 1, contact, system, app
}

//MARK: - Model

class Model: ObservableObject {
    @Published var data: [DockApp]
    
    // For each of the name, add prefix
    // Shortcuts Prefix:  SHORTCUTS::
    // Contact Prefix:    CONTACT::
    // System App Prefix: SYSTEM::
    
    // There should be a better way of organizing this...
    
    var systemApps: [DockApp] = [.init(id: "x-web-search://", name: "Safari", type: .system),
                                 .init(id: UIApplication.openSettingsURLString, name: "Settings", type: .system),
                                 .init(id: "shareddocuments://", name: "Files", type: .system),
                                 .init(id: "photos-navigation://", name: "Photos", type: .system)]
    
    let fileManager = FBFileManager.init()

    let columns = [
        GridItem(.flexible(minimum: 80, maximum: 80))
    ]
    let widgets:[String] = ["Time", "Date", "Battery"]

    init() {
        data = []
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedRefreshNotification(notification:)), name: Notification.Name("reloadDockItems"), object: nil)
                                               
        let dockSavedPath = fileManager.userDockConfigJSON
        print(dockSavedPath)
        if !fileManager.fileManager.fileExists(atPath: dockSavedPath.relativePath) {
            print("file does not exist")
            data = systemApps
            fileManager.createBasicDirectory()
            fileManager.createFile(name: "SpatialDockSaved.json", atPath: dockSavedPath)
            fileManager.createFile(name: "SpatialDockImportedShortcuts.json", atPath: fileManager.mainPath)
            
            for widget in widgets {
                UserDefaults.standard.set(true, forKey: widget)
            }
            
            UserDefaults.standard.set(widgets, forKey: "widgetOrder")
            
            do {
                let encodedData = try? JSONEncoder().encode(data)
                try encodedData?.write(to: dockSavedPath)
                
                let emptyArray:[DockApp] = []
                let encodedDataForImports = try? JSONEncoder().encode(emptyArray)
                try encodedDataForImports?.write(to: fileManager.shortcutStorage)
                
            } catch {
                print(error)
            }
            return
        }
        refreshData()
        
    }
    
    @objc func receivedRefreshNotification(notification: NSNotification) {
        refreshData()
    }
    
    func refreshData() {
        let dockSavedPath = fileManager.userDockConfigJSON
        do {
            let savedData = try Data(contentsOf: dockSavedPath)
            let decodedData = try JSONDecoder().decode([DockApp].self, from: savedData)
            print(decodedData)
            data = decodedData
            print(systemApps)
            print(data)
        } catch {
            print(error)
        }
    }
}

//MARK: - Grid

struct DemoDragRelocateView: View {
    @StateObject private var model = Model()
    
    @Binding var editButton: Bool
    @State private var dragging: DockApp?

    var body: some View {
        //ScrollView {
           LazyHGrid(rows: model.columns, spacing: 8) {
                ForEach(model.data) { app in
                    DockItemView(appURL: app.id, appName: app.name, editModeInBound: $editButton, modelInUse: model, dockApp: app)
                        .onDrag {
                            if !editButton {
                                editButton = true
                            }
                            print("start editing")
                            self.dragging = app
                            return NSItemProvider(object: String(app.id) as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: app, listData: $model.data, current: $dragging))
                        
                        .onChange(of: editButton, {
                            print("Value changed!")
                        })
                        
                }

            }.animation(.default, value: model.data)
            .frame(minHeight: 80, maxHeight: 80)
        //}
    }
}

struct DragRelocateDelegate: DropDelegate {
    let item: DockApp
    @Binding var listData: [DockApp]
    @Binding var current: DockApp?
    let fileManager = FBFileManager.init()
    
    func dropEntered(info: DropInfo) {
        if item != current {
            let from = listData.firstIndex(of: current!)!
            let to = listData.firstIndex(of: item)!
            if listData[to].id != current!.id {
                listData.move(fromOffsets: IndexSet(integer: from),
                    toOffset: to > from ? to + 1 : to)
                
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        do {
            let encodedData = try? JSONEncoder().encode(listData)
            try encodedData?.write(to: fileManager.userDockConfigJSON)
            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
        } catch {
            print(error)
        }
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        
        self.current = nil
        return true
    }
}

//MARK: - GridItem

struct DockItemView: View {
    
    
    
    var appURL: String
    var appName: String
    
    @Binding var editModeInBound: Bool
    var modelInUse: Model
    var dockApp: DockApp
    @State var appImage: Image?
    let fileManager = FBFileManager.init()
    
    var body: some View {
        ZStack {
            Spacer()
            Button {
                editModeInBound = false
                if let url = URL(string: appURL) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        print("cant open URL \(appURL)")
                    }
                }
            } label: {
                
                // determine how to design this button by looking at the prefixes of the appName.
                if let appImage = appImage {
                    appImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .transition(.opacity)
                        .clipShape(Circle())
                } else {
                    ProgressView()
                }
                    
            }.padding(5)
                .buttonStyle(.borderless)
                .buttonBorderShape(.circle)
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        
                        for (index, app) in modelInUse.data.enumerated() {
                            if app == dockApp {
                                modelInUse.data.remove(at: index)
                                break
                            }
                        }
                        
                        do {
                            let encodedData = try? JSONEncoder().encode(modelInUse.data)
                            try encodedData?.write(to: fileManager.userDockConfigJSON)
                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        } catch {
                            print(error)
                        }
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height:40)
                    }.opacity(editModeInBound ? 1.0 : 0.0)
                        .frame(width: 40, height: 40)
                }
                Spacer()
            }
            
        }.onAppear {
            Task {
                appImage = await IconUtils().getIcon(name: appName)
            }
        }.onChange(of: modelInUse.data) { oldValue, newValue in
            Task {
                appImage = await IconUtils().getIcon(name: appName)
            }
        }
    }
    
    func change() {
        
    }
}

struct GridItemView: View {
    var d: DockApp

    var body: some View {
        VStack {
            Text(String(d.id))
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(minWidth: 80, maxWidth: 80, minHeight: 80, maxHeight: 80)
        .background(Color.green)
    }
}

struct DropOutsideDelegate: DropDelegate {
    @Binding var current: DockApp?
        
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        return true
    }
}


