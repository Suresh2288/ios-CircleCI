//
//  AboutPlanoVC.swift
//  Plano
//
//  Created by Thiha Aung on 9/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyUserDefaults

class AboutPlanoVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "about"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "about"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var policyView : UIView!
    @IBOutlet weak var btnPolicyType : UIButton!
    @IBOutlet weak var imgPolicyType : UIImageView!
    
    @IBOutlet weak var lblAboutTitle : UILabel!
    @IBOutlet weak var lblAboutDescription : UITextView!
    
    @IBOutlet weak var aboutScrollView : UIScrollView!
    @IBOutlet weak var snecView : UIView!
    
    @IBOutlet weak var aboutPlanoImageHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var snecViewHeightConstriant : NSLayoutConstraint!
    
    var isPresented : Bool = false
    var viewModel = PolicyViewModel()
    var policyData : Policies!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent About plano Page",pageName:"About plano Page",actionTitle:"Entered in About plano page")

        setupMenuNavBarWithAttributes(navtitle: "About plano".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        
        initAboutPlanoView()
        viewModelCallBack()
    }
    
    func initAboutPlanoView(){
        self.policyView.isHidden = true
        self.aboutScrollView.isHidden = true
        self.snecView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isPresented{
            
            viewModel.getPolicy(success: { 
                
                self.policyData = Policies.getPolicies()
                
                UIView.transition(with: self.policyView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.policyView.isHidden = false
                })
                
                self.imgPolicyType.image = UIImage(named: "iconAboutAvator")
                self.btnPolicyType.setTitle("The plano application".localized(), for: .normal)
                
                self.lblAboutTitle.text = "Who is plano?".localized()
                self.lblAboutDescription.text = self.policyData.aboutPlano
                
                UIView.transition(with: self.snecView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.aboutPlanoImageHeightConstraint.constant = 200
                    self.snecView.isHidden = false
                    
                })
                
                self.aboutScrollView.isHidden = false
                self.aboutScrollView.layoutIfNeeded()
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
            }
            isPresented = true
            
        }
    }
    
    func viewModelCallBack(){
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
    
    @IBAction func btnPolicyTapped(_ sender : UIButton){
        setUpPolicyPicker()
    }
    
    @IBAction func btnTakeATrouTapped(_ sender: Any) {
        let vc = UIStoryboard.TakeATour()
        present(vc, animated: true, completion: nil)
    }
    
    func setUpPolicyPicker(){
        
        let policyAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // The Plano Application
        let planoApplicationAction = UIAlertAction(title: "The plano application", style: .default, handler: { action in
            
            AnalyticsHelper().analyticLogScreen(screen: "about")
            
            AppFlyerHelper().trackScreen(screenName: "about")
            
            self.imgPolicyType.image = UIImage(named: "iconAboutAvator")
            self.btnPolicyType.setTitle("The plano application", for: .normal)
            
            self.lblAboutTitle.text = "Who is plano?".localized()
            self.lblAboutDescription.text = self.policyData.aboutPlano
            self.lblAboutDescription.alpha = 0
            
            UIView.transition(with: self.aboutScrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                
                self.aboutPlanoImageHeightConstraint.constant = 200
                self.lblAboutDescription.alpha = 1
                self.snecViewHeightConstriant.constant = 50
                self.snecView.isHidden = false
                self.aboutScrollView.layoutIfNeeded()
            })
            
        })
        policyAlert.addAction(planoApplicationAction)
        
        // Terms And Condition
        let termsAndConditionAction = UIAlertAction(title: "Terms & Conditions".localized(), style: .default, handler: { action in
            
            AnalyticsHelper().analyticLogScreen(screen: "terms")
            
            AppFlyerHelper().trackScreen(screenName: "terms")
            
            self.imgPolicyType.image = UIImage(named: "iconTC")
            self.btnPolicyType.setTitle("Terms & Conditions".localized(), for: .normal)
            
            self.lblAboutTitle.text = "Terms & Conditions".localized()
            self.lblAboutDescription.text = self.policyData.termsAndCondition
            self.lblAboutDescription.alpha = 0
            
            UIView.transition(with: self.aboutScrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in

                self.aboutPlanoImageHeightConstraint.constant = 0
                self.lblAboutDescription.alpha = 1
                self.snecViewHeightConstriant.constant = 0
                self.snecView.isHidden = true
                self.aboutScrollView.layoutIfNeeded()
                
            })
            
        })
        policyAlert.addAction(termsAndConditionAction)
        
        // Privacy Policy
        let privacyPolicyAction = UIAlertAction(title: "Privacy Policy".localized(), style: .default, handler: { action in
            
            AnalyticsHelper().analyticLogScreen(screen: "privacy")
            
            AppFlyerHelper().trackScreen(screenName: "privacy")
            
            self.imgPolicyType.image = UIImage(named: "iconPP")
            self.btnPolicyType.setTitle("Privacy Policy".localized(), for: .normal)
            
            self.lblAboutTitle.text = "Privacy Policy".localized()
            self.lblAboutDescription.text = self.policyData.privacypolicy
            self.lblAboutDescription.alpha = 0
            
            UIView.transition(with: self.aboutScrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                
                self.aboutPlanoImageHeightConstraint.constant = 0
                self.lblAboutDescription.alpha = 1
                self.snecViewHeightConstriant.constant = 0
                self.snecView.isHidden = true
                self.aboutScrollView.layoutIfNeeded()
            })
            
        })
        policyAlert.addAction(privacyPolicyAction)
        
        // Personal Data Protection Act
        let pdpaAction = UIAlertAction(title: "Personal Data Protection Act".localized(), style: .default, handler: { action in
            
            AnalyticsHelper().analyticLogScreen(screen: "pdpa")
            
            AppFlyerHelper().trackScreen(screenName: "pdpa")
            
            self.imgPolicyType.image = UIImage(named: "iconPDPA")
            self.btnPolicyType.setTitle("Personal Data Protection Act".localized(), for: .normal)
            
            self.lblAboutTitle.text = "Personal Data Protection Act".localized()
            self.lblAboutDescription.text = self.policyData.pdpa
            self.lblAboutDescription.alpha = 0
            
            UIView.transition(with: self.aboutScrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                
                self.aboutPlanoImageHeightConstraint.constant = 0
                self.lblAboutDescription.alpha = 1
                self.snecViewHeightConstriant.constant = 0
                self.snecView.isHidden = true
                self.aboutScrollView.layoutIfNeeded()
            })
            
        })
        policyAlert.addAction(pdpaAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
        })
        
        policyAlert.addAction(cancelAction)
        
        if let popOver = policyAlert.popoverPresentationController {
            let anchorRect = CGRect(x: 0, y: 0, width: btnPolicyType.frame.size.width, height: btnPolicyType.frame.size.height)
            popOver.sourceRect = anchorRect
            popOver.sourceView = btnPolicyType // works for both iPhone & iPad
        }
        
        self.present(policyAlert, animated: true, completion: nil)
    }
        
}
