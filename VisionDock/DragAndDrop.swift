//
//  DragAndDrop.swift
//  infiniteX3I
//
//  Created by Joonwoo KIM on 2023-07-07.
//

import SwiftUI
import UniformTypeIdentifiers

struct GridData: Identifiable, Equatable {
    
    let id: String
}

//MARK: - Model

class Model: ObservableObject {
    @Published var data: [GridData]
    
    @State var systemApps:[String] = ["Safari", "Settings", "Files", "Photos"]
    

    let columns = [
        GridItem(.flexible(minimum: 30, maximum: 40))
    ]

    init() {
        data = Array(repeating: GridData(id: ""), count: 4)
        for i in 0..<data.count {
            data[i] = GridData(id: systemApps[i])
        }
    }
}

//MARK: - Grid

struct DemoDragRelocateView: View {
    @StateObject private var model = Model()

    @State private var dragging: GridData?
    @State var appsCorrespondingURL:[String : String] = ["Safari" : "x-web-search://", "Settings": UIApplication.openSettingsURLString, "Files" : "shareddocuments://", "Photos" : "photos-navigation://"]

    var body: some View {
        //ScrollView {
           LazyHGrid(rows: model.columns, spacing: 8) {
                ForEach(model.data) { app in
                    DockItemView(appURL: appsCorrespondingURL[app.id] ?? "", appName: app.id )
                        .overlay(dragging?.id == app.id ? Color.white.opacity(0.8) : Color.clear)
                        .onDrag {
                            self.dragging = app
                            return NSItemProvider(object: String(app.id) as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: app, listData: $model.data, current: $dragging))
                }
            }.animation(.default, value: model.data)
            .frame(minHeight: 30, maxHeight: 40)
        //}
    }
}

struct DragRelocateDelegate: DropDelegate {
    let item: GridData
    @Binding var listData: [GridData]
    @Binding var current: GridData?

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
    
    var body: some View {
        Button {
            if let url = URL(string: appURL ?? "") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("cant")
                }
            }
        } label: {
            Image(appName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }.padding(5)
            .buttonStyle(.borderless)
            .buttonBorderShape(.circle)
    }
}

struct GridItemView: View {
    var d: GridData

    var body: some View {
        VStack {
            Text(String(d.id))
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(minWidth: 40, maxWidth: 40, minHeight: 40, maxHeight: 40)
        .background(Color.green)
    }
}

struct DropOutsideDelegate: DropDelegate {
    @Binding var current: GridData?
        
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        return true
    }
}
