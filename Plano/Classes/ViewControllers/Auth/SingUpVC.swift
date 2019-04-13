//
//  SignUpVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import SkyFloatingLabelTextField
import PKHUD
import PopupDialog
import SwiftyUserDefaults

class SignUpVC: _BaseScrollViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "register"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName: String? {
        get {
            return "register"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }

    var iconConfirmClick:Bool = true
    var iconCreateClick: Bool = true
    var viewModel = SignUpViewModel()
    var willClearPasswordField = false

    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtConfirmPassword: SkyFloatingLabelTextField!

    @IBOutlet weak var txtEmailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtPasswordTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtConfirmTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var PWStrengthView: PasswordStrengthView!

    @IBOutlet weak var btnComfirmShowPw: UIButton!
    
    @IBOutlet weak var btnCreateShowPw:UIButton!
    @IBOutlet weak var btnSignInNow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        optimizeForSmallerScreens()
        
        initTextFields()
        initFloatingLabels()
        viewModelCallBack()
        setUpNavBarWithAttributes(navtitle: "", setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16))
        
        // hide Password Strength View per Client's request on Feb 2018
        PWStrengthView.isHidden = true
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .color("Already registered?".localized(), Color.DarkGrey.rawValue, btnSignInNow.titleLabel!.getLabelFontSize(),false)
            .color(" Sign in now".localized(), Color.Purple.rawValue, btnSignInNow.titleLabel!.getLabelFontSize(),true)
        btnSignInNow.setAttributedTitle(formattedString, for: .normal)
        
        do { let ipAddress = try String(contentsOf: URL.init(string: "https://ipinfo.io/ip")!, encoding: String.Encoding.utf8)
            print("IP Address : ", ipAddress)
            Defaults[.ipAddress] = String(ipAddress.filter { !" \n\t\r".contains($0) })
            
        } catch {
            Defaults[.ipAddress] = ""
            print(error)
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    // MARK: -- Callbacks
    func viewModelCallBack() {
       viewModel.isNewEmailChecking = {[weak self] (_ validationObj: ValidationObj) in

            if let me = self {
                me.txtEmail.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    let msg = "Account was already registered".localized()
                    self?.showAlert("Sorry".localized(), msg, callBack: nil)
                    self?.txtEmail.errorMessage = msg// "email already exist".localized()
                }
            }
        }
        viewModel.isEmailValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtEmail.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtEmail)
                }
            }
        }
        
        viewModel.isPasswordValidCallback = { [weak self] (_ validationArray) in
            if let me = self {
                var errorMessages:Array<String> = []
                for ve in validationArray {
                    if !ve.isValid, let msg = ve.message() {
                        errorMessages.append(msg)
                    }
                }
                if(errorMessages.count == 1){
                    me.txtPassword.errorMessage = errorMessages.joined(separator: ", ")
                    me.pushDownFloatingLabel(me.txtPassword)
                }else if(errorMessages.count > 0){
                    me.txtPassword.errorMessage = errorMessages.joined(separator: ", ")
                    me.pushDownFloatingLabel(me.txtPassword)
                }else{
                    me.txtPassword.errorMessage = ""
                }
            }
        }
        
        viewModel.isConfirmPasswordValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtConfirmPassword.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtConfirmPassword)
                }
            }
        }
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.passwordStrengthCallback = {[weak self] (_ strength:PWStrength) in
            self?.PWStrengthView.strength = strength
        }
        
        viewModel.submitFormCallback = {[weak self](_ registerDataModel:RegisterData) in
            self?.gotoNextScreen(registerDataModel)
        }
        
    }
    
    func gotoNextScreen(_ registerDataModel:RegisterData) {
        
        let vc = UIStoryboard.CreateProfile() as! CreateProfileVC
        vc.assignRegisterDataModel(registerDataModel)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // MARK: -- TextFields
    
    func initTextFields() {
        txtEmail.returnKeyType = .next
        txtPassword.returnKeyType = .next
        txtConfirmPassword.returnKeyType = .done
    }
    
    func initFloatingLabels() {
        
        // config Fonts, Format, etc
        configFloatingLabel(txtEmail)
        configFloatingLabel(txtPassword)
        configFloatingLabel(txtConfirmPassword)
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self

        txtEmail.keyboardType = .emailAddress
        
        // move up the floatingLabel for initial load
        pushUpFloatingLabel(txtEmail)
        pushUpFloatingLabel(txtPassword)
        pushUpFloatingLabel(txtConfirmPassword)
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 8
        if(textField == txtEmail){
            txtEmailTopConstraint.constant = constant
        }else if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }else if(textField == txtConfirmPassword){
            txtConfirmTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = -5
        if(textField == txtEmail){
            txtEmailTopConstraint.constant = constant
        }else if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }else if(textField == txtConfirmPassword){
            txtConfirmTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }

    func optimizeForSmallerScreens() {
        
        var constantFromBottom:CGFloat = 0
        var screenHeight = self.view.frame.size.height
        var calculatedValue:CGFloat = 0
        
        if Device.size() == .screen3_5Inch {
            
            screenHeight = 435 // ContentHeight of 4Inch ScrollView
            constantFromBottom = 70
            calculatedValue = screenHeight + constantFromBottom
            
        }else if Device.size() == .screen4Inch {
            
            constantFromBottom = 70
            calculatedValue = screenHeight - self.scrollView.frame.origin.y + constantFromBottom
            
        }else if Device.size() <= .screen5_8Inch{
            calculatedValue = screenHeight - self.scrollView.frame.origin.y + constantFromBottom
        }
        
        scrollViewBgHeightConstraint.constant = calculatedValue
        
        scrollView.layoutIfNeeded()
    }
    @IBAction func btnCreatedPwShowClicked(_ sender: Any) {
        if(iconCreateClick == true) {
            txtPassword.isSecureTextEntry = false
            self.btnCreateShowPw.setImage(#imageLiteral(resourceName: "iconPwEye"),for:.normal)
            
            iconCreateClick = false
        } else {
            txtPassword.isSecureTextEntry = true
            self.btnCreateShowPw.setImage(#imageLiteral(resourceName: "iconPwOpenEye"),for:.normal)
            iconCreateClick = true
        }
    }
    @IBAction func btnConfirmPwshow(_ sender: Any) {
        if(iconConfirmClick == true) {
            txtConfirmPassword.isSecureTextEntry = false
            self.btnComfirmShowPw.setImage(#imageLiteral(resourceName: "iconPwEye"),for:.normal)
            
            iconConfirmClick = false
        } else {
            txtConfirmPassword.isSecureTextEntry = true
            self.btnComfirmShowPw.setImage(#imageLiteral(resourceName: "iconPwOpenEye"),for:.normal)
            iconConfirmClick = true
        }
    }
    
    @IBAction func btnSignUpClicked(_ sender: Any) {
        var found = false
        if let nv = navigationController {
            for vc in nv.viewControllers {
                if vc.isKind(of: SignInVC.self) {
                    nv.popToViewController(vc, animated: true)
                    found = true
                }
            }
            
            if !found {
                let vc = UIStoryboard.SignIn()
                nv.pushViewController(vc, animated: true)
            }
        }
        
    }

    
}


extension SignUpVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let isSecureField = (txtPassword == textField || txtConfirmPassword == textField)
            
            /*
             * Old      New     Final
             *------------------------
             * a        b       ab
             * @12      x       @12x
             */
            let replacedString = txt.replacingCharacters(in: newRange, with: string)
            
            /*
             * To determine, if the text will be replaced or appended?
             */
            let isNewlyType = replacedString.characters.count > txt.characters.count
            
            /*
             * Recently Focused PW Field will replace the previous text with new one
             *
             * Old      New     Final
             *------------------------
             * a        b       b
             * @12      x       x
             */
            let finalString = (isSecureField && willClearPasswordField) ? string : replacedString
            
            let isBackSpace = string == ""
            
            if finalString.characters.count > 0 {
                pushDownFloatingLabel(textField)
                
                // check from "" -> "a"
                
                if isNewlyType && isSecureField {
                    willClearPasswordField = false // this happen when we start typing again in PW field
                    PWStrengthView.alpha = 1
                }
                
            }else{
                PWStrengthView.alpha = 0
                pushUpFloatingLabel(textField)
                
                // clear error message if text is empty
                (textField as! SkyFloatingLabelTextField).errorMessage = ""
                
            }
            
            // Reason: to handle special case when password field is just focused and tapped "backspace" to clear the password
            //          As default feature, UITextfield clear whole password field when it's newly focused
            // Action: To move up the password field when all text are gone
            if(isSecureField && isBackSpace){
                if willClearPasswordField {
                    pushUpFloatingLabel(textField)
                    log.debug("pushUpFloatingLabel")
                    willClearPasswordField = false
                }
            }
            
            if(txtEmail == textField){
                txtEmail.errorMessage = "" // clear the error message as long as the user typing
            }else if(txtPassword == textField){
//                PWStrengthView.alpha = 1
                viewModel.password = finalString // check real-time password error
            }else if(txtConfirmPassword == textField){
                viewModel.passwordConfirm = finalString // check real-time password error
            }

            
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        willClearPasswordField = textField == txtPassword || textField == txtConfirmPassword // We know that PW Wipe out will hapen when we start typing in PW field again
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(txtEmail == textField){
            txtPassword.becomeFirstResponder() // show keyboard
        }else if(txtPassword == textField){
            txtConfirmPassword.becomeFirstResponder() // show keyboard
        }else if(txtConfirmPassword == textField){
            txtConfirmPassword.resignFirstResponder() // hide keyboard
            viewModel.submitForm()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEmail {
            viewModel.email = textField.text// update Email to ViewModel
        }else if textField == txtPassword {
            viewModel.password = textField.text // update Password to ViewModel
        }else if textField == txtConfirmPassword {
            viewModel.passwordConfirm = textField.text // update Confirm Password to ViewModel
        }
    }
}

