//
//  SettingsManageDock.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-01.
//

import SwiftUI
import PhotosUI
struct SettingsManageDock: View {
    
    // Add shortcut through Shortcuts app.
    // 1. Add a shortcut that copies shortcut URL into the app
    // 2. In the Shortcuts app, let user press our shortcut
    // 3. let them copy the shortcut to the clipboard.
    // 4. Let the app detect the clipboard content
    // 5. Ask if they want to add shortcut to the app
    // 6. Add it to the app
    
    // We can look into "Add shortcuts" in "Launcher" app on the App Store.
    @Environment(\.openWindow) var openWindow
    @State private var showSystemApps = false
    @State private var showAvailableShortcuts = false
    @State private var showAvailableApps = false
    @State private var showAvailableSystemApps = false
    @State private var addAppView = false
    @State private var selectedApps: [DockApp] = []
    @State private var selectedShortcuts: [DockApp] = []
    @State private var selectedSystemApps: [DockApp] = []
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
                                AsyncView {
                                    await IconUtils().getIcon(name: item.name)
                                } content: { phase in
                                    switch phase {
                                    case .loading:
                                        ProgressView().frame(width: 40, height: 40)
                                    case .success(value: let value):
                                        value
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:40, height: 40)
                                            .cornerRadius(20)
                                    case .failure(error: let error):
                                        Image("NoIcon").resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:40, height: 40)
                                    }
                                }

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
                    Text("To add more shortcuts or Apps, please add more through + button at top right corner.\nTo change icon of an app or shortcut, long pinch while staring at an app and tap \"edit\".")
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
        .sheet(isPresented: $showAvailableApps) {
            SettingsAvailableApps(selectedShortcuts: $selectedApps)
                .frame(width: 750, height: 500)
        }
        .sheet(isPresented: $showAvailableShortcuts) {
            SettingsAvailableShortcuts(selectedShortcuts: $selectedShortcuts)
                .frame(width: 750, height: 500)
        }
        .sheet(isPresented: $showAvailableSystemApps) {
            SettingsAvailableSystemApps(selectedShortcuts: $selectedSystemApps)
                .frame(width: 750, height: 500)
        }
        .sheet(isPresented: $addAppView, content: {
            AddNewAppModal()
        }).sheet(isPresented: $editingShortcutView, onDismiss: {
            refreshList()
            NotificationCenter.default.post(name: NSNotification.Name("reloadDockItems"), object: nil, userInfo: nil)
        }, content: {
            EditShortcutView(item: $itemBeingEdited)
        })
        .navigationTitle("Manage Dock")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                                showAvailableShortcuts.toggle()
                    }, label: {
                        Text("\(Image(systemName: "square.stack.3d.up.fill")) Add Imported Shortcuts") //TODO: maybe find a better icon for this?
                    })
                    Button(action: {
                            showAvailableApps.toggle()
                    }, label: {
                        Text("\(Image(systemName: "circle.hexagongrid.fill")) Add Added Apps") //using app w/ notification badge because the regular app symbol is literally just a rounded rectangle
                    })
                    
                    Button(action: {
                            showAvailableSystemApps.toggle()
                    }, label: {
                        Text("\(Image(systemName: "visionpro.fill")) Add System Apps") //using app w/ notification badge because the regular app symbol is literally just a rounded rectangle
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
    SettingsManageDock()
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
                Text("Add an App to SpatialDock with URL")
                    .font(.title)
                    .multilineTextAlignment(.center)
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
                        Text("Write the name of the app.")
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
                let app = DockApp(id: appLink, name: appName, type: .app)
                if let data = imgData {
                    IconUtils().addDataToCache(name: appName.lowercased(), data: data)
                }
                let fileManager = FBFileManager.init()
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
                Task {
                    appIcon = await IconUtils().getIcon(name: appName)
                    DispatchQueue.main.async {
                        withAnimation {
                            loading = false
                        }
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
                Task {
                    appIcon = await IconUtils().getIcon(name: item.name)
                    DispatchQueue.main.async {
                        withAnimation {
                            loading = false
                        }
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

public struct AsyncView<T>: View {
    
    public enum AsyncLoadingPhase {
        /// No value is loaded.
        case loading
        /// A value successfully loaded.
        case success(value: T)
        /// A value failed to load with an error.
        case failure(error: Error?)
    }
    
    @State private var task: Task<Void, Never>? = nil
    @State private var phase: AsyncLoadingPhase = .loading
    var priority: TaskPriority = .userInitiated
    let fetch: () async throws -> T
    let content: (AsyncLoadingPhase) -> any View
        
    public var body: some View {
        if #available(iOS 15.0, *) {
            AnyView(content(phase))
                .task(priority: priority) {
                    await performFetchRequestIfNeeded()
                }
        } else {
            AnyView(content(phase))
                .onAppear {
                    task = Task(priority: priority) {
                        await performFetchRequestIfNeeded()
                    }
                }
                .onDisappear {
                    task?.cancel()
                }
        }
    }
    
    private func performFetchRequestIfNeeded() async {
        // This will be called every time the view appears.
        // If we already performed a successful fetch, there's no need to refetch.
        switch phase {
        case .loading, .failure:
            break
        case .success:
            return
        }
        
        do {
            phase = .success(value: try await fetch())
        } catch {
            phase = .failure(error: error)
        }
    }
    
}
