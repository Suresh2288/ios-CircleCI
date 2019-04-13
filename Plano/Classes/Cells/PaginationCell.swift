//
//  PaginationCell.swift
//  Plano
//
//  Created by John Raja on 12/06/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class PaginationCell: UICollectionViewCell{
    @IBOutlet weak var lbl_PageNumber_Outlet: UILabel!
    @IBOutlet weak var vw_Borders_Outlet: UIView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
       self.vw_Borders_Outlet.layer.cornerRadius = 8
    }

}
