//
//  File.swift
//  
//
//  Created by Damien Bell on 1/30/23.
//

import StoreKit


//MARK: The Cache is our Univeral source of truth.
public extension Product {
    
    static var cache:PurchasesCache { return PurchasesCache() }
    
    func cachePurchase() {
        Self.cache.markPurchased(product: self.id)
    }
    
    func clearCache() {
        Self.cache.close(product: self.id)
    }
    
    func purchaseIsCached()->Bool {
        return Self.cache.isPurchased(product: self.id)
    }
    
    var isSubscription:Bool {
        return subscription != nil
    }
    
    var displayTimeUnit:String {
        if #available(iOS 15.4, *) {
            return subscription?.subscriptionPeriod.unit.localizedDescription  ?? ""
        } else {
            return ""
        }
    }
    
    var displayTimeUnitPrice:String {
        let price = displayPrice
        if #available(iOS 15.4, *) {
            guard let unit = subscription?.subscriptionPeriod.unit.localizedDescription else {
                return price
            }
            return "\(price)/\(unit)"

        } else {
            return price
        }
    }
}


extension Product.SubscriptionInfo.RenewalState {
    var display:String {
        switch self {
        case .subscribed: return "Subscribed"
        case .expired: return "Expired"
        case .inBillingRetryPeriod: return "Billing Retry"
        case .inGracePeriod: return "Grace Period"
        case .revoked: return "Canceled"
        default:
            return ""
        }
    }
}


extension Date {
    func priceFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
}
