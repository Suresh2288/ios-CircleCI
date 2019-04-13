//
//  ChildShopRequestPromptVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/31/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device

class ChildShopRequestPromptVC: _BaseViewController {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblSubTitle : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Device.size() >= .screen7_9Inch{
            let color = UIColor.black
            let blackTrans = UIColor.withAlphaComponent(color)(0.8)
            self.view.backgroundColor = blackTrans
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Child Shop Request Page",pageName:"Child Shop Request Page",actionTitle:"Child Shop Request")
    }
    
    @IBAction func dismissRequestPrompt(_ sender: UIButton){
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
