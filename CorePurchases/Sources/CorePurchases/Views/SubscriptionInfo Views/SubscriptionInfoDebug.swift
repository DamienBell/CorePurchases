//
//  File.swift
//  
//
//  Created by Damien Bell on 2/4/23.
//

import SwiftUI
import StoreKit

typealias StoreTransaction = StoreKit.Transaction

struct SubscriptionInfoDebug:View {
    
    let subscription:Product.SubscriptionInfo
    let product:Product
    let group:SubscriptionGroup
    
    @State var statuses:[Product.SubscriptionInfo.Status]?
    @State var isEligibleForIntroOffer:Bool = false
    
    var promos:[(id: String, offer: Product.SubscriptionOffer)] {
        return subscription.promotionalOffers.map { offer in
            return (id: UUID().uuidString, offer: offer)
        }
    }
    
    var offerText:String {
        if isEligibleForIntroOffer {
            return "Eligible"
        } else {
            return "Not Eligible"
        }
    }
    var statusTuples:[(id: String, status: Product.SubscriptionInfo.Status)] {
        
        let stats:[Product.SubscriptionInfo.Status] = statuses ?? []
        
        return stats.map { status in
            return (id: UUID().uuidString, status: status)
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                
                Text("Subscription.Info:")
                    .fontWeight(.bold)
                
                Text("Period: \(subscription.subscriptionPeriod.debugDescription)")
                
                if subscription.promotionalOffers.count > 0 {
                    Divider()
                    Text("Promotions: ")
                        .fontWeight(.bold)
                    ForEach(promos, id: \.id) { info in
                        SubscriptionOfferDebug(offer: info.offer)
                    }
                }
   
                if let offer = subscription.introductoryOffer {
                    Divider()
                    Text("Intro Offers: ")
                        .fontWeight(.bold)
                    SubscriptionOfferDebug(offer: offer)
                        .padding(EdgeInsets(top: 0, leading: 8.0, bottom: 0, trailing: 0))
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                ForEach(statusTuples, id: \.id) { info in
            
                    let status = info.status
                    
                    Text(messaging(for: status))
                    
                    if let transaction = self.transaction(for: status) {
                        Divider()
                        RenewalStateDebug(state: status.state)
                        TransactionDebug(transaction: transaction)
                    }
                    
                    if let renewal = self.renewal(for: status) {
                        Text("RenewalInfo:")
                            .fontWeight(.bold)
                        RenewalInfoDebug(renewal: renewal)
                    }
                }
            }
        }
        .task {
            do {
                statuses = try? await subscription.status
                isEligibleForIntroOffer = await subscription.isEligibleForIntroOffer
            }
        }
    }
    
    func messaging(for status: Product.SubscriptionInfo.Status)->String {
        let msg:RenewableStatusMessaging = .init(product: product,
                                                 group: group,
                                                 status: status)
        return msg.statusDescription()
    }
    
    func transaction(for status: Product.SubscriptionInfo.Status)->StoreTransaction? {
        if case .verified(let transaction) = status.transaction {
            if transaction.productID == self.product.id {
                return transaction
            }
        }
        return nil
    }
    
    func renewal(for status: Product.SubscriptionInfo.Status)->Product.SubscriptionInfo.RenewalInfo? {
        if case .verified(let renewal) = status.renewalInfo {
            if renewal.currentProductID == product.id {
                return renewal
            }
            if let upcomingProduct = renewal.autoRenewPreference {
                if upcomingProduct == product.id {
                    return renewal
                }
            }
        }
        return nil
    }
}
