//
//  LinkWithFacebookVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LinkWithFacebookVC: _BaseScrollViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!

    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPasswordTopConstraint: NSLayoutConstraint!

    override var analyticsScreenName:String? {
        get {
            return "facebook"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "facebook"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }

    var viewModel = LinkWithFacebookViewModel()

    var willClearPasswordField = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configFloatingLabel(txtPassword)
        txtPassword.delegate = self
        txtPassword.returnKeyType = .next
        pushUpFloatingLabel(txtPassword)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 8
        if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = -5
        if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func gotoNextScreen(){
        
        self.showParentChildLandingScreen()
        
        self.getMasterDataInBackground()

    }
    
    func submitForm(){
        viewModel.submitForm {[weak self](success, errorMessage) in
            if !success, let msg = errorMessage {
                self?.showAlert(msg)
            }else{
                self?.gotoNextScreen()
            }
        }
    }
}

extension LinkWithFacebookVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let isSecureField = (txtPassword == textField)
            
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
                }
                
            }else{
                
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
            
            if(txtPassword == textField){
                viewModel.password = finalString // check real-time password error
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        willClearPasswordField = textField == txtPassword
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.submitForm()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtPassword {
            viewModel.password = textField.text // update Password to ViewModel
        }
    }
}

