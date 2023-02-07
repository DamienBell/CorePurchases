//
//  SwiftUIView.swift
//  
//
//  Created by Damien Bell on 2/2/23.
//

import SwiftUI
import StoreKit

struct SubscriptionGroupDebug: View {
    
    let group:SubscriptionGroup
    let store:Store
    
    var body: some View {
        Section("Auto-Renewable Group: \(group.referenceName)") {

            ForEach(Array(group.products)) { product in
                
                DebugRenewableProductCell(product: product, group: group, store: store) {
                    
                    Task {
                        do {
                            guard !store.activeTransaction.processing else {
                                return
                            }
                            print("purchasing: ", product.id)
                            await store.buy(product: product)
                            print("purchase complete")
                        }
                    }
    
                }
            }
        }
    }
}

struct DebugRenewableProductCell:View {
    
    let product:Product
    let store:Store
    let group:SubscriptionGroup
    let purchaseAction:()->Void
    
    public var body: some View {
        HStack(alignment: .top) {
            
            DemoProductDescription(product: product)
        
            Divider()
            VStack(alignment: .leading) {
                LabeledCheck(label: "Cached",
                             checked: store.isCached(product: product))
                LabeledCheck(label: "Entitlements",
                             checked: store.inEntitlements(product: product))
            }
  
            Divider()
           
            if let subscription = product.subscription {
                SubscriptionInfoDebug(subscription: subscription,
                                      product: product,
                                      group: group)
            }

            Spacer()
            
            let purchased:Bool = store.isSubscriptionOpen(productId: product.id)
            let text:String = (purchased) ? "Subscribed" : "\(product.displayPrice)"
            let color:Color = (purchased) ? Color.blue : Color.green
            
            Button {
                purchaseAction()
            } label: {
                Text(text)
            }
            .buttonStyle(BuyButtonStyle(background: color))
        }
    }
    
    public init(product: Product, group: SubscriptionGroup, store: Store, purchaseAction: @escaping ()->Void) {
        self.product = product
        self.group = group
        self.purchaseAction = purchaseAction
        self.store = store
    }
}

public extension SubscriptionGroup {
    
    static func message(transaction: StoreKit.Transaction,
                        status: Product.SubscriptionInfo.Status,
                        renewal: Product.SubscriptionInfo.RenewalInfo,
                        state: Product.SubscriptionInfo.RenewalState,
                        isEligibleForIntroOffer: Bool)
    {
        
    }
}
