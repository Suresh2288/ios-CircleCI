//
//  ParentRewardsVC.swift
//  Plano
//
//  Created by John Raja on 21/02/19.
//  Copyright © 2019 Codigo. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField
import ObjectMapper
import PopupDialog
import Device

class ParentRewardsVC: _BaseViewController{

    @IBOutlet weak var txtNRIC: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEnterNRIC: SkyFloatingLabelTextField!
    @IBOutlet weak var lblNRICFormat: UILabel!
    @IBOutlet weak var lblNRICNotMatch: UILabel!
    @IBOutlet weak var lblDownloadApp: UILabel!
    @IBOutlet weak var btnRedeem: UIButton!
    @IBOutlet weak var lblComplimentary: UILabel!
    @IBOutlet weak var lblJustForYou: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var AvailablePoints : String = ""
    var NtucPlusUrl : String = ""
    
    @IBOutlet weak var InfoLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var NRICViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var RedeemBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var TxtNRICTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var DownloadLblWidthConstraint: NSLayoutConstraint!
    //@IBOutlet weak var BgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgBgView: UIImageView!
    @IBOutlet weak var LinkLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ImgBgTopSpaceConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "RewardsViewBg-iphone")!)
        
//        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
//        backgroundImage.image = UIImage(named: "RewardsViewBg-iphone")
//        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
//        self.view.insertSubview(backgroundImage, at: 0)
        
        if Device.size() >= .screen7_9Inch {
            InfoLblWidthConstraint.constant = 450
            DownloadLblWidthConstraint.constant = 450
            RedeemBtnBottomConstraint.constant = 50
            TxtNRICTopConstraint.constant = 50
            //BgViewTopConstraint.constant = -80
            LinkLogoTopConstraint.constant = 50
            imgBgView.image = UIImage(named: "RewardsViewBg-ipad")
            scrollView.isScrollEnabled = false
        } else if Device.size() < .screen5_8Inch {
            ImgBgTopSpaceConstraint.constant = 25
        }
        
        setUpNavBarWithAttributes(navtitle: "Rewards".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        
        //self.scrollView.layoutIfNeeded()
        
        
        txtNRIC.delegate = self
        txtEnterNRIC.delegate = self
        
//        let wholeStr = "Not a Plus! member yet? Click here to download the app and sign up."
//        let rangeToUnderLine = (wholeStr as NSString).range(of: "here")
//        //let rangeToUnderLine = NSRange(location: 0, length: 10))
//        let underLineTxt = NSMutableAttributedString(string: wholeStr, attributes: [NSFontAttributeName.font:UIFont.systemFont(ofSize: 18),NSFontAttributeName.foregroundColor: UIColor.white.withAlphaComponent(0.8)])
//
//        underLineTxt.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: rangeToUnderLine)
//        lblDownloadApp.attributedText = underLineTxt
        
        
        let wholeStr = "Not a Plus! member yet? Click here to download the app and sign up."
        let rangeToUnderLine = (wholeStr as NSString).range(of: "here")
        //let rangeToUnderLine = NSRange(location: 0, length: 10)
        let underLineTxt = NSMutableAttributedString(string: wholeStr, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font):UIFont(name: "Raleway-SemiBold", size: 18) as Any,convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white]))
        underLineTxt.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeToUnderLine)
        lblDownloadApp.attributedText = underLineTxt
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.tapLink(sender:)))
        lblDownloadApp.isUserInteractionEnabled = true
        lblDownloadApp.addGestureRecognizer(tap1)
        
    }
    
    @objc func tapLink(sender:UITapGestureRecognizer) {
        
        guard let url = URL(string: NtucPlusUrl) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+200)
    }
    
    @IBAction func RedeemButtonClicked() {
        self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.origin.x, y: 0), animated: true)
        
        if isValidNRIC(testStr: txtNRIC.text!) {
            if (txtNRIC.text == txtEnterNRIC.text) {
                
                if let parentProfile = ProfileData.getProfileObj() {
                    let request = InsertNtucUserNricRequest(email: parentProfile.email, nric: txtNRIC.text!, accessToken: parentProfile.accessToken)
                    
                    if ReachabilityUtil.shareInstance.isOnline(){
                        
                        ParentApiManager.sharedInstance.InsertNtucUserNric(request, completed: { (apiResponseHandler, error) in
                            
                            if apiResponseHandler.isSuccess() {
                                self.RedeemUpdatedSuccessfully()
                            } else {
                                self.showAlert(apiResponseHandler.errorMessage())
                            }
                        })
                    }
                }
            } else {
                print("NRIC format doesn't match")
                self.txtEnterNRIC.errorMessage = "NRIC format doesn't match"
            }
        } else {
            print("NRIC format is wrong")
            self.txtNRIC.errorMessage = "NRIC format is wrong"
        }
    }
    
    func isValidNRIC(testStr:String) -> Bool {
        let NRICRegEx = "^[stfgSTFG]\\d{7}[a-zA-Z]$"
        
        let NRICTest = NSPredicate(format:"SELF MATCHES %@", NRICRegEx)
        return NRICTest.evaluate(with: testStr)
    }
    
    func RedeemUpdatedSuccessfully(animated: Bool = true) {
        
        // Prepare the popup
        let title = ""
        let message = "Successful".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonThree = CancelButton(title: "OK".localized()) {
            self.GotoNextScreen()
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonThree])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    func GotoNextScreen() {
        if let parentProfile = ProfileData.getProfileObj() {
            let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ParentApiManager.sharedInstance.CheckNtucUserNric(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<CheckNtucUserNricResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if (Int(response.IsNtucUserNricExist) == 1) {
                                if let vc = UIStoryboard.RewardsView() as? RewardsViewVC {
                                    vc.parentVC = self
                                    vc.isFromMainView = false
                                    vc.AvailablePoints = String(response.NtucLinkpointsCredit)
                                    vc.NtucPlusUrl = response.NtucPlusUrl
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    } else {
                        self.showAlert(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
}

extension ParentRewardsVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        self.txtEnterNRIC.errorMessage = ""
        self.txtNRIC.errorMessage = ""
        
        if Device.size() < .screen7_9Inch {
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.origin.x, y: 85), animated: true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(txtNRIC == textField){
            txtEnterNRIC.becomeFirstResponder() // show keyboard
            return false
        } else {
            textField.resignFirstResponder() // hide keyboard
        }
        
        if Device.size() < .screen7_9Inch {
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.origin.x, y: 0), animated: true)
        }
        
        return true
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
