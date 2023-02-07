//
//  File.swift
//  
//
//  Created by Damien Bell on 2/6/23.
//

import SwiftUI
import StoreKit


struct SubscriptionOfferDebug:View {
    
    let offer:Product.SubscriptionOffer

    var body: some View {
        VStack(alignment: .leading) {
            Text(offer.display)
                .lineLimit(0...8)
        }
    }
}



/// This is always `nil` for introductory offers and never `nil` for promotional offers.
//public let id: String?
//
///// The type of the offer.
//public let type: Product.SubscriptionOffer.OfferType
//
///// The discounted price that the offer provides in local currency.
/////
///// This is the price per period in the case of `.payAsYouGo`
//public let price: Decimal
//
///// A localized string representation of `price`.
//public let displayPrice: String
//
///// The duration that this offer lasts before auto-renewing or changing to standard subscription
///// renewals.
//public let period: Product.SubscriptionPeriod
//
///// The number of periods this offer will renew for.
/////
///// Always 1 except for `.payAsYouGo`.
//public let periodCount: Int
//
///// How the user is charged for this offer.
//public let paymentMode: Product.SubscriptionOffer.PaymentMode


//Product.SubscriptionOffer.PaymentMode
//public static let payAsYouGo: Product.SubscriptionOffer.PaymentMode
//
//public static let payUpFront: Product.SubscriptionOffer.PaymentMode
//
//public static let freeTrial: Product.SubscriptionOffer.PaymentMode
