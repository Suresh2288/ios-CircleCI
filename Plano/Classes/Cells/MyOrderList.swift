//
//  MyOrderList.swift
//  Plano
//
//  Created by John Raja on 13/06/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class MyOrderList: UITableViewCell{
    @IBOutlet weak var lbl_OrderName: UILabel!
    @IBOutlet weak var lbl_OrderStatus: UILabel!
    @IBOutlet weak var lbl_OrderDate: UILabel!
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
    }
    
}
