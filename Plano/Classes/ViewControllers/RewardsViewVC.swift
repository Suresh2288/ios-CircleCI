//
//  RewardsViewVC.swift
//  Plano
//
//  Created by John Raja on 21/02/19.
//  Copyright © 2019 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import PopupDialog
import Device

class RewardsViewVC: _BaseViewController{
    
    @IBOutlet weak var lblInfoYouHave: UILabel!
    @IBOutlet weak var lblPlanoPoints: UILabel!
    @IBOutlet weak var lblDownloadApp: UILabel!
    @IBOutlet weak var btnRedeem: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imgBgView: UIImageView!
    var AvailablePoints : String = ""
    var NtucPlusUrl : String = ""
    var isFromMainView : Bool = false
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Rewards View Did Load")
        
        setUpNavBarWithAttributes(navtitle: "Rewards".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        lblPlanoPoints.text = AvailablePoints + " plano points"
        
        if Device.size() >= .screen7_9Inch {
            imgBgView.image = UIImage(named: "RewardsViewBg-ipad")
            scrollView.isScrollEnabled = false
        }
        
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
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+200)
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
    
    @IBAction func RedeemButtonClicked() {
        
        if let parentProfile = ProfileData.getProfileObj() {
            let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                ParentApiManager.sharedInstance.UpdateNtucLinkPointsTransaction(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        self.RedeemUpdatedSuccessfully()
                    } else {
                        self.showAlert(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
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
            self.navigationController?.popToRootViewController(animated: true)
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
