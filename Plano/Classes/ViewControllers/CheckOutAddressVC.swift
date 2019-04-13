//
//  CheckOutAddressVC.swift
//  Plano
//
//  Created by John Raja on 26/06/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit
import CountryPicker
import PopupDialog
import libPhoneNumber_iOS

class CheckOutAddressVC: _BaseViewController,UITextFieldDelegate,UINavigationControllerDelegate, CountryPickerDelegate{
    
    @IBOutlet weak var txtfd_CountryCode: UITextField!
    @IBOutlet weak var txtfd_MobileNUmber: UITextField!
    @IBOutlet weak var txtfd_EnterAddress: UITextField!
    @IBOutlet weak var vw_Submit_Outlet: UIView!
    @IBOutlet weak var lbl_AlertTop_Outlet: NSLayoutConstraint!
    @IBOutlet weak var lbl_AlertLeft_Outlet: NSLayoutConstraint!
    @IBOutlet weak var lbl_Alert_Outlet: UILabel!
    @IBOutlet weak var lbl_AddressHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_MobileNumberHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_CountryCodeHeader_Outlet: UILabel!
    @IBOutlet weak var vw_SelectCountryView_Outlet: UIView!
    @IBOutlet weak var pickerView_Outlet: CountryPicker!
    @IBOutlet weak var btn_DonePicker_Outlet: UIButton!
    @IBOutlet weak var img_FlagImage_Outlet: UIImageView!
    @IBOutlet weak var txtfd_PostalCode_Outlet: UITextField!
    @IBOutlet weak var lbl_PostalCode_Outlet: UILabel!
    @IBOutlet weak var pickerHeight_Outlet: NSLayoutConstraint!
    
