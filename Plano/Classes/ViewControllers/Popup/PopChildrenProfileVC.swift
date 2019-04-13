//
//  ChildrenProfileVC.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/5/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopChildrenProfileVC: _BasePopupViewController {

    @IBOutlet weak var lblQuestion: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        lblQuestion.lineBreakMode = .byWordWrapping
        lblQuestion.numberOfLines = 0
        
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
