//
//  VDProUnlimitedApps.swift
//  SpatialDock
//
//  Created by Payton Curry on 1/20/24.
//

import SwiftUI

struct VDProUnlimitedApps: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Unlimited Apps").font(.title).bold()
            Text("Use unlimited apps in the dock and get more widgets in the future updates.")
            Divider()
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Range(0...100)) { index in
                        _RandomAppContainer().scrollTransition(.interactive.threshold(.visible(0.99999))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    }
                }
            }.scrollIndicators(.never).clipShape(.capsule(style: .continuous)).padding()
            Spacer()
        }
    }
    
}

#Preview {
    VDProUnlimitedApps()
}

struct _RandomAppContainer: View {
    var colors: [Color] = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink, Color.cyan]
    var symbols: [String] = []
    init() {
        if let sfSymbolsBundle = Bundle(identifier: "com.apple.SFSymbolsFramework"),
            let bundlePath = sfSymbolsBundle.path(forResource: "CoreGlyphs", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let resourcePath = bundle.path(forResource: "symbol_search", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: resourcePath) {

            /// keys in plist are names of all available symbols
            symbols = (plist.allKeys as? [String]) ?? ["wand.and.stars"]
        }
    }
    var body: some View {
        ZStack {
            Circle().foregroundStyle(.linearGradient(colors: [colors.randomElement()!, colors.randomElement()!], startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: symbols.randomElement()!).font(.title).bold()
        }.frame(width: 70, height: 70)
    }
}
