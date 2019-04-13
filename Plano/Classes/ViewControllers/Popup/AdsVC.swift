//
//  AdsVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import SwiftyUserDefaults

class AdsVC: _BaseViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImageAndShow()
    }
    
    func getImageAndShow(){
        let realm = try! Realm()
        if let ads = realm.objects(SplashAdvertising.self).first {
            let url = URL(string: ads.ProductImage)
            imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: {[weak self](a, b, c, d) in
                // hide after 3 seconds
//                self?.hideAds()
                self?.perform(#selector(self?.hideAds), with: nil, afterDelay: TimeInterval(Constants.hideAdsAfterSecond))
            })
        }
        
    }
   
    @objc func hideAds(){
        self.dismiss(animated: true, completion: nil)
        Defaults[.lastAdsShownAt] = Date()
    }
    
    @IBAction func btnImageClicked(_ sender: Any) {
        let realm = try! Realm()
        if let ads = realm.objects(SplashAdvertising.self).first {
            if let url = URL(string:ads.PruchaseLink) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
