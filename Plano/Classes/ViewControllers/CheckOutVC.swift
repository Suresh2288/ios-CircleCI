//
//  CheckOutVC.swift
//  Plano
//
//  Created by John Raja on 25/06/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit
import Device

class CheckOutVC: _BaseViewController {
    
    @IBOutlet weak var lbl_SubTotal_Outlet: UILabel!
    @IBOutlet weak var lbl_OrderTotal_Outlet: UILabel!
    @IBOutlet weak var stk_AddressDetail_Outlet: UIStackView!
    @IBOutlet weak var vw_BillingAddressDetail_Outlet: UIView!
    @IBOutlet weak var vw_ShippingAddressDetail_Outlet: UIView!
    @IBOutlet weak var vw_BillingAddress_Outlet: UIView!
    @IBOutlet weak var vw_ShippngAddress_Outlet: UIView!
    @IBOutlet weak var stk_Addess_Outlet: UIStackView!
    @IBOutlet weak var vw_ShippingAddressCorner_Outlet: UIView!
    @IBOutlet weak var vw_BillingAddressCorner_Outlet: UIView!
    @IBOutlet weak var lbl_BillingAddressText_Outlet: UILabel!
    @IBOutlet weak var lbl_ShippingAddressText_Outlet: UILabel!
    @IBOutlet weak var shippingAddressDetailHeight: NSLayoutConstraint!
    @IBOutlet weak var billingAddressDetailHeight: NSLayoutConstraint!
    @IBOutlet weak var billingAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var shippingAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var vw_Submit_Action: UIView!
    @IBOutlet weak var vw_BaseView_Outlet: UIView!
    @IBOutlet weak var vw_LoadingBack_Outlet: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel = ParentWalletViewModel()
    var appdelegate = UIApplication.shared.delegate as! AppDelegate
    var profile = ProfileData.getProfileObj()
    var shippingBillingData = [StoreData]()
    var productPriceValue = "0.0"
    var billignOrShipping = ""
    var passPostalCode = ""
    var passPhoneNumber = ""
    var passCountryCode = ""
    var passAddress = ""
    var publishKeyIs = ""
    var productNameIs = ""
    var productIDIs = ""
    
    var isFromProgressView : Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.productPriceValue = self.appdelegate.passPriceValue
        self.vw_ShippingAddressCorner_Outlet.layer.cornerRadius = 8
        self.vw_BillingAddressCorner_Outlet.layer.cornerRadius = 8
        self.lbl_SubTotal_Outlet.text = "$ \(productPriceValue)"
        self.lbl_OrderTotal_Outlet.text = "$ \(productPriceValue)"
        
