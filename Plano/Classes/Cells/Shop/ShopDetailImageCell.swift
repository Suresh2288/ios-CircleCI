//
//  ShopDetailImageCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class ShopDetailImageCell: UITableViewCell {
    
    @IBOutlet weak var imgScrollView: ImageScrollView!

    @IBOutlet weak var imgDetail : UIImageView!{
        didSet{
            imgDetail.clipsToBounds = true
            imgDetail.contentMode = .scaleAspectFit
        }
    }
    
    var imgArray:[UIImageView]! {
        didSet{
            imgScrollView.imgArray = imgArray // assign images
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        // Initialization code
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
