//
//  ProfileImageView.swift
//  Plano
//
//  Created by Paing Pyi on 1/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width/2;
        self.clipsToBounds = true;
        self.contentMode = .scaleAspectFill;
    }
}
