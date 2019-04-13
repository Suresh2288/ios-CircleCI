//
//  SwitchToParentVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SwitchToParentVC : _BaseViewController {
    
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPasswordTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var PopupViewHeightConstraint: NSLayoutConstraint!
    var willClearPasswordField = false
    
    var viewModel = ChildDashboardViewModel()
    
    @IBOutlet weak var btnForgotPassword: AdaptiveButton!
    var checkParentPassword = false
    var IsForgotPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if checkParentPassword {
            lblTitle.text = "Use with permission"
        }
        
        configFloatingLabel(txtPassword)
        txtPassword.delegate = self
        pushUpFloatingLabel(txtPassword)
        
        btnSubmit.isEnabled = false
        
        //TODO: DEBUG: to be disable
//        txtPassword.text = "!1Aaaaaa"
//        viewModel.password = "!1Aaaaaa"
//        btnSubmit.isEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if IsForgotPassword {
            btnForgotPassword.isHidden = false
            PopupViewHeightConstraint.constant = 240
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 50
        if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 38
        if(textField == txtPassword){
            txtPasswordTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func switchToParent(sender:UIButton){
        
        viewModel.updateScreenTime { (response) in
            
            if response.isSuccess(){
                _ = response.jsonObject as! NSDictionary
            }
            
            sender.isEnabled = false
            
            // update `password` value to ViewModel
            self.viewModel.password = self.txtPassword.text
            
            self.viewModel.switchToParentMode {[weak self] (validationObj) in
                
                sender.isEnabled = true
                if(validationObj.isValid){
                    
                    // hide keyboard
                    self?.view.endEditing(true)
                    
                    // dismiss self and ask ChildDashboard to switch to ParentDashboard
                    self?.dismiss(animated: true, completion: {
                        if let pvc = self?.parentVC as? ChildDashboardVC {
                            if pvc.canPerformAction(#selector(pvc.performSwitchToParent),
                                                    withSender: nil) {
                                pvc.perform(#selector(pvc.performSwitchToParent), with: nil)
                            }
                        }
                    })
                    
                } else {
                    self?.txtPassword.errorMessage = validationObj.message()
                }
            }
        }
        
    }
    
    func checkParentPassword(sender:UIButton){
        sender.isEnabled = false
        
        // update `password` value to ViewModel
        viewModel.password = txtPassword.text
        
        viewModel.checkParentPassword {[weak self] (validationObj) in
            
            sender.isEnabled = true
            
            if(validationObj.isValid){
                
                // hide keyboard
                self?.view.endEditing(true)
                
                // dismiss self and ask ChildDashboard to switch to ParentDashboard
                self?.dismiss(animated: true, completion: {
                    
                    if let pvc = self?.parentVC as? _BasePopupViewController {
                        pvc.perform(#selector(pvc.checkParentPasswordSuccess))
                    }
                    
                })
                
            }else{
                self?.txtPassword.errorMessage = validationObj.message()
            }
        }

    }

    @IBAction func btnSubmitClicked(_ sender: UIButton) {
        if checkParentPassword {
            checkParentPassword(sender: sender)
        }else{
            switchToParent(sender: sender)
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        if let vc = UIStoryboard.ForgotPassword() as? ForgotPasswordVC {
            vc.IsShowClosePopup = true
            present(vc, animated: true, completion: nil)
        }
    }
}

extension SwitchToParentVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
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
            

            self.btnSubmit.isEnabled = !replacedString.isEmpty
            self.txtPassword.errorMessage = ""
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
    }
    
}

