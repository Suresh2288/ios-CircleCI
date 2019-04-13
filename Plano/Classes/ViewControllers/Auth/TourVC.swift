//
//  TourVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SwiftHEXColors
import Device
import SwiftyUserDefaults

class TourVC: _BaseViewController {
  
    @IBOutlet weak var guideView: UIView!
    
    @IBOutlet weak var imgStep1: UIImageView!
    @IBOutlet weak var imgStep1TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgStep2: UIImageView!
    @IBOutlet weak var imgStep2TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgStep9: UIImageView!
    @IBOutlet weak var imgStep9TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewStep1: UIView!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var lblDesc1: UILabel!
    @IBOutlet weak var view1BottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var lblTitle1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDesc1TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTitle2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDesc2TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewStep2: UIView!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var lblDesc2: UILabel!
    @IBOutlet weak var view2BottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewStep9: UIView!
    @IBOutlet weak var lblTitle9: UILabel!
    @IBOutlet weak var view9BottomConstraint: NSLayoutConstraint!
    
    var isAnimating = false
    var currentIndex = 1
    
    let images = ["step1","step2","step31","step32","step33",
                  "step4","step51","step52","step53",
                  "step6","step7","step8"]
    
    let titles = ["Let’s get started".localized(),
                  "Get reminded".localized(),
                  "Complete control".localized(),
                  "Remove not child-friendly apps".localized(),
                  "Set location boundaries".localized(),
                  "Child-Friendly".localized(),
                  "plano guided".localized(),
                  "Friendly reminders".localized(),
                  "Get rewarded".localized(),
                  "Remote lock".localized(),
                  "Track progress".localized(),
                  "Give them what they like".localized()]
    
    let descs = ["Begin your plano journey by adding your child details.".localized(),
                 "Save your child’s eye health information to receive reminders for eye tests.".localized(),
                 "Customise the settings to keep your child’s device usage in check.".localized(),
                 "Select and block apps that you do not want your child to get access to via your devices.".localized(),
                 "Create safe zones to ensure your child’s safety.".localized(),
                 "Switch to child mode and share your devices with peace of mind.".localized(),
                 "Your child will be using the device as usual under the care of plano.".localized(),
                 "Your child will be gently reminded of their device usage by plano.".localized(),
                 "Your child can earn points if they stick to the guidelines.".localized(),
                 "Log in to another device to lock your child’s device remotely with ease.".localized(),
                 "Keep tabs on your child’s progress and usage at your fingertips.".localized(),
                 "Reward your child with their requested items from the plano shop.".localized()]
    
    let bgColors = ["68ced9","49bcc9","49bcc9","49bcc9","49bcc9",
                    "38a6b2","319ca7","319ca7","319ca7",
                    "298e99","38a6b2","49bcc9","68ced9"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Tour Page",pageName:"Tour Page",actionTitle:"Take a tour")

        self.title = "Tour".localized()
        
        imgStep1.isHidden = false
        imgStep2.isHidden = true
        imgStep9.isHidden = true
        
        viewStep1.isHidden = false
        viewStep2.isHidden = false
        viewStep9.isHidden = true
        
        lblTitle1.isHidden = false
        lblDesc1.isHidden = false
        lblTitle2.isHidden = false
        lblDesc2.isHidden = false
        
        lblTitle1.alpha = 1
        lblDesc1.alpha = 1
        lblTitle2.alpha = 0
        lblDesc2.alpha = 0

        viewStep1.backgroundColor = UIColor.clear
        viewStep2.backgroundColor = UIColor.clear
        
        imgStep1.image = UIImage(named: images[0])
        lblTitle1.text = titles[0]
        lblDesc1.text = descs[0]
     
        AnalyticsHelper().analyticLogScreen(screen: "tour1")

        AppFlyerHelper().trackScreen(screenName: "tour1")
        
    }
    
    
    @objc func enableButton(_ sender:UIButton){
        sender.isEnabled = true
    }
    
