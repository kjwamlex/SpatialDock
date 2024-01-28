//
//  StoreController.swift
//  SpatialDock
//
//  Created by Payton Curry on 1/20/24.
//

import Foundation
import StoreKit

class StoreController: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchased: [String] = []
    static var shared = StoreController()
    
    init() {
        Task { @MainActor in
            do {
                products = try await Product.products(for: ["com.exDevelopments.SpatialDock.pro.monthly", "com.exDevelopments.SpatialDock.pro.yearly"])
                print("got \(products.count) SpatialDock Pro products")
            } catch {
                print("Error fetching products: \(error)")
            }
//            print(purchased)
            
            for product in products {
                let statuses = (try? await Product.SubscriptionInfo.status(for: product.id)) ?? []
                let current = statuses.last
                if let current = current {
                    print(current)
                }
            }
            for await transaction in Transaction.currentEntitlements {
                if let payload = try? transaction.payloadValue {
                    print("entitlements")
                    purchased.append(payload.productID)
                }
            }
            print(purchased)
            for await transaction in Transaction.updates {
                print("new transaction")
                
                switch transaction {
                case .verified(let trans):
                    purchased.append(trans.productID)
                case .unverified(let thing1, let thing2):
                    print(thing1, thing2)
                }
                print(purchased)
                try? await transaction.payloadValue.finish()
            }
            
        }
    }
    func storePurchasedInDefaults() {
        let store = UserDefaults(suiteName: "group.com.paytondeveloper.daysuntil")!
        store.setValue(purchased, forKey: "purchased")
    }
    func pullPurchasedFromDefaults() {
        let store = UserDefaults(suiteName: "group.com.paytondeveloper.daysuntil")!
        purchased = store.array(forKey: "purchased") as? [String] ?? []
    }
    func restore(callback: @escaping () -> Void) {
        Task {
            for await transaction in Transaction.currentEntitlements {
                if let payload = try? transaction.payloadValue {
                    print("entitlements")
                    DispatchQueue.main.async {
                        self.purchased.append(payload.productID)
                    }
                }
            }
            callback()
        }
    }
}

