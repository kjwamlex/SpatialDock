//
//  ProductsView.swift
//  DaysUntil
//
//  Created by Payton Curry on 11/23/23.
//

import SwiftUI
import StoreKit

struct ProductsView: View {
    @Environment(\.purchase) var purchase
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var storeController: StoreController = StoreController.shared
    @State var gradientRotation: Angle = Angle(degrees: 0)
    var timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    var featuresTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var selectedProduct: Product?
    @State var pressedCard: Product?
    @State var index = 0
    let upsellCount = 1
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }.padding().glassBackgroundEffect()

            }
            HStack(spacing: 4) {
                Text("VisionDock").font(.largeTitle).fontWeight(.semibold)
                liveText().font(.largeTitle)
            }.padding().glassBackgroundEffect()
            Divider()
            Spacer()
            TabView(selection: $index) {
                VDProUnlimitedApps().tag(0)
            }.tabViewStyle(.page(indexDisplayMode: .always)).padding().glassBackgroundEffect()
            Spacer()
            HStack {
                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("•")
                //TODO: change priv policy URL
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            }.font(.caption).foregroundStyle(.secondary)
            Divider().padding()
            HStack {
                if !StoreController.shared.products.isEmpty {
                    ForEach(storeController.products.indices) { product in
                        productCard(prod: storeController.products[product], inverted: product % 2 == 0)
                    }
                } else {
                    ProgressView().frame(height: 160)
                }
            }.padding().glassBackgroundEffect()
            Button {
                if let selectedProduct = selectedProduct {
                    Task { @MainActor in
                        do {
                            let res = try await purchase(selectedProduct)
                            switch (res) {
                                
                            case .success(let thing):
                                switch thing {
                                case .verified(let prod):
                                    storeController.purchased.append(prod.productID)
                                        dismiss()
                                case .unverified(_, _):
                                    break;
                                }
                            case .userCancelled:
                                break
                            case .pending:
                                break
                            @unknown default:
                                break
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            } label: {
                Text("Subscribe").bold()
            }.padding().glassBackgroundEffect()
        }.onReceive(timer, perform: { _ in
            withAnimation {
                gradientRotation = Angle(degrees: gradientRotation.degrees + 5)
            }
        }).padding().onChange(of: storeController.products, initial: true) { _, _ in
            if !storeController.products.isEmpty {
                selectedProduct = storeController.products.first(where: { prod in
                    prod.displayName.contains("monthly")
                })
                print("go for change")
            }
        }.onReceive(featuresTimer) { _ in
                withAnimation {
                    if index < (upsellCount - 1) {
                        index += 1
                    } else {
                        index = 0
                    }
                    print("index changed \(index)")
                }
        }
    }
    @ViewBuilder
    func liveText() -> some View {
        StrokeText(text: "Pro", width: 0.8, style: AnyShapeStyle(.linearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))).fontWeight(.black).hueRotation(gradientRotation)
    }
    @ViewBuilder
    func productCard(prod: Product, inverted: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30.0).foregroundStyle(Material.ultraThin).overlay(
                RoundedRectangle(cornerRadius: 30.0).stroke(.linearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 4)).hueRotation(inverted ? -gradientRotation : gradientRotation).opacity(0.6)
            )
            VStack(alignment: .leading) {
                Text(prod.displayName.replacingOccurrences(of: "VisionDock", with: "")).bold()
                Spacer()
                HStack {
                    Text("\(prod.displayPrice)/\(prod.displayName.contains("Monthly") ? "month" : "year")")
                    Spacer()
                    if selectedProduct?.id == prod.id {
                        ZStack {
                            Circle().foregroundStyle(.linearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: "checkmark").resizable().frame(width: 10, height: 10).foregroundStyle(.white).fontWeight(.bold)
                        }.frame(width: 20, height: 20)
                    } else {
                        Circle().foregroundStyle(Material.ultraThin).overlay(
                            Circle().stroke(.secondary, lineWidth: 2.0)
                        ).frame(width: 20, height: 20)
                    }
                }
            }.padding()
        }.frame(height: 160).onTapGesture {
            pressedCard = prod
            withAnimation(.easeInOut) {
                selectedProduct = prod
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                pressedCard = nil
            })
        }.scaleEffect(x: pressedCard == prod ? 0.8 : 1, y: pressedCard == prod ? 0.8 : 1).animation(.spring, value: pressedCard).hoverEffect(.lift)
    }
}
struct StrokeText: View {
    let text: String
    let width: CGFloat
    let style: AnyShapeStyle

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundStyle(style)
            Text(text)
        }
    }
}