    @IBAction func btnNextClicked(_ sender: UIButton) {
        
        // to disable button for 1 sec during animation
        sender.isEnabled = false
        self.perform(#selector(self.enableButton(_:)), with: sender, afterDelay: 0.7)
        
        // calculations
        currentIndex = currentIndex + 1
        let arrayIndex = currentIndex-1
        
        // change bg color
        if arrayIndex < bgColors.count {
            UIView.animate(withDuration: 0.5) {
                self.guideView.backgroundColor = UIColor(hexString: self.bgColors[arrayIndex])
            }
        }
        
        // change slides
        if currentIndex < images.count + 1 {
            let nextImage = images[arrayIndex]
            let nextTitle = titles[arrayIndex]
            let desc = descs[arrayIndex]
            
            if currentIndex%2 == 0 { // even
                
                imgStep2.image = UIImage(named: nextImage)
                lblTitle2.text = nextTitle
                lblDesc2.text = desc
                
                imageFadeInFadeOut(fadeInView: imgStep2, fadeInViewConstraint: imgStep2TopConstraint, fadeOutView: imgStep1, fadeOutViewConstraint: imgStep1TopConstraint)
                
                textFadeInFadeOut(fadeInView: lblTitle2, fadeInViewConstraint: lblTitle2TopConstraint, fadeOutView: lblTitle1, fadeOutViewConstraint: lblTitle1TopConstraint)
                textFadeInFadeOut(fadeInView: lblDesc2, fadeInViewConstraint: lblDesc2TopConstraint, fadeOutView: lblDesc1, fadeOutViewConstraint: lblDesc1TopConstraint)
                
            }else{ // odd
                
                imgStep1.image = UIImage(named: nextImage)
                lblTitle1.text = nextTitle
                lblDesc1.text = desc
                
                imageFadeInFadeOut(fadeInView: imgStep1, fadeInViewConstraint: imgStep1TopConstraint, fadeOutView: imgStep2, fadeOutViewConstraint: imgStep2TopConstraint)
                
                textFadeInFadeOut(fadeInView: lblTitle1, fadeInViewConstraint: lblTitle1TopConstraint, fadeOutView: lblTitle2, fadeOutViewConstraint: lblTitle2TopConstraint)
                textFadeInFadeOut(fadeInView: lblDesc1, fadeInViewConstraint: lblDesc1TopConstraint, fadeOutView: lblDesc2, fadeOutViewConstraint: lblDesc2TopConstraint)
                
            }
        }else if(currentIndex == images.count+1){
            
            imageFadeInFadeOut(fadeInView: imgStep9, fadeInViewConstraint: imgStep1TopConstraint, fadeOutView: imgStep2, fadeOutViewConstraint: imgStep2TopConstraint)
            textFadeInFadeOut(fadeInView: viewStep9, fadeInViewConstraint: view9BottomConstraint, fadeOutView: viewStep2, fadeOutViewConstraint: view2BottomConstraint)
            
        }else{
            self.dismiss(animated: true, completion: nil)
        }
     
        let screenName = "tour\(currentIndex)"
        
        AnalyticsHelper().analyticLogScreen(screen: screenName)
        
        AppFlyerHelper().trackScreen(screenName: screenName)

    }
    
    func imageFadeInFadeOut(fadeInView:UIView, fadeInViewConstraint:NSLayoutConstraint, fadeOutView:UIView, fadeOutViewConstraint:NSLayoutConstraint){

        fadeOutViewConstraint.constant = fadeOutView.frame.size.height * -1
        fadeOutView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: {
            fadeOutView.alpha = 0
            fadeOutView.superview!.layoutIfNeeded()
        }) { (completed) in
            fadeOutView.isHidden = true
        }
        
        fadeInViewConstraint.constant = self.view.frame.size.height // push down
        fadeInView.superview!.layoutIfNeeded()
        if Device.size() >= .screen7_9Inch {
            fadeInViewConstraint.constant = 200
        }else{
            fadeInViewConstraint.constant = 67
        }
        fadeInView.alpha = 0
        fadeInView.isHidden = false
        
        UIView.animate(withDuration: 0.7, animations: {
            fadeInView.alpha = 1
            fadeInView.superview!.layoutIfNeeded()
        }) { (completed) in
            //
        }
        
    }
    
    func textFadeInFadeOut(fadeInView:UIView, fadeInViewConstraint:NSLayoutConstraint, fadeOutView:UIView, fadeOutViewConstraint:NSLayoutConstraint){

        fadeOutView.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            fadeOutView.alpha = 0
        }) { (completed) in
        }

        fadeInView.alpha = 0
        fadeInView.isHidden = false

        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            fadeInView.alpha = 1
        }) { (completed) in
        }
    }

    
    @IBAction func btnExit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
