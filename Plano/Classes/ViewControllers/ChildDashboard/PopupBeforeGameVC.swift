//
//  PopupBeforeGameVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class PopupBeforeGameVC : _BaseViewController {
    
    @IBOutlet weak var lblPlayGame: UILabel!
    @IBOutlet weak var lblWinGame: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("Play game for".localized())
            .color(" 100 ".localized(),"F7AB18")
            .normal("points".localized())
        lblPlayGame.attributedText = formattedString
        
        let formattedString1 = NSMutableAttributedString()
        formattedString1
            .normal("Win and get ".localized())
            .color(" 1,000 ".localized(),"FF1A27")
            .normal("points".localized())
        lblPlayGame.attributedText = formattedString1
        */
        
        lblPlayGame.text = "Play game for 100 points".localized()
        lblWinGame.text = "Win and get 200 points".localized()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnPlayClicked(_ sender: Any) {
        
        btnCancelClicked(sender)
        
        if let pvc = parentVC as? ChildDashboardVC {
            if pvc.canPerformAction(#selector(pvc.performPlayGame),
                                    withSender: nil) {
                pvc.perform(#selector(pvc.performPlayGame))
            }
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
