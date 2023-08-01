//
//  DragAndDrop.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-07.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct DockApp: Identifiable, Equatable {
    var id: String //deep link
    var name: String
}

//MARK: - Model

class Model: ObservableObject {
    @Published var data: [DockApp]
    
    // For each of the name, add prefix
    // Shortcuts Prefix:  SHORTCUTS::
    // Contact Prefix:    CONTACT::
    // System App Prefix: SYSTEM::
    
    // There should be a better way of organizing this...
    
    let systemApps: [DockApp] = [.init(id: "x-web-search://", name: "Safari"),
        .init(id: UIApplication.openSettingsURLString, name: "Settings"),
        .init(id: "shareddocuments://", name: "Files"),
        .init(id: "photos-navigation://", name: "Photos")]
    

    let columns = [
        GridItem(.flexible(minimum: 80, maximum: 80))
    ]

    init() {
        data = []
        data = systemApps
        //add user-selected apps here
    }
}

//MARK: - Grid

struct DemoDragRelocateView: View {
    @StateObject private var model = Model()
    
    @Binding var editButton: Bool
    @Binding var addingApp: Bool
    @State private var dragging: DockApp?

    var body: some View {
        //ScrollView {
           LazyHGrid(rows: model.columns, spacing: 8) {
                ForEach(model.data) { app in
                    DockItemView(appURL: app.id, appName: app.name, editModeInBound: $editButton)
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
               if editButton {
                   Button {
                       addingApp.toggle()
                   } label: {
                       Image(systemName: "plus.circle.fill").resizable()
                           .aspectRatio(contentMode: .fit)
                           .opacity(0.8)
                   }.buttonStyle(.borderless)
                       .buttonBorderShape(.circle).padding(5).transition(.opacity.combined(with: .slide))
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
    @State var appImage: Image?
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
            IconUtils().getIcon(name: appName) { img in
                appImage = img
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


struct AddNewAppModal: View {
    @State var appName: String = ""
    @State var appLink: String = ""
    @State var appIcon: Image = Image("NoIcon")
    @State var loading = false
    @State var appIconItem: PhotosPickerItem?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Add an app to InfiniteX3I")
                .font(.title)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
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
                    appIcon.resizable().frame(width: 100, height: 100).transition(.opacity)
                    
                } else {
                    ProgressView().frame(width: 100, height: 100).transition(.opacity)
                }
                //need to let user choose their own
                PhotosPicker("Choose from Photos", selection: $appIconItem, matching: .images)
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Spacer()
            Button {
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
                    appIcon = Image(uiImage: UIImage(data: data) ?? UIImage(named: "NoIcon")!)
                }
            }
        }
    }
}



#Preview {
    AddNewAppModal()
}
