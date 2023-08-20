//
//  SettingsShortcuts.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI
import PhotosUI
struct SettingsShortcuts: View {
    
    // Add shortcut through Shortcuts app.
    // 1. Add a shortcut that copies shortcut URL into the app
    // 2. In the Shortcuts app, let user press our shortcut
    // 3. let them copy the shortcut to the clipboard.
    // 4. Let the app detect the clipboard content
    // 5. Ask if they want to add shortcut to the app
    // 6. Add it to the app
    
    // We can look into "Add shortcuts" in "Launcher" app on the App Store.
    
    @State private var showSystemApps = false
    @State private var showShortcuts = false
    @State private var addAppView = false
    @State private var selectedShortcuts: [DockApp] = []
    @State private var itemsInDock: [DockApp] = []
    @State var editMode: EditMode = .active
    let fileManager = FBFileManager.init()
    let reloadNotification = NotificationCenter.default.publisher(for: NSNotification.Name("reloadDockItems"))
    
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.defaultMinListHeaderHeight) var listHeaderHeight
    @State var editingShortcutView = false
    //using this to get around a weird SwiftUI bug where parameters passed into a view from .sheet don't get updated :/
    @State var itemBeingEdited: DockApp = .init(id: "", name: "", type: .system)
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(itemsInDock, id: \.self) { item in
                            HStack {
                                Image("Photos")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:40, height: 40)
                                    
                                Text(item.name)

                            }.contextMenu {
                                Button("Edit") {
                                    itemBeingEdited = item
                                    editingShortcutView.toggle()
                                }
                            }

                    }
                    .onMove { from, to in
                        itemsInDock.move(fromOffsets: from, toOffset: to)
                        do {
                            let encodedData = try? JSONEncoder().encode(itemsInDock)
                            try encodedData?.write(to: fileManager.userDockConfigJSON)
                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        } catch {
                            print(error)
                        }
                    }
                    .onDelete { offset in
                        itemsInDock.remove(atOffsets: offset)
                        do {
                            let encodedData = try? JSONEncoder().encode(itemsInDock)
                            try encodedData?.write(to: fileManager.userDockConfigJSON)
                            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                        } catch {
                            print(error)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
                    }
                } header: {
                    Text("Added Shortcuts and Apps in Dock")
                } footer: {
                    Text("To add more shortcuts or Apps, please add more by pressing + button at top right corner.")
                }
            }
            .environment(\.editMode, $editMode)//.frame(minHeight: (minRowHeight * 6) + (3 * listHeaderHeight!))
        }
        .onReceive(reloadNotification) { _ in
            refreshList()
        }
        .onAppear {
            refreshList()
        }
        .sheet(isPresented: $showShortcuts) {
            SettingsAvailableShortcuts(selectedShortcuts: $selectedShortcuts)
                .frame(width: 500, height: 500)
        }.sheet(isPresented: $addAppView, content: {
            AddNewAppModal()
        }).sheet(isPresented: $editingShortcutView, onDismiss: {
            refreshList()
            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
        }, content: {
            EditShortcutView(item: $itemBeingEdited)
        })
        .navigationTitle("Shortcuts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showShortcuts.toggle()
                    }, label: {
                        Text("\(Image(systemName: "curlybraces")) Add Shortcut") //TODO: maybe find a better icon for this?
                    })
                    Button(action: {
                        addAppView.toggle()
                    }, label: {
                        Text("\(Image(systemName: "app.badge")) Add App") //using app w/ notification badge because the regular app symbol is literally just a rounded rectangle
                    })
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
    }
    
    func refreshList() {
        do {
            let data = try Data(contentsOf: fileManager.userDockConfigJSON)
            let decodedData = try JSONDecoder().decode([DockApp].self, from: data)
            itemsInDock = decodedData
        } catch {
            print(error)
        }
    }
}