        self.vw_BillingAddressDetail_Outlet.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(vw_BillingAddressDetail_Action)))
        self.vw_BillingAddressDetail_Outlet.isUserInteractionEnabled = true
        
        self.vw_ShippingAddressDetail_Outlet.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(vw_ShippingAddressDetail_Action)))
        self.vw_ShippingAddressDetail_Outlet.isUserInteractionEnabled = true
        
        self.vw_Submit_Action.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(goToPayment)))
        self.vw_Submit_Action.isUserInteractionEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Shop Checkout Page",pageName:"Checkout Page",actionTitle:"Entered in checkout page")

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.getParentPaymentInfo()
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        
        if (isFromProgressView) {
            for controller in self.navigationController!.viewControllers as Array {
                
                if Device.size() >= .screen7_9Inch{
                    if controller.isKind(of: ChildProgressVCiPad.self) {
                       
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
                else {
                    if controller.isKind(of: ChildProgressVC.self) {
                       
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            }
        }
        else {
            let vc = UIStoryboard.WalletNav()
            self.slideMenuController()?.changeMainViewController(vc, close: true)
        }
        
    }
    
    func billingShowHide(shipaddView1:Bool,shipaddView2:Bool,height1:CGFloat,height2:CGFloat){
        self.vw_BillingAddressDetail_Outlet.isHidden = shipaddView2
        self.vw_BillingAddress_Outlet.isHidden = shipaddView1
        self.billingAddressHeight.constant = height1
        self.billingAddressDetailHeight.constant = height2
    }
    
    func shippingShowHide(shipaddView1:Bool,shipaddView2:Bool,height1:CGFloat,height2:CGFloat){
        self.vw_ShippingAddressDetail_Outlet.isHidden = shipaddView2
        self.vw_ShippngAddress_Outlet.isHidden = shipaddView1
        self.shippingAddressHeight.constant = height1
        self.shippingAddressDetailHeight.constant = height2
    }
    
    @IBAction func btn_ShippingAddress_Action(_ sender: UIButton) {
        self.vw_ShippingAddressDetail_Action()
    }
    
    @IBAction func btn_BillingAddress_Action(_ sender: UIButton) {
        self.vw_BillingAddressDetail_Action()
    }
    
    @objc func goToCheckOutAddressVC(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Wallet", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CheckOutAddressVC") as! CheckOutAddressVC
        if self.passPostalCode != "0" && self.passPhoneNumber != "0"{
            nextViewController.postalCodeIs = self.passPostalCode
            nextViewController.pahoneNumberIs = self.passPhoneNumber
            nextViewController.countryCodeIs = self.passCountryCode
            nextViewController.addressIs = self.passAddress
        }
        nextViewController.pageFor = self.billignOrShipping
        self.navigationController?.pushViewController(nextViewController,animated: true)
    }
    
    func getParentPaymentInfo(){
        self.activityIndicator.startAnimating()
        self.vw_LoadingBack_Outlet.isHidden = false
        self.activityIndicator.isHidden = false
        self.shippingBillingData.removeAll()
//        let json: [String: Any] = ["Email":self.profile!.email,"Access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID()]
//        let url = URL(string: Constants.API.URL + "/Payment/GetParentPaymentInfo")!
//        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
        
        viewModel.getParentPaymentInfo { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess(){
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let DataIS = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        let dataClassIs = StoreData()
                        // BillingAddress
                        if (DataIS as AnyObject).object(forKey: "BillingAddress") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "BillingAddress") as! String != ""{
                                dataClassIs.setBillingAddress(billingAddress: (DataIS as AnyObject).object(forKey: "BillingAddress") as! String)
                            }else{
                                dataClassIs.setBillingAddress(billingAddress: "0")
                            }
                        }else{
                            dataClassIs.setBillingAddress(billingAddress: "0")
                        }
                        // BillingPostcde
                        if (DataIS as AnyObject).object(forKey: "BillingPostcde") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "BillingPostcde") as! String != ""{
                                dataClassIs.setBillingPostcde(billingPostcde: (DataIS as AnyObject).object(forKey: "BillingPostcde") as! String)
                            }else{
                                dataClassIs.setBillingPostcde(billingPostcde: "0")
                            }
                        }else if (DataIS as AnyObject).object(forKey: "BillingPostcde") as? Int != nil{
                            dataClassIs.setBillingPostcde(billingPostcde: String((DataIS as AnyObject).object(forKey: "BillingPostcde") as! Int))
                        }else{
                            dataClassIs.setBillingPostcde(billingPostcde: "0")
                        }
                        // ContactCountryCode
                        if (DataIS as AnyObject).object(forKey: "ContactCountryCode") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "ContactCountryCode") as! String != ""{
                                dataClassIs.setContactCountryCode(contactCountryCode: (DataIS as AnyObject).object(forKey: "ContactCountryCode") as! String)
                                self.passCountryCode = (DataIS as AnyObject).object(forKey: "ContactCountryCode") as! String
                            }else{
                                dataClassIs.setContactCountryCode(contactCountryCode: "0")
                                self.passCountryCode = "0"
                            }
                        }else if (DataIS as AnyObject).object(forKey: "ContactCountryCode") as? Int != nil{
                            dataClassIs.setContactCountryCode(contactCountryCode: String((DataIS as AnyObject).object(forKey: "ContactCountryCode") as! Int))
                            self.passCountryCode = String((DataIS as AnyObject).object(forKey: "ContactCountryCode") as! Int)
                        }else{
                            dataClassIs.setContactCountryCode(contactCountryCode: "0")
                            self.passCountryCode = "0"
                        }
                        // ContactNumber
                        if (DataIS as AnyObject).object(forKey: "ContactNumber") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "ContactNumber") as! String != ""{
                                dataClassIs.setContactNumber(contactNumber: (DataIS as AnyObject).object(forKey: "ContactNumber") as! String)
                                self.passPhoneNumber = (DataIS as AnyObject).object(forKey: "ContactNumber") as! String
                            }else{
                                dataClassIs.setContactNumber(contactNumber: "0")
                                self.passPhoneNumber = "0"
                            }
                        }else if (DataIS as AnyObject).object(forKey: "ContactNumber") as? Int != nil{
                            dataClassIs.setContactNumber(contactNumber: String((DataIS as AnyObject).object(forKey: "ContactNumber") as! Int))
                            self.passPhoneNumber = String((DataIS as AnyObject).object(forKey: "ContactNumber") as! Int)
                        }else{
                            dataClassIs.setContactNumber(contactNumber: "0")
                            self.passPhoneNumber = "0"
                        }
                        
                        // ShippingAddress
                        if (DataIS as AnyObject).object(forKey: "ShippingAddress") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "ShippingAddress") as! String != ""{
                                dataClassIs.setShippingAddress(shippingAddress: (DataIS as AnyObject).object(forKey: "ShippingAddress") as! String)
                            }else{
                                dataClassIs.setShippingAddress(shippingAddress: "0")
                            }
                        }else{
                            dataClassIs.setShippingAddress(shippingAddress: "0")
                        }
                        // ShippingPostcode
                        if (DataIS as AnyObject).object(forKey: "ShippingPostcode") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "ShippingPostcode") as! String != ""{
                                dataClassIs.setShippingPostcode(shippingPostcode: (DataIS as AnyObject).object(forKey: "ShippingPostcode") as! String)
                            }else{
                                dataClassIs.setShippingPostcode(shippingPostcode: "0")
                            }
                        }else if (DataIS as AnyObject).object(forKey: "ShippingPostcode") as? Int != nil{
                            dataClassIs.setShippingPostcode(shippingPostcode: String((DataIS as AnyObject).object(forKey: "ShippingPostcode") as! Int))
                        }else{
                            dataClassIs.setShippingPostcode(shippingPostcode: "0")
                        }
                        self.shippingBillingData.append(dataClassIs)
                    }
                    var shippingPay = 0
                    var billingPay = 0
                    if self.shippingBillingData[0].getBillingAddress() == "0" ||  self.shippingBillingData[0].getBillingPostcde() == "0" ||  self.shippingBillingData[0].getContactCountryCode() == "0" ||   self.shippingBillingData[0].getContactNumber() == "0"{
                        self.billingShowHide(shipaddView1:false,shipaddView2:true,height1:60.0,height2:0.0)
                        shippingPay = 0
                    }else{
                        self.billingShowHide(shipaddView1:true,shipaddView2:false,height1:0.0,height2:100.0)
                        shippingPay = 1
                    }
                    if self.shippingBillingData[0].getShippingAddress() == "0" ||  self.shippingBillingData[0].getShippingPostcode() == "0" ||  self.shippingBillingData[0].getContactCountryCode() == "0" ||   self.shippingBillingData[0].getContactNumber() == "0"{
                        self.shippingShowHide(shipaddView1:false,shipaddView2:true,height1:60.0,height2:0.0)
                        billingPay = 0
                    }else{
                        self.shippingShowHide(shipaddView1:true,shipaddView2:false,height1:0.0,height2:100.0)
                        billingPay = 1
                    }
                    self.lbl_BillingAddressText_Outlet.text = self.shippingBillingData[0].getBillingAddress()
                    self.lbl_ShippingAddressText_Outlet.text = self.shippingBillingData[0].getShippingAddress()
                    if shippingPay == 1 && shippingPay == 1{
                        self.vw_Submit_Action.isHidden = false
                    }else{
                        self.vw_Submit_Action.isHidden = true
                    }
                }
            }
            self.activityIndicator.stopAnimating()
            self.vw_LoadingBack_Outlet.isHidden = true
            self.activityIndicator.isHidden = true
        }
    }
    
    @objc func vw_BillingAddressDetail_Action(){
        self.passPostalCode = self.shippingBillingData[0].getBillingPostcde()
        self.passAddress = self.shippingBillingData[0].getBillingAddress()
        self.billignOrShipping = "Billing"
        self.goToCheckOutAddressVC()
    }
    
    @objc func vw_ShippingAddressDetail_Action(){
        self.passPostalCode = self.shippingBillingData[0].getShippingPostcode()
        self.passAddress = self.shippingBillingData[0].getShippingAddress()
        self.billignOrShipping = "Shipping"
         self.goToCheckOutAddressVC()
    }
    
    @objc func goToPayment(){
        self.getPaymentSettings()
        
    }
    
    func getPaymentSettings(){
//        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID()]
//        let url = URL(string: Constants.API.URL + "/Payment/GetPaymentSettings")!
//        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
        
        viewModel.getPaymentSettings { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess(){
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let DataIS = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        if DataIS.object(forKey: "PaymentSettings") as? NSDictionary != nil{
                            let PaymentSettings = DataIS.object(forKey: "PaymentSettings") as! NSDictionary
                            if PaymentSettings.object(forKey: "StripeSettings") as? NSDictionary != nil{
                                let StripeSettings = PaymentSettings.object(forKey: "StripeSettings") as! NSDictionary
                                if StripeSettings.object(forKey: "publishablekey") as? String != nil{
                                    self.publishKeyIs = StripeSettings.object(forKey: "publishablekey") as! String
                                }else if StripeSettings.object(forKey: "publishablekey") as? Int != nil{
                                    self.publishKeyIs = String(StripeSettings.object(forKey: "publishablekey") as! Int)
                                }
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Wallet", bundle:nil)
                                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PaymentPageVC") as! PaymentPageVC
                                nextViewController.publicKeyValue = self.publishKeyIs
                                nextViewController.productName = self.productNameIs
                                nextViewController.productID = self.productIDIs
                                nextViewController.productPriceValueIs = self.productPriceValue
                                nextViewController.shippingAddress = self.shippingBillingData[0].getShippingAddress()
                                nextViewController.shippingPostalCode = self.shippingBillingData[0].getShippingPostcode()
                                nextViewController.billingAddress = self.shippingBillingData[0].getBillingAddress()
                                nextViewController.billingPostalCode = self.shippingBillingData[0].getBillingPostcde()
                                nextViewController.countryCode = self.shippingBillingData[0].getContactCountryCode()
                                nextViewController.countactNumber = self.shippingBillingData[0].getContactNumber()
                                self.navigationController?.pushViewController(nextViewController,animated: true)
                            }
                        }
                    }
                }
            }else{
                self.showAlert(apiResponseHandler.errorMessage())
            }
        }
    }
}
