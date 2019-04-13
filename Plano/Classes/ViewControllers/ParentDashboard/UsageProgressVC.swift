//
//  UsageProgressVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/16/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class UsageProgressVC: _BaseViewController {
    
    var childID : Int = 0
    var dateUsed : String = ""
    
    @IBOutlet weak var lblTimeSpendTitle : UILabel!
    @IBOutlet weak var lblTotalMinutes : UILabel!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    
    
    
    var viewModel = ChildProgressViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModelCallBacks()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UsageProgressVC.getTimeUsage), name: NSNotification.Name(rawValue: "getTimeUsage"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    func initUsageView(){
        lblTimeSpendTitle.text = "Time spent on device"
        lblTotalMinutes.text = "? min"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getTimeUsage()
    }
    
    @objc func getTimeUsage(){
        viewModel.childID = childID
        viewModel.dateUsed = dateUsed
        viewModel.getTimeUsage(success: { 

            guard let timeUsageObj : TimeUsage = TimeUsage.getTimeUsageObj() else{
                return
            }
            let total_minutes = Int(timeUsageObj.totalSecond)! / 60
            if total_minutes > 1{
                self.lblTotalMinutes.text = "\(String(total_minutes)) mins"
            }else{
                self.lblTotalMinutes.text = "\(String(total_minutes)) min"
            }
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }

    }
    
    func viewModelCallBacks(){
        viewModel.beforeApiCall = {
            self.loadingIndicator.startAnimating()
        }
        
        viewModel.afterApiCall = {
            self.loadingIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
