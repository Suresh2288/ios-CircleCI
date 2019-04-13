//
//  UserTermsVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PopupDialog
import PKHUD
import SwiftyUserDefaults

class UserTermsVC: _BaseViewController {
    
    @IBOutlet weak var pdpaTextView: UITextView!
    
    var isPresented : Bool = false
    var isPrivacyPolicy:Bool = false
    var viewModel = PolicyViewModel()
    var policyData : Policies!
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPrivacyPolicy {
            title = "Privacy Policy".localized()
        }else{
            title = "Personal data protection act".localized()
        }
        ViewModelCallBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let navigationTitleFont = FontBook.Bold.of(size: 16)
        let whiteColor = UIColor.white

        if let nav = navigationController {
            nav.navigationBar.barTintColor = Color.Cyan.instance()
            nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: navigationTitleFont, NSAttributedString.Key.foregroundColor.rawValue: whiteColor])
        }
        self.pdpaRequest()
    }
    func ViewModelCallBack(){
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
    }
    
    func pdpaRequest(){
        
        viewModel.getPolicy(success: { 
            
            self.policyData = Policies.getPolicies()
            
            if self.isPrivacyPolicy {
                self.pdpaTextView.text = self.policyData.privacypolicy
            }else{
                self.pdpaTextView.text = self.policyData.pdpa
            }
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
        isPresented = true
    }
    @IBAction func btnAgreeClicked(_ sender: Any) {
        dismiss(animated: true) {
            if let parent = self.parentVC as? CreateProfileVC {
                parent.perform(#selector(parent.registerShow))
            }
        }
    }
    
    @IBAction func btnDisagreeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    
    }

    /*!
     Displays the standard dialog without image, just as the system dialog
     */
    func showStandardDialog(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Rate our app".localized()
        let message = "Is our app helping to manage your child's use of smart devices?\nPlease take a moment to rate us or send us a feedback.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
            print("Completed")
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "LATER".localized()) {
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "FEEDBACK".localized()) {
        }
        
        
        let buttonThree = DefaultButton(title: "RATE APP".localized()) {
        }
        

        if popup.viewController is PopupDialogDefaultViewController {
            let vc = popup.viewController as? PopupDialogDefaultViewController
            vc?.titleFont = FontBook.Bold.of(size: 16)
            vc?.messageFont = FontBook.Regular.of(size: 16)
        }
        
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)

        // Add buttons to dialog
        popup.addButtons([buttonTwo, buttonThree, buttonOne])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    func showCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        let ratingVC = self.storyboard!.instantiateViewController(withIdentifier: AlertResetPassword.className)
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC, buttonAlignment: .horizontal, transitionStyle: .bounceUp, tapGestureDismissal: true)
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL".localized(), height: 60) {
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "RATE".localized(), height: 60) {
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