    var appdelegate = UIApplication.shared.delegate as! AppDelegate
    var profile = ProfileData.getProfileObj()
    var pageFor = ""
    var postalCodeIs = ""
    var pahoneNumberIs = ""
    var countryCodeIs = ""
    var addressIs = ""
    var countryName = ""
    var phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtfd_MobileNUmber.delegate = self
        self.txtfd_EnterAddress.delegate = self
        self.txtfd_CountryCode.delegate = self
        self.txtfd_PostalCode_Outlet.delegate = self
        self.txtfd_MobileNUmber.returnKeyType = .next
        self.txtfd_CountryCode.returnKeyType = .next
        self.txtfd_PostalCode_Outlet.returnKeyType = .done
        self.vw_Submit_Outlet.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(self.mobileNumberValidation)))
        self.vw_Submit_Outlet.isUserInteractionEnabled = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(self.dismissKeyboard)))
        self.view.isUserInteractionEnabled = true
        
        self.txtfd_MobileNUmber.addTarget(self, action: #selector(textFieldDidChange1(_:)), for: .editingChanged)
        self.txtfd_EnterAddress.addTarget(self, action: #selector(textFieldDidChange2(_:)), for: .editingChanged)
        self.txtfd_PostalCode_Outlet.addTarget(self, action: #selector(textFieldDidChange3(_:)), for: .editingChanged)

        // Default Country Code for Singapore
        self.btn_DonePicker_Outlet.layer.cornerRadius = 8
        self.vw_SelectCountryView_Outlet.isHidden = true
        pickerView_Outlet.countryPickerDelegate = self
        pickerView_Outlet.showPhoneNumbers = true
        pickerView_Outlet.backgroundColor = UIColor.lightGray
        pickerView_Outlet.tintColor = UIColor.white
        pickerView_Outlet.layer.cornerRadius = 10
        pickerHeight_Outlet.constant = UIScreen.main.bounds.height - 150
        // Alert View at initial State
        self.lbl_Alert_Outlet.isHidden = true
        // check
        self.txtfd_CountryCode.text = self.countryCodeIs
        self.txtfd_MobileNUmber.text = self.pahoneNumberIs
        self.txtfd_EnterAddress.text = self.addressIs
        self.txtfd_PostalCode_Outlet.text = self.postalCodeIs
        if self.countryCodeIs.isEmpty
        {
            self.txtfd_CountryCode.text = "+65"
            self.img_FlagImage_Outlet.image = UIImage(named: "SG")
            self.countryName = "SG"
        }
        pickerView_Outlet.setCountryByPhoneCode(self.txtfd_CountryCode.text!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.pageFor == "Shipping"
        {
           WoopraTrackingPage().trackEvent(mainMode:"Shop Shipping Address Page",pageName:"Shipping Address Page",actionTitle:"Filling shipping address page")
        }
        else if self.pageFor == "Billing"
        {
            WoopraTrackingPage().trackEvent(mainMode:"Shop Billing Address Page",pageName:"Billing Address Page",actionTitle:"Filling billing address page")
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func btn_CountryCodePickup(_ sender: UIButton) {
        self.vw_SelectCountryView_Outlet.isHidden = false
        //get corrent country
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        //init Picker
        
        pickerView_Outlet.setCountry(code!)
    }
    
    @objc func vw_Submit_Action(){
        
        if self.validation() == true{
            if self.pageFor == "Shipping"
            {
                self.updatingBiilShipAddressInfo(billShipaddress:"ShippingAddress",billShipPostal:"ShippingPostcode",urlPass:"/Payment/UpdateShippingAddress")
            }
            else if self.pageFor == "Billing"
            {
                self.updatingBiilShipAddressInfo(billShipaddress:"BillingAddress",billShipPostal:"BillingPostcode",urlPass:"/Payment/UpdateBillingAddress")
            }
        }
    }
    
    @objc func mobileNumberValidation(){
        let phoneNumber = try?phoneUtil.parse(self.txtfd_MobileNUmber.text!, defaultRegion: self.countryName)
        if phoneUtil.isValidNumber(phoneNumber) == true{
            self.txtfd_MobileNUmber.textColor = UIColor.black
            self.vw_Submit_Action()
        }else{
            self.txtfd_MobileNUmber.textColor = UIColor.red
            self.gettingValidation(topValue:2,leftValue:150,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.red,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:5)
        }
    }
    // TextField Delegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == self.txtfd_MobileNUmber{
            let phoneNumber = try?phoneUtil.parse(self.txtfd_MobileNUmber.text!, defaultRegion: self.countryName)
            if phoneUtil.isValidNumber(phoneNumber) == true{
                self.txtfd_MobileNUmber.textColor = UIColor.black
                self.txtfd_MobileNUmber.resignFirstResponder()
                self.txtfd_EnterAddress.becomeFirstResponder()
            }else{
                self.txtfd_MobileNUmber.textColor = UIColor.red
                self.gettingValidation(topValue:2,leftValue:150,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.red,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:5)
            }
        }else if textField == self.txtfd_EnterAddress{
            self.txtfd_EnterAddress.resignFirstResponder()
            self.txtfd_PostalCode_Outlet.becomeFirstResponder()
        }else{
            self.txtfd_PostalCode_Outlet.resignFirstResponder()
            self.dismissKeyboard()
        }
        return true
    }
    
    // dismiss the keyboard presence
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func validation() -> Bool{
        
        if self.txtfd_CountryCode.text?.count == 0 || self.txtfd_CountryCode.text == "CC"{
            self.gettingValidation(topValue:2,leftValue:20,showHideValue:false,color1:UIColor.red,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:1)
            return false
        }else if self.txtfd_MobileNUmber.text?.count == 0{
            self.gettingValidation(topValue:2,leftValue:150,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.red,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:2)
            return false
        }else if self.txtfd_EnterAddress.text?.count == 0{
            self.gettingValidation(topValue:101,leftValue:20,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.red,color4:UIColor.lightGray,getState:3)
            return false
        }else if self.txtfd_PostalCode_Outlet.text?.count == 0{
            self.gettingValidation(topValue:202,leftValue:20,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.red,getState:4)
            return false
        }else{
            self.gettingValidation(topValue:0,leftValue:0,showHideValue:true,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:0)
            return true
        }
    }
    
    @objc func gettingValidation(topValue:CGFloat,leftValue:CGFloat,showHideValue:Bool,color1:UIColor,color2:UIColor,color3:UIColor,color4:UIColor,getState:Int){
        self.lbl_AlertTop_Outlet.constant = topValue
        self.lbl_AlertLeft_Outlet.constant = leftValue
        self.lbl_Alert_Outlet.isHidden = showHideValue
        self.lbl_CountryCodeHeader_Outlet.textColor = color1
        self.lbl_MobileNumberHeader_Outlet.textColor = color2
        self.lbl_AddressHeader_Outlet.textColor = color3
        self.lbl_PostalCode_Outlet.textColor = color4
        // Image for alert view
        
        if getState == 1{
            self.lbl_Alert_Outlet.text = "  Please enter the Country Code"
            self.lbl_Alert_Outlet.addImageWith(name: "iconTypeCritical", behindText: false)
        }else if getState == 2{
            self.lbl_Alert_Outlet.text = "  Please enter the Mobile Number"
            self.lbl_Alert_Outlet.addImageWith(name: "iconTypeCritical", behindText: false)
        }else if getState == 3{
            self.lbl_Alert_Outlet.text = "  Please enter the Address"
            self.lbl_Alert_Outlet.addImageWith(name: "iconTypeCritical", behindText: false)
        }else if getState == 4{
            self.lbl_Alert_Outlet.text = "  Please enter the Postal Code"
            self.lbl_Alert_Outlet.addImageWith(name: "iconTypeCritical", behindText: false)
        }else if getState == 5{
            self.lbl_Alert_Outlet.text = "  Please enter valid mobile number"
            self.lbl_Alert_Outlet.addImageWith(name: "iconTypeCritical", behindText: false)
        }else{
            self.lbl_Alert_Outlet.removeImage()
        }
    }
    
    @objc func textFieldDidChange1(_ textField: UITextField) {
        textField.textColor = UIColor.black
        if self.txtfd_CountryCode.text?.count == 0 || self.txtfd_CountryCode.text == "CC"{
            self.gettingValidation(topValue:2,leftValue:20,showHideValue:false,color1:UIColor.red,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:1)
            textField.text = ""
            textField.resignFirstResponder()
        }else if (textField.text?.count)! > 0{
            self.gettingValidation(topValue:0,leftValue:0,showHideValue:true,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:2)
        }
        else if (textField.text?.count)! == 0{
            self.gettingValidation(topValue:2,leftValue:150,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.red,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:2)
        }
    }
    
    @objc func textFieldDidChange2(_ textField: UITextField) {
        if self.txtfd_CountryCode.text?.count == 0 || self.txtfd_CountryCode.text == "CC"{
            self.gettingValidation(topValue:2,leftValue:20,showHideValue:false,color1:UIColor.red,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:1)
            textField.text = ""
            textField.resignFirstResponder()
            self.txtfd_MobileNUmber.becomeFirstResponder()
        }else if self.txtfd_MobileNUmber.text?.count == 0{
            self.gettingValidation(topValue:2,leftValue:150,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.red,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:2)
            textField.text = ""
            textField.resignFirstResponder()
            self.txtfd_MobileNUmber.becomeFirstResponder()
        }else if (textField.text?.count)! > 0{
            self.gettingValidation(topValue:0,leftValue:0,showHideValue:true,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:3)
        }else if (textField.text?.count)! == 0{
            self.gettingValidation(topValue:101,leftValue:20,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.red,color4:UIColor.lightGray,getState:3)
        }
    }
    
    @objc func textFieldDidChange3(_ textField: UITextField) {
        if self.txtfd_CountryCode.text?.count == 0 || self.txtfd_CountryCode.text == "CC"{
            self.gettingValidation(topValue:2,leftValue:20,showHideValue:false,color1:UIColor.red,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:1)
            textField.text = ""
            textField.resignFirstResponder()
            self.txtfd_PostalCode_Outlet.becomeFirstResponder()
        }else if self.txtfd_MobileNUmber.text?.count == 0{
            self.gettingValidation(topValue:2,leftValue:150,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.red,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:2)
            textField.text = ""
            textField.resignFirstResponder()
            self.txtfd_MobileNUmber.becomeFirstResponder()
        }else if self.txtfd_EnterAddress.text?.count == 0{
            self.gettingValidation(topValue:101,leftValue:20,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.red,color4:UIColor.lightGray,getState:3)
            textField.text = ""
            textField.resignFirstResponder()
            self.txtfd_EnterAddress.becomeFirstResponder()
        }else if (textField.text?.count)! > 0{
            self.gettingValidation(topValue:0,leftValue:0,showHideValue:true,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.lightGray,getState:4)
        }else if (textField.text?.count)! == 0{
            self.gettingValidation(topValue:202,leftValue:20,showHideValue:false,color1:UIColor.lightGray,color2:UIColor.lightGray,color3:UIColor.lightGray,color4:UIColor.red,getState:4)
        }
    }
    
    
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btn_DonePicker_Action(_ sender: UIButton) {
        self.vw_SelectCountryView_Outlet.isHidden = true
    }
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.txtfd_CountryCode.text = phoneCode
        self.img_FlagImage_Outlet.image = flag
        self.countryName = countryCode
    }
    
    func updatingBiilShipAddressInfo(billShipaddress:String,billShipPostal:String,urlPass:String){
        let json: [String: Any] = ["Email":self.profile!.email,"Access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID(),billShipaddress:self.txtfd_EnterAddress.text!,billShipPostal:self.txtfd_PostalCode_Outlet.text!]
        let url = URL(string: Constants.API.URL + "\(urlPass)")!
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
            if apiResponseHandler.isSuccess(){
                self.UpdateContact(countryCode:self.txtfd_CountryCode.text!,contactNumber:self.txtfd_MobileNUmber.text!)
            }else{
                self.showAlert(apiResponseHandler.errorMessage())
            }
        }
    }
    
    // Payment/UpdateContact
    func UpdateContact(countryCode:String,contactNumber:String){
        let json: [String: Any] = ["Email":self.profile!.email,"Access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID(),"ContactCountryCode":countryCode,"ContactNumber":contactNumber]
        let url = URL(string: Constants.API.URL + "/Payment/UpdateContact")!
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
            if apiResponseHandler.isSuccess(){
                self.showAlert(apiResponseHandler.message!, callBack: {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Wallet", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
                    
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.navigationController?.popViewController(animated: true)
                })
            }else{
                self.showAlert(apiResponseHandler.errorMessage())
            }
        }
    }
    
    @IBAction func goToNextPage(_ sender: Any) {
    }
    
}


