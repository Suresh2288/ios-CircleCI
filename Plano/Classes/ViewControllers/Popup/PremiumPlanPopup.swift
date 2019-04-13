//
//  PremiumPlanPopup.swift
//  Plano
//
//  Created by John Raja on 17/12/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class PremiumPlanPopup: UIViewController {

    var parentPopVC:UIViewController?
    @IBOutlet weak var lblYearlyPlan: UILabel!
    @IBOutlet weak var lblMonthPlan: UILabel!
    
    var MonthlyPrize : String = ""
    var YearlyPrize : String = ""
    var MonthlyTitle : String = ""
    var YearlyTitle : String = ""
    
    @IBOutlet weak var btnYearly: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lblMonthPlan.text = "(" + MonthlyPrize + "/month" + ")"
        lblYearlyPlan.text = "(" + YearlyPrize + "/year - 2 months off" + ")"
        
        btnMonthly.setTitle(MonthlyTitle,for: .normal)
        btnYearly.setTitle(YearlyTitle,for: .normal)
        
        btnMonthly.layer.cornerRadius = btnMonthly.frame.size.height/2
        btnYearly.layer.cornerRadius = btnYearly.frame.size.height/2
    }
    
    @IBAction func btnMonthlyPlanClicked(_ sender: Any) {
        dismiss(animated: true) {
            if let parent = self.parentPopVC as? PremiumVC {
                parent.perform(#selector(parent.SubscribeMonthlyPlanClicked))
            }
        }
    }
    
    @IBAction func btnYearlyPlanClicked(_ sender: Any) {
        dismiss(animated: true) {
            if let parent = self.parentPopVC as? PremiumVC {
                parent.perform(#selector(parent.SubscribeYearlyPlanClicked))
            }
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
