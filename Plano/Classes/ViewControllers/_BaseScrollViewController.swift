//
//  BaseViewController.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import AMScrollingNavbar

class _BaseScrollViewController: _BaseViewController {
 
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var headerBg: UIImageView!
    var shouldFollowScrollView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Auto hide NavigationBar upon scrolling
        if shouldFollowScrollView {
            if let navigationController = navigationController as? ScrollingNavigationController {
                navigationController.followScrollView(scrollView, delay: 0)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        UIApplication.shared.isStatusBarHidden = false
    }
}

extension _BaseScrollViewController: UIScrollViewDelegate {
    
    // Auto hide the headerBg upon scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if shouldFollowScrollView {
          
            let y = scrollView.contentOffset.y
            
            // 100% - (100% / (maxY / currentY))
           
            headerBg.alpha = 1-(1/(100/y))
            self.navigationController?.navigationItem.titleView?.alpha = headerBg.alpha
            if(headerBg.alpha >= 1){

                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    UIApplication.shared.isStatusBarHidden = false
            }else{
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                UIApplication.shared.isStatusBarHidden = true
            }
        }
    }

}
