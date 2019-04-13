//
//  PopChildrenProfileCreatedVC.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/5/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopChildrenProfileCreatedVC: UIViewController {

    @IBOutlet weak var lblQuote: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblQuote.lineBreakMode = .byWordWrapping
        lblQuote.numberOfLines = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}
