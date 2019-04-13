//
//  _BasePopupViewController.swift
//  Plano
//
//  Created by Paing Pyi on 4/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class _BasePopupViewController : _BaseViewController {
    
    var viewModel = PopupViewModel()
    
    func dismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    func checkParentPasswordSuccess(){
        dismiss(animated: true) {
            self.viewModel.checkParentPasswordSuccess()
        }
    }
}
