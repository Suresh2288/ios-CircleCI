//
//  ForgotPasswordVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PKHUD
import PopupDialog

class ForgotPasswordVC: _BaseViewController {
    
    @IBOutlet weak var lblForgotPassword: UILabel!
  
    override var analyticsScreenName:String? {
        get {
            return "forgot"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "forgot"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }

    var viewModel = ForgetPasswordViewModel()
    
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmailTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var btnClosePopup: UIButton!
    var IsShowClosePopup = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTextFields()
        initFloatingLabels()
        viewModelCallBack()
       
        setUpNavBarWithAttributes(navtitle: "", setStatusBarStyle: .lightContent, isTransparent: true, tintColor: UIColor.clear, titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        
        lblForgotPassword.text = "Forgot password".localized()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Forgot Password Page",pageName:"Forgot Password Page",actionTitle:"Entered in Forgot Password Page")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if IsShowClosePopup {
            btnClosePopup.isHidden = false
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
    }
    func viewModelCallBack() {
        
        viewModel.isEmailValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtEmail.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtEmail)
                }
              //  me.btnSubmit.isEnabled = validationObj.isValid
            }
        }
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
    
    func gotoNextScreen() {
        
        viewModel.forgetPasswordApi(success: {[weak self] (_ message:String?) in
            WoopraTrackingPage().trackEvent(mainMode:"Parent Forgot Password Page",pageName:"Forgot Password Page",actionTitle:"Forgot Password submitted")

            self?.showStandardDialog(animated: true, message: message)
            
        }) {(validationObj) in
            
            log.debug("Login fail")
//            self?.lblLoginFail.isHidden = validationObj.isValid
            self.showStandardDialog(animated: true, message: validationObj.message()?.localized())
        }
    }
    
    func initTextFields() {
        txtEmail.returnKeyType = .done
        txtEmail.keyboardType = .emailAddress
       //  btnSubmit.isEnabled = false      // Submit Button Hidden
    }
    
    func initFloatingLabels() {
        
        // config Fonts, Format, etc
        configFloatingLabel(txtEmail)
        txtEmail.delegate = self

        
        // move up the floatingLabel for initial load
        pushUpFloatingLabel(txtEmail)
        
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 8
        if(textField == txtEmail){
            txtEmailTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = -5
        if(textField == txtEmail){
            txtEmailTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }

    @IBAction func btnSubmitClicked(_ sender: Any) {
        gotoNextScreen()
    }
    
    func showStandardDialog(animated: Bool = true, message:String?) {
        
        // Prepare the popup
        let title = "ForgotPassword".localized()
        let message = "Please check the email you entered to create a new password".localized()

        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let ok = DefaultButton(title: "OPEN EMAIL".localized()) {
        
            let googleUrlString = "googlegmail://"
            if let googleUrl = NSURL(string: googleUrlString) {
                // show alert to choose app
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(googleUrl as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (complete) in
                        if let url = NSURL(string: "message:"){
                            UIApplication.shared.openURL(url as URL)
                        }
                    })
                    
                } else {
                    if !UIApplication.shared.openURL(googleUrl as URL){
                        if let url = NSURL(string: "message:"){
                            UIApplication.shared.openURL(url as URL)
                        }
                    }
                }
            }
        }    
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
        }
        
        ok.setTitleColor(Color.Cyan.instance(), for: .normal)

        // Add buttons to dialog
        popup.addButtons([ok])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension ForgotPasswordVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let finalString = txt.replacingCharacters(in: newRange, with: string)
            
            if finalString.characters.count > 0 {
                pushDownFloatingLabel(textField)
                viewModel.email = finalString // update Email to ViewModel

            }else{
                
                pushUpFloatingLabel(textField)
                
                // clear error message if text is empty
                (textField as! SkyFloatingLabelTextField).errorMessage = ""
                
            }
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(txtEmail == textField){
            textField.resignFirstResponder() // show keyboard
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEmail {
            viewModel.email = textField.text // update Email to ViewModel
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
