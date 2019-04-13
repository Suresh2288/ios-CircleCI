//
//  PaymentPageVC.swift
//  Plano
//
//  Created by John Raja on 02/07/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit
import Stripe
import SlideMenuControllerSwift

enum CardTypes {
    case amex, dinersClub, discover, JCB, masterCard, visa, unknown
}

class PaymentPageVC: _BaseViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var txtCardNumber_Outlet: UITextField!
    @IBOutlet weak var txtMonthDate_Outlet: UITextField!
    @IBOutlet weak var txtCvv_Outlet: UITextField!
    @IBOutlet weak var txtCardHolderName_Outlet: UITextField!
    @IBOutlet weak var vw_Success_Outlet: UIView!
    @IBOutlet weak var vw_Failure_Outlet: UIView!
    @IBOutlet weak var lbl_UUID_Outlet: UILabel!
    @IBOutlet weak var lbl_amount_Outlet: UILabel!
    @IBOutlet weak var vw_Transactionresult_Outlet: UIView!
    
    @IBOutlet weak var btn_PaymnetAction_Outlet: UIButton!
    let stripCard = STPCardParams()
    var publicKeyValue = ""
    var profile = ProfileData.getProfileObj()
    var productName = ""
    var productID = ""
    var productPriceValueIs = ""
    var shippingAddress = ""
    var shippingPostalCode = ""
    var billingAddress = ""
    var billingPostalCode = ""
    var countryCode = ""
    var countactNumber = ""
    var udidIs = ""
    var stateIs = "0"
    var getCardType : STPCardBrand!
    var appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.txtCardNumber_Outlet.delegate = self
        self.txtMonthDate_Outlet.delegate = self
        self.txtCvv_Outlet.delegate = self
        self.txtCardHolderName_Outlet.delegate = self
        self.txtCardNumber_Outlet.returnKeyType = .next
        self.txtMonthDate_Outlet.returnKeyType = .next
        self.txtCvv_Outlet.returnKeyType = .next
        self.txtCardHolderName_Outlet.returnKeyType = .done
        
        self.txtCardNumber_Outlet.addTarget(self, action: #selector(txtCardNumber_Action(_:)), for: .editingChanged)
        self.txtMonthDate_Outlet.addTarget(self, action: #selector(txtMonthDate_Action(_:)), for: .editingChanged)
        self.txtCvv_Outlet.addTarget(self, action: #selector(txtCvv_Action(_:)), for: .editingChanged)
        self.txtCardHolderName_Outlet.addTarget(self, action: #selector(txtCardHolderName_Action(_:)), for: .editingChanged)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(self.dismissKeyboard)))
        self.view.isUserInteractionEnabled = true
        
        // Initial Stage
        self.vw_Success_Outlet.isHidden = true
        self.vw_Failure_Outlet.isHidden = true
        self.vw_Transactionresult_Outlet.isHidden = true
        self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Shop Payment Page",pageName:"Payment Page",actionTitle:"Entered in Payment Page")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func txtCardNumber_Action(_ textField: UITextField) {
    }
    
    @objc func txtMonthDate_Action(_ textField: UITextField) {
        if textField.text?.count == 2{
            textField.text = textField.text! + "/"
        }}
    
    @objc func txtCvv_Action(_ textField: UITextField) {
    }
    
    @objc func txtCardHolderName_Action(_ textField: UITextField) {
    }
    
    // dismiss the keyboard presence
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    // TextField Delegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField{
        case txtCardNumber_Outlet :
            self.txtCardNumber_Outlet.resignFirstResponder()
            self.txtMonthDate_Outlet.becomeFirstResponder()
        case txtMonthDate_Outlet :
            self.txtMonthDate_Outlet.resignFirstResponder()
            self.txtCvv_Outlet.becomeFirstResponder()
        case txtCvv_Outlet :
            self.txtCvv_Outlet.resignFirstResponder()
            self.txtCardHolderName_Outlet.becomeFirstResponder()
        case txtCardHolderName_Outlet :
            self.txtCardHolderName_Outlet.resignFirstResponder()
            self.dismissKeyboard()
        default  :
            print("Empty")
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        switch textField{
        case txtCardNumber_Outlet :
            let maxLength = 30
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        case txtMonthDate_Outlet :
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                self.txtMonthDate_Outlet.text = ""
                return true
            }else{
                let maxLength = 5
                let currentString: NSString = textField.text! as NSString
                let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            }
        case txtCvv_Outlet :
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        case txtCardHolderName_Outlet :
            let maxLength = 25
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        default  :
            return false
        }}
    
    func validation(){
        if (self.txtCardNumber_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the card number")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtMonthDate_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the card expiry month and year")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtMonthDate_Outlet.text?.count)! < 4{
            self.showAlert("Please enter the valid card expiry month and year")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtCvv_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the cvv number")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtCvv_Outlet.text?.count)! < 4{
            self.showAlert("Please enter the valid cvv number")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtCardHolderName_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the card holder name")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else{
            stripCard.number = self.txtCardNumber_Outlet.text!
            stripCard.cvc = self.txtCvv_Outlet.text!
            let expMonthIS = self.txtMonthDate_Outlet.text!
            stripCard.expYear = UInt(expMonthIS.suffix(2))!
            stripCard.expMonth = UInt(expMonthIS.prefix(2))!
            self.passingCardType(stripeIs:stripCard)
        }
    }
    
    func testValidation(){
        if (self.txtCardNumber_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the card number")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtMonthDate_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the card expiry month and year")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtMonthDate_Outlet.text?.count)! < 4{
            self.showAlert("Please enter the valid card expiry month and year")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtCvv_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the cvv number")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtCvv_Outlet.text?.count)! < 3{
            self.showAlert("Please enter the valid cvv number")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else if (self.txtCardHolderName_Outlet.text?.isEmpty)!{
            self.showAlert("Please enter the card holder name")
            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
        }else{
            stripCard.number = self.txtCardNumber_Outlet.text!
            stripCard.cvc = self.txtCvv_Outlet.text!
            let expMonthIS = self.txtMonthDate_Outlet.text!
            stripCard.expYear = UInt(expMonthIS.suffix(2))!
            stripCard.expMonth = UInt(expMonthIS.prefix(2))!
            self.passingCardType(stripeIs:stripCard)
        }
    }
    
    @IBAction func btn_MakePayment_Action(_ sender: UIButton) {
        Stripe.setDefaultPublishableKey(self.publicKeyValue)
        self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = false
        if Constants.API.URL == "https://www.plano.co/planoapi/v1/"{
            self.validation()
        }else if Constants.API.URL == "https://staging.plano.co/planoapi/v1"{
            self.testValidation()
        }
    }
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func createStripeTransaction(passTokenIs:String){
        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID(),"token":passTokenIs,"productName":self.productName,"productID":self.productID,"currencyCode":"SGD","amount":self.productPriceValueIs,"shippingAddress":self.shippingAddress,"shippingPostcode":self.shippingPostalCode,"billingAddress":self.billingAddress,"billingPostcode":self.billingPostalCode,"contactCountryCode":self.countryCode,"contactNumber":self.countactNumber]
        let url = URL(string: Constants.API.URL + "/Payment/CreateStripeTransaction")!
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
            if apiResponseHandler.isSuccess(){
                WoopraTrackingPage().trackEvent(mainMode:"Shop Payment Page",pageName:"Payment Page",actionTitle:"Payment completed successfully")
                self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
                self.vw_Transactionresult_Outlet.isHidden = false
                let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                    let DataIS = myRespondataIs.object(forKey: "Data") as! NSDictionary
                    if DataIS.object(forKey: "OrderDetails") as? NSDictionary != nil{
                        let OrderDetails = DataIS.object(forKey: "OrderDetails") as! NSDictionary
                        if OrderDetails.object(forKey: "OrderUUID") as? String != nil{
                            self.udidIs = OrderDetails.object(forKey: "OrderUUID") as! String
                        }else if OrderDetails.object(forKey: "OrderUUID") as? Int != nil{
                            self.udidIs = String(OrderDetails.object(forKey: "OrderUUID") as! Int)
                        }
                        self.lbl_UUID_Outlet.text = self.udidIs
                        self.lbl_amount_Outlet.text = "$ \(self.productPriceValueIs)"
                        self.vw_Success_Outlet.isHidden = false
                        self.vw_Failure_Outlet.isHidden = true
                        self.stateIs = "1"
                    }else{
                        self.stateIs = "0"
                        self.vw_Success_Outlet.isHidden = true
                        self.vw_Failure_Outlet.isHidden = false
                    }}else{
                    self.vw_Success_Outlet.isHidden = true
                    self.vw_Failure_Outlet.isHidden = false
                    self.stateIs = "0"
                }
            }else{
                WoopraTrackingPage().trackEvent(mainMode:"Shop Payment Page",pageName:"Payment Page",actionTitle:"Having trouble on paymet")
                self.showAlert(apiResponseHandler.errorMessage())
                self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
            }}
    }
    
    @IBAction func btn_CloseTransactionView(_ sender: Any) {
        if self.stateIs == "0"{
            let vc = UIStoryboard.WalletNav()
            self.slideMenuController()?.changeMainViewController(vc, close: true)
        }else{
            let vc = UIStoryboard.MyOderListVCNav()
            self.slideMenuController()?.changeMainViewController(vc, close: true)
        }}
    
    @objc func passingCardType(stripeIs:STPCardParams){
        if Constants.API.URL == "https://www.plano.co/planoapi/v1/"{
            let expMonthIS = self.txtMonthDate_Outlet.text!
            if STPCardValidator.validationState(forExpirationMonth: String(expMonthIS.prefix(2))) == .valid{
                if STPCardValidator.validationState(forCard: stripeIs) == .valid{
                    STPAPIClient.shared().createToken(withCard: stripeIs) { (token: STPToken?, error: Error?) in
                        let token = token
                        if error == nil{
                            if (token?.tokenId.isEmpty)!{
                                self.showAlert("Please provide the valid card details")
                                self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
                            }else{
                                self.createStripeTransaction(passTokenIs:(token?.tokenId)!)
                            }
                        }else{
                            self.showAlert("Please provide the valid card details")
                            self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
                        }
                    }
                }else{
                    self.showAlert("Please check your card details")
                    self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
                }
            }else{
                self.showAlert("Please check your card expiry month")
                self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
            }
        }else if Constants.API.URL == "https://staging.plano.co/planoapi/v1"{
            if STPCardValidator.validationState(forCard: stripeIs) == .valid
            {
                STPAPIClient.shared().createToken(withCard: stripeIs) { (token: STPToken?, error: Error?) in
                    guard let token = token, error == nil else {
                        self.showAlert("Please check your card details")
                        self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
                        return
                    }
                    if token.tokenId.isEmpty{
                        self.showAlert("Please check your card details")
                        self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
                    }else{
                        self.createStripeTransaction(passTokenIs:token.tokenId)
                    }
                }
            }
            else{
                self.showAlert("Please check your card details")
                self.btn_PaymnetAction_Outlet.isUserInteractionEnabled = true
            }
        }
    }
    
}

