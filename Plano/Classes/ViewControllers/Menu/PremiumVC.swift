//
//  PremiumVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import PopupDialog
import Device
import ObjectMapper

class PremiumVC: _BaseViewController {
    
    @IBOutlet weak var premiumPrizeView : UIView!
    @IBOutlet weak var tblPremium : UITableView!
    
    @IBOutlet weak var lblPrivacyLink: AdaptiveLabel!
    @IBOutlet weak var lblTermsLink: AdaptiveLabel!
    
    @IBOutlet weak var premiumHolder : UIView!{
        didSet{
            premiumHolder.layer.shadowColor = UIColor.lightGray.cgColor
            premiumHolder.layer.shadowOpacity = 10
            premiumHolder.layer.shadowOffset = CGSize.zero
            premiumHolder.layer.shadowRadius = 10
        }
    }
    
    @IBOutlet weak var imgProfile : UIImageView!{
        didSet{
            imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
            imgProfile.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var lblPremiumInfo : UILabel!{
        didSet{
            lblPremiumInfo.numberOfLines = 0
        }
    }
    
    let placeholderImage = UIImage(named: "iconAvatar")
    var FamilyPrize : String = ""
    var AnnualPrize : String = ""
    
    var FreePackTitle : String = ""
    var FamilyPackTitle : String = ""
    var AnnualPackTitle : String = ""
    var SubscribePrompt : String = ""

    @IBOutlet weak var lblExpiresOn: UILabel!
    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    var viewModel = PremiumViewModel()
    var freeList : PremiumList?
    var liteList : PremiumList?
    var familyList : PremiumList?
    var annualList : PremiumList?
    var checkingApiCall = 0
    var blockApiCall = false
    var allowPremium = true
    
    var iAPProductList : Results<iAPList>!
    
    var isPresented : Bool = false
    var comeFromSetting : Bool = false
    var IsEnableSubscribe : Bool = false
    var IsEnableSubscribePrompt : Bool = false
    
    override var analyticsScreenName:String? {
        get {
            return "premium"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "premium"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Premium Page",pageName:"Premium Page",actionTitle:"Entered in Premium page")

        
        if parentVC != nil {
            removeLeftMenuGesture()
            setUpNavBarWithAttributes(navtitle: "Premium", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }else{
            setupMenuNavBarWithAttributes(navtitle: "Premium", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }
        
        setUpPremiumView()
        
        viewModelCallBack()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if self.preferences.string(forKey: "productId") == Constants.Products.FAMILY{
//            self.callCheckSubscription(sender:1)
//        }else if self.preferences.string(forKey: "productId") == Constants.Products.ANNUAL{
//            self.callCheckSubscription(sender:2)
//        }
        
    }
    
    func setUpPremiumView(){
        
        lblPremiumInfo.text = "If you choose to subscribe, you will be charged a price according to your country. The price will be shown in the app before you complete the payment. The subscription renews every month/year unless auto-renew is turned off at least 24 hours before end of the current subscription period. Your iTunes account will automatically be charged within 24-hours prior to the end of the current period and you will be charged for one month/year at at time. You can turn off auto-renew at any time from your iTunes account settings."
        
        lblPrivacyLink.attributedText = NSAttributedString(string: "Privacy Policy", attributes:
            convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue]))
        
        lblTermsLink.attributedText = NSAttributedString(string: "Terms & Conditions", attributes:
            convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue]))
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.tapLink(sender:)))
        lblPrivacyLink.tag = 1
        lblPrivacyLink.isUserInteractionEnabled = true
        lblPrivacyLink.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tapLink(sender:)))
        lblTermsLink.tag = 2
        lblTermsLink.isUserInteractionEnabled = true
        lblTermsLink.addGestureRecognizer(tap2)
        
        tblPremium.register(UINib(nibName : "PremiumCell", bundle : nil), forCellReuseIdentifier: "PremiumCell")
        tblPremium.register(UINib(nibName : "PremiumSecondCell", bundle : nil), forCellReuseIdentifier: "PremiumSecondCell")
        tblPremium.register(UINib(nibName : "SubscribeButtonCell", bundle : nil), forCellReuseIdentifier: "SubscribeButtonCell")
        
        tblPremium.estimatedRowHeight = 100
        tblPremium.rowHeight = UITableView.automaticDimension
        tblPremium.separatorInset.left = 20
        tblPremium.separatorInset.right = 20
        tblPremium.showsVerticalScrollIndicator = false
        tblPremium.tableFooterView = UIView(frame: .zero)
        
    }
    
    @objc func tapLink(sender:UITapGestureRecognizer) {
        let v = sender.view!
        let tag = v.tag
        
        if tag == 1 {
            guard let url = URL(string: "https://www.plano.co/privacy") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else if tag == 2 {
            guard let url = URL(string: "https://www.plano.co/terms") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPremiumData()
        GetCurrentSubscription()
        GetAvailableSubscriptions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if comeFromSetting{
            setUpNavBarWithAttributes(navtitle: "Settings".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
            comeFromSetting = false
        }
    }
    
    func getPremiumData(){
        showPremium()
    }
    
    func showPremium(){
        viewModel.getAllPurchasableProduct(success: { 
            
            self.viewModel.getAllPremiumList(success: { (subscriptionEnabled) in
                
                self.freeList = PremiumList.getPremiumListByOrderNo(orderNo: "1")
                self.liteList = PremiumList.getPremiumListByOrderNo(orderNo: "2")
                self.familyList = PremiumList.getPremiumListByOrderNo(orderNo: "3")
                self.annualList = PremiumList.getPremiumListByOrderNo(orderNo: "4")
                
                UIView.transition(with: self.tblPremium, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.iAPProductList = iAPList.getProductList()
                    
                    print(self.iAPProductList)
                    self.FamilyPrize = self.iAPProductList[0].productPrice
                    self.AnnualPrize = self.iAPProductList[1].productPrice
                    
                    self.tblPremium.reloadData()
                    
                }, completion: nil)
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
            }
            
        }) { (errorMessage) in
            self.showAlert("Fail to get the products".localized())
        }
    }
    
    @objc func SubscribeButtonClicked(_ sender : UIButton){
        
        if IsEnableSubscribe && !IsEnableSubscribePrompt {
            let vc = UIStoryboard.PopupToChoosePremiumPlan() as! PremiumPlanPopup
            
            vc.parentPopVC = self
            vc.modalPresentationStyle = .overFullScreen
            vc.MonthlyPrize = FamilyPrize
            vc.YearlyPrize = AnnualPrize
            vc.MonthlyTitle = FamilyPackTitle
            vc.YearlyTitle = AnnualPackTitle
            
            present(vc, animated: true, completion: nil)
        } else if IsEnableSubscribePrompt {
            self.showAlert(SubscribePrompt)
        }
        
    }
    
    func SubscribeMonthlyPlanClicked(){
        self.subscribingProduct(sender:1)
        
//        if self.allowPremium == true {
//            if blockApiCall == false {
//                if self.preferences.string(forKey: "productId") == Constants.Products.FAMILY {
//                    self.checkingApiCall = 1
//                    self.callCheckSubscription(sender:1)
//                } else {
//                    self.subscribingProduct(sender:1)
//                }
//            } else {
//                self.subscribingProduct(sender:1)
//            }
//        } else {
//            self.showAlert("Sorry you can't able to subscribe")
//        }
    }
    
    func SubscribeYearlyPlanClicked(){
        self.subscribingProduct(sender:2)
        
//        if self.allowPremium == true {
//            if blockApiCall == false {
//               if self.preferences.string(forKey: "productId") == Constants.Products.ANNUAL {
//                    self.checkingApiCall = 1
//                    self.callCheckSubscription(sender:2)
//                } else {
//                    self.subscribingProduct(sender:2)
//                }
//            } else{
//                self.subscribingProduct(sender:2)
//            }
//        } else{
//            self.showAlert("Sorry you can't able to subscribe")
//        }
    }
    
//    @IBAction func subscribeTapped(_ sender : UIButton){
//
//        if self.allowPremium == true{
//            if blockApiCall == false{
//                if self.preferences.string(forKey: "productId") == Constants.Products.FAMILY{
//                    self.checkingApiCall = 1
//                    self.callCheckSubscription(sender:1)
//                }else if self.preferences.string(forKey: "productId") == Constants.Products.ANNUAL{
//                    self.checkingApiCall = 1
//                    self.callCheckSubscription(sender:2)
//                }
//                else {
//                    self.subscribingProduct(sender:sender.tag)
//                }
//            }else{
//                self.subscribingProduct(sender:sender.tag)
//            }
//        }else{
//            self.showAlert("Sorry you can't able to subscribe")
//        }
    
        /*
        var productID = ""
        var premiumName = ""
        var premiumDuration = ""
        if sender.tag == 0{
            log.info("Lite Subscribed")
            productID = Constants.Products.LITE
            premiumName = "Lite"
            premiumDuration = "month"
        }else if sender.tag == 1{
            log.info("Family Subscribed")
            productID = Constants.Products.FAMILY
            premiumName = "Family"
            premiumDuration = "month"
            
        }else if sender.tag == 2{
            log.info("Annual Subscribed")
            productID = Constants.Products.ANNUAL
            premiumName = "Annual"
            premiumDuration = "year"
        }
        
         showAlert("", "You have selected the \(premiumName) plan at \(self.iAPProductList[sender.tag].productPrice)/\(premiumDuration). Your subscription will be renewed automatically.".localized(), "CANCEL".localized(), "PROCEED".localized(), callBackOne: nil, callBackTwo: {
            
            self.viewModel.subscribeProduct(productID: productID, success: { (receiptMessage) in
                self.viewModel.receiptData = receiptMessage
                self.viewModel.shareSecret = Constants.StoreConnect.SecretKey
                self.viewModel.premiumCode = ""
                self.viewModel.updatePremium(success: {
                    
                    self.showCompletionAlert(server_message: "You are now subscribed to \(premiumName) and every \(premiumDuration), the subscription will renew automatically.", isSuccess: true)
                    
                }, failure: { (errorMessage) in
                    self.showAlert("Error occur when subscribing premium. Please try again later".localized())
                })
                
            }, failure: { (errorMessage) in
                //self.showAlert(errorMessage)
            })
        })
        */
//    }
    
//    func callCheckSubscription(sender:Int){
//        let profile = ProfileData.getProfileObj()
//        let json: [String: Any] = ["email":profile!.email,"access_Token":profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID(),"device_Type": "iOS","appleReceiptPayload":self.preferences.string(forKey: "latest_receipt") ?? "","premiumCode":self.preferences.string(forKey: "productId") ?? ""]
//
//        print(json)
//        let url = URL(string: Constants.API.URL + "/Parent/CheckCurrentSubscription")!
//        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
//            print("json:\(json)")
//            print("url:\(url)")
//            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
//            if apiResponseHandler.isSuccess(){
//                if self.checkingApiCall == 1{
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
//                            let myDataIs = myRespondataIs.object(forKey: "Data") as! NSDictionary
//                            if myDataIs.object(forKey: "IsSubscribable") as? String != nil{
//                                let IsSubscribable = myDataIs.object(forKey: "IsSubscribable") as! String
//                                if IsSubscribable == "1"{
//                                    self.subscribingProduct(sender:sender)
//                                }else{
//                                    self.showAlert(myRespondataIs.object(forKey: "Message") as! String)
//                                }
//                            }else if myDataIs.object(forKey: "IsSubscribable") as? Int != nil{
//                                let IsSubscribable = myDataIs.object(forKey: "IsSubscribable") as! Int
//                                if IsSubscribable == 1{
//                                    self.subscribingProduct(sender:sender)
//                                }else{
//                                    self.showAlert(myRespondataIs.object(forKey: "Message") as! String)
//                                }
//                            }
//                        }
//                    }
//                }
//
//            }else{
//                if apiResponseHandler.errorCode == 130{
//                    self.allowPremium = false
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        self.showAlert("", myRespondataIs.object(forKey: "Message") as! String, "OK", callBack: {
//                        })
//                    }
//                }
//                else if apiResponseHandler.errorCode == 131{
//                    self.allowPremium = false
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        self.showAlert("", myRespondataIs.object(forKey: "Message") as! String, "OK", callBack: {
//                        })
//                    }
//                }
//                else if apiResponseHandler.errorCode == 999{
//                    self.allowPremium = false
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        self.showAlert("", myRespondataIs.object(forKey: "Message") as! String, "OK", callBack: {
//                        })
//                    }
//                }
//                else if apiResponseHandler.errorCode == 136{
//                    self.allowPremium = false
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        self.showAlert("", myRespondataIs.object(forKey: "Message") as! String, "OK", callBack: {
//                        })
//                    }
//                }
//                else if apiResponseHandler.errorCode == 120{
//
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        var premiumName = ""
//                        var premiumDuration = ""
//                        if self.preferences.string(forKey: "productId") == Constants.Products.LITE{
//                            premiumName = "Lite"
//                            premiumDuration = "month"
//                        }else if self.preferences.string(forKey: "productId") == Constants.Products.FAMILY{
//                            premiumName = "Family"
//                            premiumDuration = "month"
//                        }else if self.preferences.string(forKey: "productId") == Constants.Products.ANNUAL{
//                            premiumName = "Annual"
//                            premiumDuration = "year"
//                        }
//                        self.showAlert("", myRespondataIs.object(forKey: "Message") as! String, "OK", "Cancel", callBackOne: {
//                            iAPManager.shareInstance.verifySubscription(success: { (receiptInfo) in
//                                print("Receipt Info : \(receiptInfo)")
//                                self.viewModel.UpdateIOSPremium(success: {
//                                    self.GetCurrentSubscription()
//                                }, failure: { (errorMessage) in
//                                    self.showAlert("Error occur when subscribing premium. Please try again later".localized())
//                                })
//                            }, failure: { (errorMessage) in
//                                self.showAlert(errorMessage)
//                            })
//                        }, callBackTwo: nil)
//                    }
//                }else{
//                    if apiResponseHandler.jsonObject as? NSDictionary != nil{
//                        let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
//                        var premiumName = ""
//                        var premiumDuration = ""
//                        if self.preferences.string(forKey: "productId") == Constants.Products.LITE{
//                            premiumName = "Lite"
//                            premiumDuration = "month"
//                        }else if self.preferences.string(forKey: "productId") == Constants.Products.FAMILY{
//                            premiumName = "Family"
//                            premiumDuration = "month"
//                        }else if self.preferences.string(forKey: "productId") == Constants.Products.ANNUAL{
//                            premiumName = "Annual"
//                            premiumDuration = "year"
//                        }
//                        self.showAlert("", myRespondataIs.object(forKey: "Message") as! String, "OK", "Cancel", callBackOne: {
//                            iAPManager.shareInstance.verifySubscription(success: { (receiptInfo) in
//                                print("Receipt Info : \(receiptInfo)")
//                                self.viewModel.UpdateIOSPremium(success: {
//                                    self.showAlert("", "You are now subscribed to \(premiumName) and every \(premiumDuration), the subscription will renew automatically.", "OK", callBack: {
//
//                                        self.GetCurrentSubscription()
//                                    })
//                                }, failure: { (errorMessage) in
//                                    self.showAlert("Error occur when subscribing premium. Please try again later".localized())
//                                })
//                            }, failure: { (errorMessage) in
//                                print("Error Message : \(errorMessage)")
//                                self.showAlert(errorMessage)
//                            })
//                        }, callBackTwo: nil)
//                    }
//                }
//            }
//        }
//    }
    
    func subscribingProduct(sender:Int){
        var productID = ""
        var premiumName = ""
        var premiumDuration = ""
        if sender == 0{
            log.info("Lite Subscribed")
            productID = Constants.Products.LITE
            premiumName = "Lite"
            premiumDuration = "month"
        }else if sender == 1{
            log.info("Family Subscribed")
            productID = Constants.Products.FAMILY
            premiumName = "Family"
            premiumDuration = "month"
            
        }else if sender == 2{
            log.info("Annual Subscribed")
            productID = Constants.Products.ANNUAL
            premiumName = "Annual"
            premiumDuration = "year"
        }
        
        showAlert("", "You have selected the \(premiumName) plan at \(self.iAPProductList[sender].productPrice)/\(premiumDuration). Your subscription will be renewed automatically.".localized(), "CANCEL".localized(), "PROCEED".localized(), callBackOne: nil, callBackTwo: {
            
            self.viewModel.subscribeProduct(productID: productID, success: { (receiptMessage) in
                self.viewModel.receiptData = receiptMessage
                self.viewModel.shareSecret = Constants.StoreConnect.SecretKey
                self.viewModel.premiumCode = "1"
                self.viewModel.appleSubscriptionCode = productID
                
                iAPManager.shareInstance.verifySubscription(success: { (receiptInfo) in
                    self.viewModel.UpdateIOSPremium(success: {
                        
                        self.showCompletionAlert(server_message: "You are now subscribed to \(premiumName) and every \(premiumDuration), the subscription will renew automatically.", isSuccess: true)
                        
                        self.GetCurrentSubscription()
                        
                    }, failure: { (errorMessage) in
                        print("Error Message : \(errorMessage)")
                        self.showAlert(errorMessage)
                    })
                }, failure: { (errorMessage) in
                    print("Error Message : \(errorMessage)")
                    self.showAlert(errorMessage)
                })
                
            }, failure: { (errorMessage) in
                self.showAlert(errorMessage)
            })
        })
    }
    
    func GetCurrentSubscription() {
        
        viewModel.getCurrentSubscription { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess() {
                
                if let response = Mapper<CurrentSubscriptionResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                    
                    self.IsEnableSubscribe = response.IsEnableSubscribe
                    self.IsEnableSubscribePrompt = response.IsEnableSubscribePrompt
                    
                    if self.IsEnableSubscribePrompt {
                        self.SubscribePrompt = response.SubscribePrompt
                    }
                    
                    if response.IsExpiryDateDisplay {
                        self.lblExpiresOn.text = "Expires on: " + response.DateValue
                        self.lblExpiresOn.isHidden = false
                    } else {
                        self.lblExpiresOn.isHidden = true
                    }
                    
                    self.lblUserName.text = response.ParentName
                    self.lblAccountName.text = "Account: " + response.PlanoPremiumTitle
                    
                    let profile = ProfileData.getProfileObj()
                    self.imgProfile.kf.setImage(with: URL(string: (profile?.profileImage)!), placeholder: self.placeholderImage,options: [.forceRefresh])
                    
                    self.tblPremium.reloadData()
                }
                
            }
            
//        viewModel.getCurrentSubscription { (response) in
//
//            if (response.jsonObject != nil) {
//                let dict = response.jsonObject as! NSDictionary
//
//                let dictData = dict.value(forKey: "Data") as! NSDictionary
//                let DateValue = dictData.value(forKey: "DateValue") as! String
//                let ParentName = dictData.value(forKey: "ParentName") as! String
//                let PlanoPremiumTitle = dictData.value(forKey: "PlanoPremiumTitle") as! String
//                let IsExpiryDateDisplay = dictData.value(forKey: "IsExpiryDateDisplay") as! Bool
//                self.IsEnableSubscribe = dictData.value(forKey: "IsEnableSubscribe") as! Bool
//                self.IsEnableSubscribePrompt = dictData.value(forKey: "IsEnableSubscribePrompt") as! Bool
//
//                if self.IsEnableSubscribePrompt {
//                    if (dictData.value(forKey: "SubscribePrompt") == nil) {
//                        self.SubscribePrompt = "Premium Features is not available now. Please try again later"
//                    } else {
//                        self.SubscribePrompt = dictData.value(forKey: "SubscribePrompt") as! String
//                    }
//                }
//
//                if IsExpiryDateDisplay {
//                    self.lblExpiresOn.text = "Expires on: " + DateValue
//                    self.lblExpiresOn.isHidden = false
//                } else {
//                    self.lblExpiresOn.isHidden = true
//                }
//
//                self.lblUserName.text = ParentName
//                self.lblAccountName.text = "Account: " + PlanoPremiumTitle
//
//                let profile = ProfileData.getProfileObj()
//                self.imgProfile.kf.setImage(with: URL(string: (profile?.profileImage)!), placeholder: self.placeholderImage,options: [.forceRefresh])
//
//                self.tblPremium.reloadData()
//            }
        }
    }
    
    func GetAvailableSubscriptions() {
        
        viewModel.getAvailableSubscriptions { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess() {
                
                if let response = Mapper<GetAvailablePremiumResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                    
                    if (response.AvailablePlans?.count)! > 0 {
                        self.FreePackTitle = (response.AvailablePlans?[0].TitleKey)!
                        self.FamilyPackTitle = (response.AvailablePlans?[1].TitleKey)!
                        self.AnnualPackTitle = (response.AvailablePlans?[2].TitleKey)!
                    }
                }
                
            }
            
//        viewModel.getAvailableSubscriptions { (response) in
//
//            if (response.jsonObject != nil) {
//                let dict = response.jsonObject as! NSDictionary
//
//                let dictData = dict.value(forKey: "Data") as! NSDictionary
//                let AvailablePlans = dictData.value(forKey: "AvailablePlans") as! NSArray
//
//                if AvailablePlans.count > 0 {
//                    self.FreePackTitle = ((AvailablePlans as NSArray).object(at: 0) as AnyObject).value(forKey: "TitleKey") as! String
//                    self.FamilyPackTitle = ((AvailablePlans as NSArray).object(at: 1) as AnyObject).value(forKey: "TitleKey") as! String
//                    self.AnnualPackTitle = ((AvailablePlans as NSArray).object(at: 2) as AnyObject).value(forKey: "TitleKey") as! String
//                }
//            }
        }
    }
    //MARK: - Popups
    func showCompletionAlert(server_message : String, isSuccess : Bool){
        
        var title = ""
        
        if isSuccess{
            title = "Successful".localized()
        }
        
        let message = server_message.localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "OK".localized()) {
            
            self.getPremiumData()
            self.getMasterDataInBackground()
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewModelCallBack(){
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.beforeUpdateApiCall = {
            HUD.show(.label("Payment was processing"))
        }
        
        viewModel.afterUpdateApiCall = {
            HUD.hide()
        }
        
    }

}

extension PremiumVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if freeList == nil{
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat
    {
        if indexPath.row == 0 {
            if IsEnableSubscribe {
                return 85.0
            }
            return 0
        }
        else if indexPath.row == 1 {
            return 225.0
        }
        else if indexPath.row == 14 {
            if IsEnableSubscribe {
                return 85.0
            }
            return 0
        }
        return 122.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell") as! SubscribeButtonCell

            cell.btnSubscribe.addTarget(self, action: #selector(PremiumVC.SubscribeButtonClicked(_:)), for: .touchUpInside)
            
            if IsEnableSubscribe {
                cell.btnSubscribe.isHidden = false
            } else {
                cell.btnSubscribe.isHidden = true
            }

            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumCell") as! PremiumCell
            
            if (self.FamilyPrize.length > 0) {
                cell.lblFreePack.text = String(self.FamilyPrize[0]) + " 0"
            }
            
            cell.lblFamilyPack.text = self.FamilyPrize
            cell.lblAnnualPack.text = self.AnnualPrize
            cell.lblFreePackTitle.text = self.FreePackTitle
            cell.lblAnnualPackTitle.text = self.AnnualPackTitle
            cell.lblFamilyPackTitle.text = self.FamilyPackTitle
            
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Loyalty Discount".localized()
            cell.imgFreePack.image = UIImage(named : "iconCross")
            cell.imgFamilyPack.image = UIImage(named : "iconCross")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "LinkPoints Bonus".localized()
            cell.imgFreePack.image = UIImage(named : "iconCross")
            cell.imgFamilyPack.image = UIImage(named : "iconCross")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "LinkPoints Eligibility".localized()
            cell.imgFreePack.image = UIImage(named : "iconCross")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Set Safe Area for Device Use".localized()
            cell.imgFreePack.image = UIImage(named : "iconCross")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Alerts for Incorrect Device Use".localized()
            cell.imgFreePack.image = UIImage(named : "iconCross")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Digital Health Report".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Blue Light Filter".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Daily Eye Calibration".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Time on Device Tracking".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 11 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Daily Posture Check".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 12 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "Low Light Detection".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        } else if indexPath.row == 13 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "plano points & Shop Vouchers".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = false
            
            return cell
        } else if indexPath.row == 14 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeButtonCell") as! SubscribeButtonCell
            
            cell.btnSubscribe.addTarget(self, action: #selector(PremiumVC.SubscribeButtonClicked(_:)), for: .touchUpInside)
            
            if IsEnableSubscribe {
                cell.btnSubscribe.isHidden = false
            } else {
                cell.btnSubscribe.isHidden = true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumSecondCell") as! PremiumSecondCell
            
            cell.lblTitle.text = "".localized()
            cell.imgFreePack.image = UIImage(named : "iconTick")
            cell.imgFamilyPack.image = UIImage(named : "iconTick")
            cell.imgAnnualPack.image = UIImage(named: "iconTick")
            cell.lblInfo.isHidden = true
            
            return cell
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
