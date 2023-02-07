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

extension Product.SubscriptionOffer {
    var display:String {
        
        return """
            \(self.type.localizedDescription)
            \(displayPrice) for \(self.period.debugDescription)
            \(self.paymentMode.localizedDescription)
        """
    }
}

extension Product.SubscriptionOffer.OfferType {
    var display:String {
        return self.localizedDescription
    }
}

extension Product.SubscriptionPeriod {
 
    @available(iOS 15.4, *)
    var display:String {
        return "\(self.unit) \(unit.localizedDescription)"
    }
}

extension StoreKit.Transaction {
    var renewalInfoDisplay:String? {
        guard let _ = self.subscriptionGroupID else {
            return nil
        }
        guard let expiration = expirationDate else {
            return nil
        }
        
        if let revocationReason = revocationReason {
            return "Expires: \(expiration.formatted()) | \(revocationReason.localizedDescription)"
        } else {
            return "Renews: \(expiration.formatted())"
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
