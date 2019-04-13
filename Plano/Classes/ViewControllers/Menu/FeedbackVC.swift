//
//  FeedbackVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PKHUD
import PopupDialog
import TPKeyboardAvoiding
import SwiftyUserDefaults

class FeedbackVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "feedback"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "feedback"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var lblFeedbackInfo : UILabel!
    @IBOutlet weak var btnCategory : UIButton!
    @IBOutlet weak var imgArrow : UIImageView!
    @IBOutlet weak var txtFeedback : UITextView!
    
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var btnSubmit : UIButton!
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    var feedbackCategory = ["Bug report","Connectivity","Design and layout","Efficiency/workflow","Functions and features","Improvement request"]
    
    var fromMenu = true
    var feedbackText = ""
    var category = ""
    var viewModel = FeedbackViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        WoopraTrackingPage().trackEvent(mainMode:"Parent Feedback Page",pageName:"Feedback Page",actionTitle:"Entered in Feedback page")

        if fromMenu {
            setupMenuNavBarWithAttributes(navtitle: "Feedback".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        }else{
            setUpNavBarWithAttributes(navtitle: "Feedback".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        }
        
        initFloatingLabels()
        initView()
    }
    
    func initView(){
        
        lblFeedbackInfo.text = "To achieve optimal product quality, we would appreciate any feedback you may have. If you have any comments, good or bad, we’re all ears (and eyes)".localized()
        
        txtFeedback.delegate = self
        txtFeedback.text = "Type your feedback here".localized()
        txtFeedback.textColor = .lightGray
        
        feedbackText = ""
        
        if feedbackText == ""{
            btnSubmit.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
            btnSubmit.isEnabled = false
        }
        
        if let profile = ProfileData.getProfileObj() {
            txtName.text = profile.firstName + " " + profile.lastName
            txtEmail.text = profile.email
            
            txtName.isUserInteractionEnabled = false
            txtEmail.isUserInteractionEnabled = false
            
            btnCategory.setTitle(feedbackCategory[0], for: .normal)
            category = feedbackCategory[0]
        }
    }
    
    // MARK: - Initialization
    func initFloatingLabels() {
        
        configFloatingLabel(txtEmail)
        configFloatingLabel(txtName)
        
        txtEmail.delegate = self
        txtName.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCategoryTapped(_ sender : UIButton){
        self.view.endEditing(true)
        setUpCategoryPicker()
    }
    
    func setUpCategoryPicker(){
        
        let categoryAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<feedbackCategory.count{
            let categoryAction = UIAlertAction(title: feedbackCategory[i], style: .default, handler: { action in
                self.btnCategory.setTitle(self.feedbackCategory[i].localized(), for: .normal)
                self.category = self.feedbackCategory[i].localized()
            })
            categoryAlert.addAction(categoryAction)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
        })

        categoryAlert.addAction(cancelAction)
        
        if let popOver = categoryAlert.popoverPresentationController {
            let anchorRect = CGRect(x: 0, y: 0, width: btnCategory.frame.size.width, height: btnCategory.frame.size.height)
            popOver.sourceRect = anchorRect
            popOver.sourceView = btnCategory // works for both iPhone & iPad
        }

        self.present(categoryAlert, animated: true, completion: nil)
    }
    
    @IBAction func btnSubmitTapped(_ sender : UIButton){
        self.view.endEditing(true)
        
        viewModel.categoryName = category
        viewModel.descriptionText = feedbackText
        
        viewModel.updateFeedback(success: { 
            
            self.showSuccess()
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
        
    }
    
    func showSuccess(){
        
        let title = "Successful".localized()

        let message = "Thank you for your feedback. We will get in touch shortly.".localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.initView()
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
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
        
    }
    
    func viewModelCallBack(){
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }

}

// MARK: - UITextFieldDelegate
extension FeedbackVC: UITextFieldDelegate,UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == ""{
            btnSubmit.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
            btnSubmit.isEnabled = false
        }else{
            btnSubmit.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
            btnSubmit.isEnabled = true
            feedbackText = textView.text
        }
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView){
        if (textView.text == "Type your feedback here".localized()) {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView){
        if (textView.text == "") {
            textView.text = "Type your feedback here".localized()
            textView.textColor = .lightGray
            btnSubmit.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
            btnSubmit.isEnabled = false
        }else{
            btnSubmit.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
            btnSubmit.isEnabled = true
            feedbackText = textView.text
        }
        textView.resignFirstResponder()
    }
}