#Preview {
    SettingsShortcuts()
}
struct AddNewAppModal: View {
    @State var appName: String = ""
    @State var appLink: String = ""
    @State var appIcon: Image = Image("NoIcon")
    @State var loading = false
    @State var appIconItem: PhotosPickerItem?
    @Environment(\.dismiss) var dismiss
    @State var imgData: Data?
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Add an app to InfiniteX3I")
                    .font(.title)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                Spacer()
                //doing it this way because Toolbar make the view too tall
                    Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(.horizontal)
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("App Name")
                        Text("Can be anything")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TextField("", text: $appName).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 300)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("App URL")
                        Text("If you don't know this,\ncontact the app developer.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TextField("", text: $appLink).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 300)
                }
                
            }
            VStack(alignment: .center) {
                Text("App Icon")
                if !loading {
                    appIcon.resizable().frame(width: 100, height: 100).transition(.opacity).clipShape(Circle())
                    
                } else {
                    ProgressView().frame(width: 100, height: 100).transition(.opacity)
                }
                //need to let user choose their own
                PhotosPicker("Choose from Photos", selection: $appIconItem, matching: .images)
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Spacer()
            Button {
                var app = DockApp(id: appLink, name: appName, type: .app)
                if let data = imgData {
                    IconUtils().addDataToCache(name: appName.lowercased(), data: data)
                }
                var fileManager = FBFileManager.init()
                AppManager.addDockAppToStore(item: app, store: fileManager.shortcutStorage)
                dismiss()
            } label: {
                Text("Add App")
            }

        }.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/).frame(width: 500).onChange(of: appName) { _ in
            if appIconItem == nil {
                withAnimation {
                    loading = true
                }
                IconUtils().getIcon(name: appName) { img in
                    withAnimation {
                        appIcon = img
                        loading = false
                    }
                }
            }
        }.onChange(of: appIconItem) { _ in
            Task {
                if let data = try? await appIconItem?.loadTransferable(type: Data.self) {
                    imgData = data
                    appIcon = Image(uiImage: UIImage(data: data) ?? UIImage(named: "NoIcon")!)
                }
            }
        }
    }
}

struct EditShortcutView: View {
    @Binding var item: DockApp
    @State var appIcon: Image = Image("NoIcon")
    @State var loading = false
    @State var appIconItem: PhotosPickerItem?
    @Environment(\.dismiss) var dismiss
    @State var imgData: Data?
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Edit \(item.name)")
                    .font(.title)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                Spacer()
                //doing it this way because Toolbar make the view too tall
                    Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding(.horizontal)
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name")
                        Text("Can be anything")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TextField("", text: $item.name).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 300)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("App URL")
                        Text("If you don't know this,\ncontact the app developer.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TextField("", text: $item.id).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 300).disabled(!(item.type == ShortcutType.app)).opacity(item.type != ShortcutType.app ? 0.5 : 1)
                }
                
            }
            VStack(alignment: .center) {
                Text("App Icon")
                if !loading {
                    appIcon.resizable().frame(width: 100, height: 100).transition(.opacity).clipShape(Circle())
                    
                } else {
                    ProgressView().frame(width: 100, height: 100).transition(.opacity)
                }
                //need to let user choose their own
                PhotosPicker("Choose from Photos", selection: $appIconItem, matching: .images)
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Spacer()
            Button {
                if let data = imgData {
                    IconUtils().addDataToCache(name: item.name, data: data)
                }
                let fileManager = FBFileManager.init()
                    //this code may seem useless at first glance (removing and then immediately adding back the item??) but it is useful and necessary so please oh please leave it!
                    AppManager.removeAppFromStore(item: item, store: fileManager.shortcutStorage)
                    AppManager.addDockAppToStore(item: item, store: fileManager.shortcutStorage)
                    AppManager.removeAppFromStore(item: item, store: fileManager.userDockConfigJSON)
                    AppManager.addDockAppToStore(item: item, store: fileManager.userDockConfigJSON)
                dismiss()
            } label: {
                Text("Save")
            }

        }.padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/).frame(width: 500).onChange(of: item.name, initial: true) { _,_  in
            if appIconItem == nil {
                withAnimation {
                    loading = true
                }
                IconUtils().getIcon(name: item.name) { img in
                    withAnimation {
                        appIcon = img
                        loading = false
                    }
                }
            }
        }.onChange(of: appIconItem, initial: false) { _,_  in
            Task {
                if let data = try? await appIconItem?.loadTransferable(type: Data.self) {
                    imgData = data
                    appIcon = Image(uiImage: UIImage(data: data) ?? UIImage(named: "NoIcon")!)
                }
            }
        }
    }
}
