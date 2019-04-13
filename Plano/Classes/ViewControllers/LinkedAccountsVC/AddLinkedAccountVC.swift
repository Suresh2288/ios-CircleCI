//
//  AddLinkedAccountVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PKHUD
import PopupDialog

class AddLinkedAccountVC : _BaseViewController {
    
    @IBOutlet weak var txtEmailAddress: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmailAddressTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgCorrect : UIImageView!
    
    @IBOutlet weak var btnSendRequest: UIButton!
    
    var willClearPasswordField = false
    
    var viewModel = LinkedAccountsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configFloatingLabel(txtEmailAddress)
        txtEmailAddress.delegate = self
        pushUpFloatingLabel(txtEmailAddress)
        btnSendRequest.isEnabled = false
        imgCorrect.isHidden = true
        viewModelCallBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewModelCallBack() {
        
        viewModel.isEmailValidCallback = { [weak self] (_ validationObj: ValidationObj) in
            if let me = self {
                me.txtEmailAddress.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.txtEmailAddress)
                }
                me.btnSendRequest.isEnabled = validationObj.isValid
                me.imgCorrect.isHidden = !(validationObj.isValid)
                
                if validationObj.isValid{
                    self?.btnSendRequest.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
                }else{
                    self?.btnSendRequest.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
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
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 50
        if(textField == txtEmailAddress){
            txtEmailAddressTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 38
        if(textField == txtEmailAddress){
            txtEmailAddressTopConstraint.constant = constant
        }
        textField.layoutIfNeeded()
    }
    
    @IBAction func btnSendRequestClicked(_ sender: UIButton) {
        sender.isEnabled = false
        
        // update `password` value to ViewModel
        viewModel.addedEmail = txtEmailAddress.text
        
        viewModel.createLinkAccount(success: { (validationObj:ValidationObj) in
            
            sender.isEnabled = true
            // hide keyboard
            self.view.endEditing(true)
            
            self.showSuccessfullyRequested()
            // dismiss self and ask ChildDashboard to switch to ParentDashboard
            
            
        }) { (validationObj:ValidationObj) in
            
            if let msg = validationObj.message() {
                self.txtEmailAddress.errorMessage = msg
            }
        }
    }
    
    func showSuccessfullyRequested(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Request sent".localized()
        let message = "You will get notified once the request has been accepted".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.dismiss(animated: true, completion: {
                
            })
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
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddLinkedAccountVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let finalString = txt.replacingCharacters(in: newRange, with: string)
            
            if finalString.characters.count > 0 {
                pushDownFloatingLabel(textField)
                viewModel.addedEmail = finalString // update Email to ViewModel
                
            }else{
                
                pushUpFloatingLabel(textField)
                
                // clear error message if text is empty
                (textField as! SkyFloatingLabelTextField).errorMessage = ""
                
            }
            
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(txtEmailAddress == textField){
            textField.resignFirstResponder() // show keyboard
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEmailAddress {
            viewModel.addedEmail = textField.text // update Email to ViewModel
        }
    }
    
}
