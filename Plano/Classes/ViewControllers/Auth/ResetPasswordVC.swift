//
//  ResetPasswordVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PKHUD
import PopupDialog
import MessageUI

class ResetPasswordVC: _BaseScrollViewController {
    var iconConfirmClick:Bool = true
    var iconCreateClick: Bool = true
    var iconCurrentClick: Bool = true
    
    @IBOutlet weak var lblPassword: UILabel!

    @IBOutlet weak var txtCurrentPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtCurrentPasswordConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPasswordTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var txtConfirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtConfirmPasswordTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var PWStrengthView: PasswordStrengthView!

    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var btnCurrentpw: UIButton!
    @IBOutlet weak var btnNewShowpw: UIButton!
    @IBOutlet weak var btnComfirmpw: UIButton!
    
    var viewModel = PasswordViewModel()

    var parentLockPassword:Bool = false
    var willClearPasswordField = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let nav = navigationController {
//            nav.setNavigationBarHidden(false, animated: false)
//        }
        setUpNavBarWithAttributes(navtitle: "", setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16))
        UIApplication.shared.isStatusBarHidden = false
 
        configFloatingLabel(txtCurrentPassword)
        configFloatingLabel(txtPassword)
        configFloatingLabel(txtConfirmPassword)
        
        txtCurrentPassword.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        
        txtCurrentPassword.returnKeyType = .next
        txtPassword.returnKeyType = .next
        txtConfirmPassword.returnKeyType = .done
        
        PWStrengthView.strength = .weak // to reset PW Strength
        
        pushUpFloatingLabel(txtCurrentPassword)
        pushUpFloatingLabel(txtPassword)
        pushUpFloatingLabel(txtConfirmPassword)

        if parentLockPassword {
            lblPassword.text = "Set a parent lock password".localized()
            
            txtPassword.placeholder = "Create password".localized()
            txtConfirmPassword.placeholder = "Confirm password".localized()
            btnSubmit.setTitle("Save".localized(), for: .normal)
            viewModel.submitFormCallback = {[weak self](_ model:RegisterData) in
                self?.gotoNextScreen(model)
            }
            
            btnSubmit.isHidden = true
        }

        
        viewModelCallBack()
        
        // hide Password Strength View per Client's request on Feb 2018
        PWStrengthView.isHidden = true
    }
    
    func viewModelCallBack() {
        
        viewModel.passwordStrengthCallback = {[weak self] (_ strength:PWStrength) in
            self?.PWStrengthView.strength = strength
        }
        
        viewModel.isCurrentPasswordValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtCurrentPassword.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtCurrentPassword)
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
        
        viewModel.resetFormCallback = {[weak self] (_ validationObj: ValidationObj) in
            if validationObj.isValid {
                HUD.show(.success)
                HUD.hide(afterDelay: 1)
                self?.navigationController?.popViewController(animated: true)
            }else{
                if let msg = validationObj.message() {
                    self?.showAlert(msg)
                    
                }
            }
        }
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }

    }
    
    func userCreatedSuccessfully(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Forgot Password".localized()
        let message = "Please check the email you entered to create a new password".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OPEN EMAIL".localized()) {
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
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)

        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Reset Password Page",pageName:"Reset Password Page",actionTitle:"Entered in Reset Password Page")

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 8
        
        if(textField == txtCurrentPassword){
            txtCurrentPasswordConstraint.constant = constant
        }else if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }else if(textField == txtConfirmPassword){
            txtConfirmPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = -5
        if(textField == txtCurrentPassword){
            txtCurrentPasswordConstraint.constant = constant
        }else if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }else if(textField == txtConfirmPassword){
            txtConfirmPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func gotoNextScreen(_ data:RegisterData){
        let vc = UIStoryboard.CreateProfile() as! CreateProfileVC
        vc.assignRegisterDataModel(data)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        viewModel.submitResetPasswordForm()
    }
    
    @IBAction func btnCurrentPwShow(_ sender: Any) {
        if(iconCurrentClick == true) {
            txtCurrentPassword.isSecureTextEntry = false
            self.btnCurrentpw.setImage(#imageLiteral(resourceName: "iconPwEye"),for:.normal)
            
            iconCurrentClick = false
        } else {
            txtCurrentPassword.isSecureTextEntry = true
            self.btnCurrentpw.setImage(#imageLiteral(resourceName: "iconPwOpenEye"),for:.normal)
            iconCurrentClick = true
        }
    }
    @IBAction func btnCreatedPwShowClicked(_ sender: Any) {
        if(iconCreateClick == true) {
            txtPassword.isSecureTextEntry = false
            self.btnNewShowpw.setImage(#imageLiteral(resourceName: "iconPwEye"),for:.normal)
            
            iconCreateClick = false
        } else {
            txtPassword.isSecureTextEntry = true
            self.btnNewShowpw.setImage(#imageLiteral(resourceName: "iconPwOpenEye"),for:.normal)
            iconCreateClick = true
        }
    }
    @IBAction func btnConfirmPwshow(_ sender: Any) {
        if(iconConfirmClick == true) {
            txtConfirmPassword.isSecureTextEntry = false
            self.btnComfirmpw.setImage(#imageLiteral(resourceName: "iconPwEye"),for:.normal)
            
            iconConfirmClick = false
        } else {
            txtConfirmPassword.isSecureTextEntry = true
            self.btnComfirmpw.setImage(#imageLiteral(resourceName: "iconPwOpenEye"),for:.normal)
            iconConfirmClick = true
        }
    }
    
}
extension ResetPasswordVC: MFMailComposeViewControllerDelegate{

}
extension ResetPasswordVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let isSecureField = (txtPassword == textField || txtConfirmPassword == textField || txtCurrentPassword == textField)
            let isNewPasswordFields = (isSecureField && txtCurrentPassword != textField)
            
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
                
                if isNewlyType && isNewPasswordFields {
                    willClearPasswordField = false // this happen when we start typing again in PW field
                    PWStrengthView.alpha = 1
                }
                
            }else{
                
                pushUpFloatingLabel(textField)
                
                if isNewPasswordFields {
                    PWStrengthView.alpha = 0
                }
                
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
            
            if(txtCurrentPassword == textField){
                viewModel.currentPassword = finalString // check real-time password error
            }else if(txtPassword == textField){
                viewModel.password = finalString // check real-time password error
            }else if(txtConfirmPassword == textField){
                viewModel.passwordConfirm = finalString // check real-time password error
            }
            
            
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        willClearPasswordField =
            textField == txtPassword ||
            textField == txtConfirmPassword ||
            textField == txtCurrentPassword
        // We know that PW Wipe out will hapen when we start typing in PW field again
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(txtCurrentPassword == textField){
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
        if textField == txtCurrentPassword {
            viewModel.currentPassword = textField.text // update Password to ViewModel
        }else if textField == txtPassword {
            viewModel.password = textField.text // update Password to ViewModel
        }else if textField == txtConfirmPassword {
            viewModel.passwordConfirm = textField.text // update Confirm Password to ViewModel
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
