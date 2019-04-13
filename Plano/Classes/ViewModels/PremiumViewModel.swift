//
//  PremiumViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/22/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

//
//  PremiumViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/22/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import SwiftyStoreKit
import StoreKit

class PremiumViewModel{
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    var beforeUpdateApiCall : (() -> Void)?
    var afterUpdateApiCall : (() -> Void)?
    var premiumCode : String?
    var receiptData : String?
    var shareSecret : String?
    var appleSubscriptionCode : String?
    var appleReceiptPayload : String?
    
    func getAllPremiumList(success: @escaping (_ subscriptionEnabled : String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = GetAllPremiumRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ParentApiManager.sharedInstance.getAllPremium(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetAllPremiumResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let premiumList = response.premiumList{
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(PremiumList.self))
                                    realm.add(premiumList)
                                }
                            }
                            
                            guard let subscriptionEnabled = response.subscriptionEnabled else{
                                return
                            }
                            
                            success(subscriptionEnabled)
                        }
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
    func verifySubscription(success: @escaping (_ recepitMessage : String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            iAPManager.shareInstance.verifySubscription(success: { (receiptInfo) in
                print("Receipt Info : \(receiptInfo)")
            }, failure: { (errorMessage) in
                print("Error Message : \(errorMessage)")
            })
            
        }
        
    }
    
    func getAllPurchasableProduct(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
            beforeApiCall?()
        
            iAPManager.shareInstance.getAllProductsInfo(success: { (products) in
                
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(iAPList.self))
                }
                
                for i in 0..<products.count{
                    
                    let productlist = iAPList()
                    productlist.productTitle = products[i].localizedTitle
                    productlist.productDescription = products[i].localizedDescription
                    productlist.productPrice = products[i].localizedPrice!
                    
                    try! realm.write {
                        realm.add(productlist)
                    }
                    
                }
                success()
                
            }, failure: { (message) in
                
                self.afterApiCall?()
                
                failure(message)
                
            })
        }
    }
    
    func subscribeProduct(productID : String, success: @escaping (_ recepitMessage : String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
            beforeApiCall?()
            
            iAPManager.shareInstance.purchaseProduct(productID: productID, success: { (receipt) in
                
                self.afterApiCall?()
                
                success(receipt["latest_receipt"] as! String)
                
            }, failure: { (message) in
                
                self.afterApiCall?()
                
                failure(message)
                
            })
            
        }
        
    }
    
    func UpdateIOSPremium(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            let data = UpdatePremiumRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.appleReceiptPayload = _BaseViewController().preferences.string(forKey: "latest_receipt") ?? ""
            data.country = profile.CountryRegistered!
            data.languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
            
            let premiumCodeStr = _BaseViewController().preferences.string(forKey: "productId") ?? ""
            if premiumCodeStr.length == 0 {
                data.appleSubscriptionCode = self.appleSubscriptionCode!
            } else {
                data.appleSubscriptionCode = _BaseViewController().preferences.string(forKey: "productId") ?? ""
            }
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeUpdateApiCall?()
                
                iAPManager.shareInstance.UpdateIOSPremium(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterUpdateApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        success()
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
    func getCurrentSubscription(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            iAPManager.shareInstance.getCurrentSubscription() { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
            
        }
    }
    
    func getAvailableSubscriptions(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            iAPManager.shareInstance.getAvailableSubscriptions() { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
            
        }
    }
}
