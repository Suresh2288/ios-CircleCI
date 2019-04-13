//
//  QuizVC.swift
//  Plano
//
//  Created by Ganesh on 21/08/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class QuizVC: _BaseViewController {

    var shippingBillingData = [StoreData]()
    
    @IBOutlet weak var webView: UIWebView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let urlStr = UserDefaults.standard.string(forKey: "QuizURL")
        
        let url = NSURL (string: urlStr!)
        let requestObj = NSURLRequest(url: url! as URL);
        webView.loadRequest(requestObj as URLRequest)
        
        if parentVC != nil {
            removeLeftMenuGesture()
            setUpNavBarWithAttributes(navtitle: "Quiz".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }else{
            setupMenuNavBarWithAttributes(navtitle: "Quiz".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
