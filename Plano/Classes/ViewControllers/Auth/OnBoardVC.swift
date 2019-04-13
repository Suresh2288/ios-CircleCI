//
//  OnBoardVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import EAIntroView
import SwiftHEXColors
import Device
import SwiftyUserDefaults

class OnBoardVC: _BaseViewController {
  
    @IBOutlet weak var btnTest: UIButton!

    @IBOutlet weak var guideView1: UIView!
    @IBOutlet weak var guideView1Text: UILabel!
    @IBOutlet weak var guideView1Image: UIImageView!
    
    @IBOutlet weak var guideView2: UIView!
    @IBOutlet weak var guideView2Text: UILabel!
    
    @IBOutlet weak var guideView3: UIView!
    @IBOutlet weak var guideView3Text: UILabel!
    
    var intro:EAIntroView = EAIntroView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        self.initIntroView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initIntroView() {
        
        guideView1.isHidden = true
        guideView2.isHidden = true
        guideView3.isHidden = true
        
        let e1:EAIntroPage = EAIntroPage(customView: guideView1)
        let e2:EAIntroPage = EAIntroPage(customView: guideView2)
        let e3:EAIntroPage = EAIntroPage(customView: guideView3)
        
        intro = EAIntroView(frame: self.view.bounds, andPages: [e1, e2, e3])
        
        intro.delegate = self;
        intro.swipeToExit = false;
        intro.skipButton = nil;
        intro.pageControlY = 130;
        intro.backgroundColor = UIColor.clear
        intro.alpha = 0;
        intro.pageControl.pageIndicatorTintColor = Color.Gray.instance()
        intro.pageControl.currentPageIndicatorTintColor = Color.Cyan.instance()
        intro.show(in: self.view, animateDuration: 0.2)
        
        guideView1.isHidden = false
        guideView2.isHidden = false
        guideView3.isHidden = false
        
        self.view.bringSubviewToFront(btnTest)
        
//        optimizeForSmallerScreens()
        
        AnalyticsHelper().analyticLogScreen(screen: "get1")
        
        AppFlyerHelper().trackScreen(screenName: "get1")

        let formattedString1 = NSMutableAttributedString()
        let f1t1 = "Too much screen time can tire your children, leading to eye discomfort and potentially myopia.\n".localized()
        let f1t2 = "plano"
        let f1t3 = " runs in the background with a range of smart eye health features."
        formattedString1
            .normal(f1t1)
            .bold(f1t2,13.0)
            .normal(f1t3)
        paraAndLineHeight(formattedString: formattedString1, count:  f1t1.utf16.count + f1t2.utf16.count + f1t3.utf16.count)
        guideView1Text.attributedText = formattedString1

        let formattedString2 = NSMutableAttributedString()
        let f2t1 = "plano"
        let f2t2 = "'s 'face to screen'\ncalibration guides your\nchild to hold the device\nat the right distance.".localized()
        formattedString2
            .bold(f2t1,13.0)
            .normal(f2t2)
        lineHeight(formattedString: formattedString2,
                   count: f2t1.utf16.count + f2t2.utf16.count)
        guideView2Text.attributedText = formattedString2
        
        let formattedString3 = NSMutableAttributedString()
        let f3t1 = "It is always tempting to get that extra bit of game time. Having some device-free time and getting outdoors makes all the difference!\n"
        let f3t2 = "plano"
        let f3t3 = "'s inbuilt smart alerts empowers your child to develop good habits.\nAnd "
        let f3t4 = "plano"
        let f3t5 = " does so much more... let’s get started!"

        formattedString3
            .normal(f3t1)
            .bold(f3t2,13.0)
            .normal(f3t3)
            .bold(f3t4,13.0)
            .normal(f3t5)
        paraAndLineHeight(formattedString: formattedString3, count:  f3t1.utf16.count + f3t2.utf16.count + f3t3.utf16.count + f3t4.utf16.count + f3t5.utf16.count)

        guideView3Text.attributedText = formattedString3
        
    }
    
    func lineHeight(formattedString:NSMutableAttributedString, count:Int){
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3 // change line spacing between paragraph like 36 or 48
        style.paragraphSpacing = 0.5
        formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: count))
    }
    
    func paraAndLineHeight(formattedString:NSMutableAttributedString, count:Int){
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3 // change line spacing between paragraph like 36 or 48
        style.paragraphSpacing = 10
        formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: count))
    }
    
    @IBAction func getStartedClicked(_ sender: Any) {
        if Int(intro.currentPageIndex) >= intro.pages.count-1 {
            onBoardIsDone()
        }else{
            intro.scrollToPage(for: intro.currentPageIndex+1, animated: true)
        }
    }
    override var prefersStatusBarHidden: Bool {
        if Device.size() < .screen4Inch {
            return true
        }else {
            return false
        }
    }
    
    func onBoardIsDone(){
        Defaults[.displayedOnBoard] = true
        if let window = UIApplication.shared.keyWindow {
            let nav = UIStoryboard.AuthNav()
            
            if let vc = nav.children.first {
                window.rootViewController = nav
                UIView.transition(from: self.view, to: vc.view, duration: 0.6, options: [.transitionFlipFromLeft], completion: {
                    _ in
                    
                })
            }
        }
    }
}


extension OnBoardVC: EAIntroDelegate {
    
    func introDidFinish(_ introView: EAIntroView!) {
        onBoardIsDone()
    }
    
    func intro(_ introView: EAIntroView!, pageAppeared page: EAIntroPage!, with pageIndex: UInt) {
        let pageNum = "get\(pageIndex+1)"
        
        AnalyticsHelper().analyticLogScreen(screen: pageNum)
        
        AppFlyerHelper().trackScreen(screenName: pageNum)
        
        if Int(pageIndex) >= introView.pages.count - 1 {
            btnTest.setTitle("Get started".localized(), for: .normal)
        }else{
            btnTest.setTitle("Next".localized(), for: .normal)
        }
    }
}
