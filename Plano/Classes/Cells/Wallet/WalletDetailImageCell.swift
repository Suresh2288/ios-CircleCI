//
//  WalletDetailImageCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class WalletDetailImageCell: UITableViewCell {
    
    @IBOutlet weak var imgScrollView: ImageScrollView!
    
    @IBOutlet weak var blurView : UIView!{
        didSet{
            let color = Color.Magenta.instance()
            let purpleTrans = UIColor.withAlphaComponent(color)(0.7)
            blurView.backgroundColor = purpleTrans
        }
    }
    
    @IBOutlet weak var lblPrize : UILabel!

    var imgArray:[UIImageView]! {
        didSet{
            imgScrollView.imgArray = imgArray // assign images
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgScrollView.layoutSubviews() // to properly set the size of images
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        imgScrollView.scrollViewDidEndDecelerating() // to track the pager
    }
}
