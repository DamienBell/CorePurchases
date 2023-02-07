//
//  File.swift
//  
//
//  Created by Damien Bell on 2/7/23.
//

import StoreKit

fileprivate typealias RenewalInfo = Product.SubscriptionInfo.RenewalInfo

public struct RenewableStatusMessaging {
    
    let product: Product
    let group:SubscriptionGroup
    let status: Product.SubscriptionInfo.Status

    //Build a string description of the subscription status to display to the user.
    public func statusDescription() -> String {
        guard case .verified(let renewalInfo) = status.renewalInfo,
              case .verified(let transaction) = status.transaction else {
            return "The App Store could not verify your subscription status."
        }

        var description = ""

        switch status.state {
        case .subscribed:
            description = subscribedDescription(renewal: renewalInfo,
                                                transaction: transaction)
        case .expired:
            if let expirationDate = transaction.expirationDate,
               let expirationReason = renewalInfo.expirationReason {
                description = expirationDescription(expirationReason, expirationDate: expirationDate)
            }
        case .revoked:
            if let revokedDate = transaction.revocationDate {
                description = "The App Store refunded your subscription to \(product.displayName) on \(revokedDate.formatted())."
            }
        case .inGracePeriod:
            description = gracePeriodDescription(renewalInfo)
        case .inBillingRetryPeriod:
            description = billingRetryDescription()
        default:
            break
        }

        if let expirationDate = transaction.expirationDate {
            description += renewalDescription(renewalInfo, expirationDate)
        }
        return description
    }

    fileprivate func billingRetryDescription() -> String {
        var description = "The App Store could not confirm your billing information for \(product.displayName)."
        description += " Please verify your billing information to resume service."
        return description
    }

    fileprivate func gracePeriodDescription(_ renewalInfo: RenewalInfo) -> String {
        var description = "The App Store could not confirm your billing information for \(product.displayName)."
        if let untilDate = renewalInfo.gracePeriodExpirationDate {
            description += " Please verify your billing information to continue service after \(untilDate.formatted())"
        }

        return description
    }

    fileprivate func subscribedDescription(renewal: RenewalInfo, transaction: StoreKit.Transaction) -> String {
        guard let current = group.product(for: renewal.currentProductID) else {
            return ""
        }
        
        if !renewal.willAutoRenew
        {
            let expiration:String = transaction.expirationDate?.formatted() ?? ""
            return "Your subscription will to \(current.displayName) will expire \(expiration)"
        }
        
        return "You are currently subscribed to \(current.displayName)."
    }

    fileprivate func renewalDescription(_ renewalInfo: RenewalInfo, _ expirationDate: Date) -> String {
        var description = ""

        if let newProductID = renewalInfo.autoRenewPreference {
            if let newProduct = group.products.first(where: { $0.id == newProductID }) {
                description += "\nYour subscription to \(newProduct.displayName)"
                description += " will begin when your current subscription expires on \(expirationDate.formatted())."
            }
        } else if renewalInfo.willAutoRenew {
            description += "\nNext billing date: \(expirationDate.formatted())."
        } else if !renewalInfo.willAutoRenew {
          //  description += "\nYour access will expire \(expirationDate.formatted())"
        }
        
        return description
    }

    //Build a string description of the `expirationReason` to display to the user.
    fileprivate func expirationDescription(_ expirationReason: RenewalInfo.ExpirationReason, expirationDate: Date) -> String {
        var description = ""

        switch expirationReason {
        case .autoRenewDisabled:
            if expirationDate > Date() {
                description += "Your subscription to \(product.displayName) will expire on \(expirationDate.formatted())."
            } else {
                description += "Your subscription to \(product.displayName) expired on \(expirationDate.formatted())."
            }
        case .billingError:
            description = "Your subscription to \(product.displayName) was not renewed due to a billing error."
        case .didNotConsentToPriceIncrease:
            description = "Your subscription to \(product.displayName) was not renewed due to a price increase that you disapproved."
        case .productUnavailable:
            description = "Your subscription to \(product.displayName) was not renewed because the product is no longer available."
        default:
            description = "Your subscription to \(product.displayName) was not renewed."
        }

        return description
    }
}
