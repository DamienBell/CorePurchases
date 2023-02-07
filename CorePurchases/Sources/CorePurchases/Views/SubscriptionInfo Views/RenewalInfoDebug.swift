//
//  File.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit

struct RenewalInfoDebug:View {
    
    var renewal:Product.SubscriptionInfo.RenewalInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            ShortJson()

//            Text(renewal.debugDescription)
//                .font(.caption)
//                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
    }
    
    @ViewBuilder func ShortJson() -> some View {

        VStack(alignment: .leading) {
            Text("{")
            Group {
                Text("currentProduct: \(renewal.currentProductID),")
                if renewal.willAutoRenew,
                let product = renewal.autoRenewPreference
                {
                    
                    let color:Color = (renewal.currentProductID == product) ? .green : .yellow
                    Text("willAutoRenew: ") + Text("true").foregroundColor(.green)
                    Text("autoRenewProduct: ") + Text(product).foregroundColor(color)
                    
                } else {
                    Text("willAutoRenew: false")
                        .foregroundColor(.red)
                    if let reason = renewal.expirationReason {
                        Text("expirationReason: \(reason.localizedDescription)")
                    }
                }
                
                Text("recentSubscriptionStartDate: \(renewal.recentSubscriptionStartDate.formatted())")
                Text("signed: \(renewal.signedDate.formatted())")
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
            
            Text("}")
        }
        .font(.caption)
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
}

