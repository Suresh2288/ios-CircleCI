//
//  SignInVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PKHUD
import SwiftyUserDefaults

class SignInVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "signin"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "signin"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    var signInViewModel = SignInViewModel()
    
    var willClearPasswordField = false
    var iconClick = true
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    
    @IBOutlet weak var txtEmailTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtEmailBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtPasswordTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblLoginFail: UILabel!
    
    @IBOutlet weak var btnPwShowHide: UIButton!
    @IBOutlet weak var btnRegisterNow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBarWithAttributes(navtitle: "", setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16))
        
        initTextFields()
        initFloatingLabels()
        viewModelCallBack()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .color("Don't have an account?".localized(), Color.DarkGrey.rawValue, btnRegisterNow.titleLabel!.getLabelFontSize(),false)
            .color(" Register now".localized(), Color.Cyan.rawValue, btnRegisterNow.titleLabel!.getLabelFontSize(),true)
        btnRegisterNow.setAttributedTitle(formattedString, for: .normal)
    }
    
    func viewModelCallBack() {
        
        signInViewModel.isEmailValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtEmail.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtEmail)
                }else{
                    self?.lblLoginFail.isHidden = validationObj.isValid
                }
            }
        }
        
        signInViewModel.isPasswordValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtPassword.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtPassword)
                }else{
                    self?.lblLoginFail.isHidden = validationObj.isValid
                }
            }
        }
        
        signInViewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        signInViewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
    
    func gotoNextScreen() {
        self.callLogin()
    }
    
    func callLogin(){
        let errormsg = "You've entered the wrong email/password details. \n Please try again.".localized()
        
        if signInViewModel.isValid == false{
            self.lblLoginFail.isHidden = false
            self.lblLoginFail.text = errormsg
            return
        }
        
        signInViewModel.login(success: {[weak self] (validationObj) in
            
            self?.showParentChildLandingScreen()
            
            self?.getMasterDataInBackground()
            
        }) {[weak self] (validationObj) in
            
            self?.lblLoginFail.isHidden = validationObj.isValid
            
            if let msg = validationObj.message() {
                if msg.isEmpty {
                    self?.lblLoginFail.text = errormsg
                }else{
                    self?.lblLoginFail.text = msg
                }
            }
        }
        
        // we clear this 2 values here:
        // because there will be a case where user come back by himself and login after Email is verified.
        // if so, every login, we should clear followings to better sanitation
        Defaults[.tempEmailOfNewUser] = nil
        Defaults[.tempPWOfNewUser] = nil
    }
    
    // Mark: -- TextFields
    
    func initTextFields() {
        txtEmail.returnKeyType = .next
        txtPassword.returnKeyType = .done
        lblLoginFail.isHidden = true
        
        txtEmail.setNeedsLayout()
        txtEmail.layoutIfNeeded()
        
        txtEmail.placeholder = "Email".localized()
        txtPassword.placeholder = "Password".localized()
    }
    
    func initFloatingLabels() {
        
        // config Fonts, Format, etc
        configFloatingLabel(txtEmail)
        configFloatingLabel(txtPassword)
        txtEmail.delegate = self
        txtPassword.delegate = self
        
        txtEmail.keyboardType = .emailAddress
        
        // move up the floatingLabel for initial load
        pushUpFloatingLabel(txtEmail)
        pushUpFloatingLabel(txtPassword)
        
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 8
        if(textField == txtEmail){
            txtEmailTopConstraint.constant = constant
        }else if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = -5
        if(textField == txtEmail){
            txtEmailTopConstraint.constant = constant
        }else if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    @IBAction func btnSignInClicked(_ sender: Any) {
        
        var found = false
        if let nv = navigationController {
            for vc in nv.viewControllers {
                if vc.isKind(of: SignUpVC.self) {
                    nv.popToViewController(vc, animated: true)
                    found = true
                }
            }
            
            if !found {
                let vc = UIStoryboard.SignUp()
                nv.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @IBAction func btnPwShowClicked(_ sender: Any) {
        if(iconClick == true) {
            txtPassword.isSecureTextEntry = false
            self.btnPwShowHide.setImage(#imageLiteral(resourceName: "iconPwEye"),for:.normal)
            
            iconClick = false
        } else {
            txtPassword.isSecureTextEntry = true
            self.btnPwShowHide.setImage(#imageLiteral(resourceName: "iconPwOpenEye"),for:.normal)
            iconClick = true
        }
    }
    
    
    
    // MARK: - Login via `plano://` after verification is success
    
    func handleAutoLoginAfterSuccessfulVerification(){
        if let email = Defaults[.tempEmailOfNewUser], let pw = Defaults[.tempPWOfNewUser] {
            signInViewModel.email = email
            signInViewModel.password = pw
            self.txtEmail.text = email
            self.txtPassword.text = pw
            pushDownFloatingLabel(self.txtEmail)
            pushDownFloatingLabel(self.txtPassword)
            self.gotoNextScreen()
        }
    }
    
}

extension SignInVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let finalString = txt.replacingCharacters(in: newRange, with: string)
            let isBackSpace = string == ""
            
            if finalString.characters.count > 0 {
                pushDownFloatingLabel(textField)
                
                // check from "" -> "a"
                let isNewlyType = finalString.characters.count > txt.characters.count
                if isNewlyType && textField == txtPassword {
                    willClearPasswordField = false // this happen when we start typing again in PW field
                }
                
            }else{
                
                pushUpFloatingLabel(textField)
                
                // clear error message if text is empty
                (textField as! SkyFloatingLabelTextField).errorMessage = ""
                
            }
            
            // Reason: to handle special case when password field is just focused and tapped "backspace" to clear the password
            //          As default feature, UITextfield clear whole password field when it's newly focused
            // Action: To move up the password field when all text are gone
            if(txtPassword == textField && isBackSpace){
                if willClearPasswordField {
                    pushUpFloatingLabel(textField)
                    log.debug("pushUpFloatingLabel")
                    willClearPasswordField = false
                }
            }
            
            if(txtEmail == textField){
                txtEmail.errorMessage = "" // clear the error message as long as the user typing
            }else if(txtPassword == textField){
                signInViewModel.password = finalString // check real-time password error
            }
            
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        willClearPasswordField = textField == txtPassword // We know that PW Wipe out will hapen when we start typing in PW field again
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(txtEmail == textField){
            txtPassword.becomeFirstResponder() // show keyboard
        }else if(txtPassword == textField){
            txtPassword.resignFirstResponder() // hide keyboard
            gotoNextScreen()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEmail {
            signInViewModel.email = textField.text // update Email to ViewModel
        }else if textField == txtPassword {
            signInViewModel.password = textField.text // update Password to ViewModel
        }
    }
}

