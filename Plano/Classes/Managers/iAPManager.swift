//
//  iAPManager.swift
//  Plano
//
//  Created by Thiha Aung on 8/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class iAPManager {
    
    static let shareInstance = iAPManager()
    let checkSubscriptionModel = PremiumViewModel()
    
    //MARK: - Get Products Info from iTunes Connect
    
    func getAllProductsInfo(success: @escaping (_ product : [SKProduct]) -> Void, failure : @escaping (_ errorMessage : String)-> Void) {
        
        SwiftyStoreKit.retrieveProductsInfo([Constants.Products.FAMILY,Constants.Products.ANNUAL]) { result in
            let products : Set<SKProduct> = result.retrievedProducts
            if products.count != 0{
                let iAPProduct = Array(products.sorted{(Double($0.price) < Double($1.price))})
                success(iAPProduct)
            }else if let invalidProductId = result.invalidProductIDs.first {
                failure("Could not retrieve product info which has invalid product identifier : \(invalidProductId)")
                return
            }else {
                print("Error: \(String(describing: result.error))")
            }
        }
        
    }
    
    //MARK: - Verify Subscription
    
    func verifySubscription(success: @escaping (_ receipt : ReceiptInfo) -> Void, failure : @escaping (_ errorMessage : String)-> Void){
        
        //TODO : change to production
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.StoreConnect.SecretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            
            if case .success(let receipt) = result {
                
                print("Verify Receipt : \(receipt)")
                
                var expires_dateIs = ""
                var original_purchase_dateIs = ""
                var product_idIs = ""
                var environment = ""
                
                environment = (receipt["environment"] as! NSString) as String
                
                if receipt["latest_receipt_info"] as? NSArray != nil{
                    let latest_receipt_info = receipt["latest_receipt_info"] as! NSArray
                    
                    
                    
                    for i in latest_receipt_info{
                        // expires_date
                        if (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "expires_date") as? String != nil{
                            expires_dateIs = (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "expires_date") as! String
                        }else if (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "expires_date") as? Int != nil{
                            expires_dateIs = String((latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "expires_date") as! Int)
                        }
                        // original_purchase_date
                        if (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "original_purchase_date") as? String != nil{
                            original_purchase_dateIs = (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "original_purchase_date") as! String
                        }else if (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "original_purchase_date") as? Int != nil{
                            original_purchase_dateIs = String((latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "original_purchase_date") as! Int)
                        }
                        // product_id
                        if (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "product_id") as? String != nil{
                            product_idIs = (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "product_id") as! String
                        }else if (latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "product_id") as? Int != nil{
                            product_idIs = String((latest_receipt_info[latest_receipt_info.count-1] as AnyObject).object(forKey: "product_id") as! Int)
                        }
                    }
                }
                
                let seperatedexpires_dateIs = expires_dateIs.components(separatedBy: " ")
                let seperatedoriginal_purchase_dateIs = original_purchase_dateIs.components(separatedBy: " ")
            
                _BaseViewController().preferences.setValue(seperatedexpires_dateIs[0], forKeyPath: "expiryDate")
                _BaseViewController().preferences.setValue(product_idIs, forKeyPath: "productId")
            _BaseViewController().preferences.setValue(seperatedoriginal_purchase_dateIs, forKeyPath: "OriginalPurchaseDate")
               
                // This condition is added for testing Sandbox tester.
                if (receipt["latest_receipt"] as? String != nil) {
                _BaseViewController().preferences.setValue(receipt["latest_receipt"] as? String, forKeyPath: "latest_receipt")
                  
                    self.checkSubscriptionModel.receiptData = receipt["latest_receipt"] as? String
                }
                else {
                    // This condition is added for testing Sandbox tester.
                    self.checkSubscriptionModel.receiptData = ""
                }
                
                success(receipt)
                
            } else {
                
                failure("Receipt Verification Failure")
                
            }
        }
    }
    
    //MARK: - Purchase Product Via iAP
    
    func purchaseProduct(productID : String, success: @escaping (_ receipt : ReceiptInfo) -> Void, failure : @escaping (_ errorMessage : String)-> Void){
        
        // First it will do purchase
        SwiftyStoreKit.purchaseProduct(productID, atomically: false) { result in
            
            // When it success, it will return recepit. Mean Apple officially reduct the money from your account
            if case .success(let purchase) = result {
                
                // This can also call if you want to get the receipt from Apple
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                // Then we validate the receipt from the server to AppStore for double check
                // First we check via client [client to AppStore]
                // Please turn these into .production when release
                
                // TODO: change to production
                
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.StoreConnect.SecretKey)
                SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: productID,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let receiptItems):
                            // Second we check via server [server to AppStore] by sending receipt and secret-code
                            
                            log.info("Product is valid until \(expiryDate)")
                            log.info("Latest Receipt Product : \(String(describing: receiptItems.last?.productId))")
                            log.info("Latest Receipt OriginalPurchaseDate : \(String(describing: receiptItems.last?.originalPurchaseDate))")
                            log.info("Latest Receipt ExpireDate : \(String(describing: receiptItems.last?.subscriptionExpirationDate))")
                            
                        case .expired(let expiryDate, let receiptItems):
                            
                            log.info("Product is expired since \(expiryDate)")
                            log.info("Final Receipt Product : \(String(describing: receiptItems.last?.productId))")
                            log.info("Final Receipt OriginalPurchaseDate : \(String(describing: receiptItems.last?.originalPurchaseDate))")
                            log.info("Final Receipt ExpireDate : \(String(describing: receiptItems.last?.subscriptionExpirationDate))")
                            
                        case .notPurchased:

                            log.info("This product has never been purchased")
                            
                        }
                        success(receipt)
                        
                    } else {
                        failure("Internal Server Error. Please try again later")
                    }
                }
            } else {
                
                // This error can happen when user trying to downgrade from higher plan to lower plan
                // or insufficient amount
                
                failure("Sorry, fail to subscribe")
            }
        }
    }
    
    //MARK: - Updating Premium
    
    func UpdateIOSPremium(_ data:UpdatePremiumRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateIOSPremium(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler:\(apiResponseHandler.jsonObject)")
            completed(apiResponseHandler, error)
        }
    }

    func getCurrentSubscription(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = GetSubscriptionRequest(email: profile.email, accessToken: profile.accessToken, countryCode: profile.CountryRegistered!).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetCurrentSubscription(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getAvailableSubscriptions(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = GetSubscriptionRequest(email: profile.email, accessToken: profile.accessToken, countryCode: profile.CountryRegistered!).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetAvailableSubscriptions(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
}
