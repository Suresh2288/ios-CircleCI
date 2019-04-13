//
//  AlertResetPassword.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class AlertResetPassword: _BaseViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didSelectDone(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
