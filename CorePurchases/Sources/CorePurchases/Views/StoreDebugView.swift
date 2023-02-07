//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 1/30/23.
//

import SwiftUI
import StoreKit


public struct StoreDebugView: View {
    
    @ObservedObject var store:Store
    
    public var body: some View {
        List {
            Section("Non-Consumables") {
                ForEach(store.nonConsumables(), id: \.id) { product in
                    
                    DebugNonConsumableProductCell(product: product, store: store) {
                        didTapPurchase(product: product)
                    }
                }
            }
            
            Section("Consumables") {
                
                let quantity:Int = 5
                ForEach(store.consumables(), id: \.id) { product in
                    DebugConsumableProductCell(product: product, store: store, increment: quantity) {
                        purchaseQuantity(product: product, amount: quantity)
                    }
                }
            }

            ForEach(store.subscriptionGroups(), id: \.id) { group in
                SubscriptionGroupDebug(group: group, store: store)
            }
            
            Section("Non-Renewable Subscriptions") {
                ForEach(store.nonRenewingSubscriptions(), id: \.id) { product in
                    DebugProductCell(product: product) {
                        didTapPurchase(product: product)
                    }
                }
            }
        }
        .font((.system(size: 14, weight: .medium, design: .monospaced)))
        .padding(EdgeInsets(top: 4.0, leading: 8.0, bottom: 4.0, trailing: 8.0))
    }
    
    public init(store: Store) {
        self.store = store
    }
    
    func purchaseQuantity(product: Product, amount: Int) {
        guard !store.activeTransaction.processing else {
            return
        }
        Task {
            do {
                let resonse = try await store.buy(consumable: product, quantity: 5)
                print("purchased")
            } catch {
                print(error)
            }
        }
    }
    
    func didTapPurchase(product: Product) {
        
        guard !store.activeTransaction.processing else {
            return
        }
        
        Task {
            do {
                let resonse = try await store.buy(product: product)
            } catch {
                print(error)
            }
        }
    }
}

public struct DebugProductCell:View {
    
    let product:Product
    
    let purchaseAction:()->Void
    
    public var body: some View {
        HStack {
            
            DemoProductDescription(product: product)
            Divider()
            Spacer()
        }
    }
    
    public init(product: Product, purchaseAction: @escaping ()->Void) {
        self.product = product
        self.purchaseAction = purchaseAction
    }
}

public struct DebugNonConsumableProductCell:View {
    
    let product:Product
    let store:Store
    
    let purchaseAction:()->Void
    
    public var body: some View {
        HStack {
            
            DemoProductDescription(product: product)
        
            Divider()
            VStack {
                LabeledCheck(label: "Cached",
                             checked: store.isCached(product: product))
                LabeledCheck(label: "Entitlements",
                             checked: store.inEntitlements(product: product))
            }
  
            Divider()
            Spacer()
            
            let purchased:Bool = store.isNonConsumableOpen(productId: product.id)
            let text:String = (purchased) ? "Purchased" : "\(product.displayPrice)"
            let color:Color = (purchased) ? Color.gray : Color.green
            
            Button {
                purchaseAction()
            } label: {
                Text(text)
            }
            .buttonStyle(BuyButtonStyle(background: color))

        }
    }
    
    public init(product: Product, store: Store, purchaseAction: @escaping ()->Void) {
        self.product = product
        self.purchaseAction = purchaseAction
        self.store = store
    }
}

public struct DebugConsumableProductCell:View {
    
    let product:Product
    let store:Store
    let increment:Int
    
    let purchaseAction:()->Void
    
    public var body: some View {
        HStack {
            
            DemoProductDescription(product: product)
        
            Divider()
            VStack {
                
                VStack {
                    
                    Image(systemName: "dollarsign.circle")
                        .controlSize(.small)
                        .foregroundColor(.white)
                    
                    Text("Current: \(store.consumableAvailable(productId: product.id))")
                        .font(.body)
                        .fontWeight(.light)
                }
            }
  
            Divider()
            Spacer()
            
            Button {
                purchaseAction()
            } label: {
                Text("+ \(increment) More")
            }
            .buttonStyle(BuyButtonStyle(background: Color.blue))

        }
    }
    
    public init(product: Product, store: Store, increment: Int, purchaseAction: @escaping ()->Void) {
        self.product = product
        self.purchaseAction = purchaseAction
        self.store = store
        self.increment = increment
    }
}



struct DemoProductDescription:View {
    
    let product:Product
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(product.displayName).font(.headline)
            
            Text(product.description)
                .font(.subheadline)
            
            Text(product.id)
                .font(.footnote)
        }
    }
}

struct LabeledCheck:View {
    
    let label:String
    let checked:Bool
    
    var icon:Image {
        if checked {
            return Image(systemName: "checkmark.circle")
        } else {
            return Image(systemName: "circle")
        }
    }
    
    var tint:Color { return (checked) ? .green : .white }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            
            Text(label)
                .font(.footnote)
                .fontWeight(.light)
            
            icon
                .controlSize(.small)
                .foregroundColor(tint)
        }
    }
}

struct BuyButtonStyle: ButtonStyle {
    
    let background:Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
             .background(background)
             .foregroundColor(.white)
             .cornerRadius(5.0)
    }
}
