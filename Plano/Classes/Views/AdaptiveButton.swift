//
//  AdaptiveButton.swift
//  Plano
//
//  Created by Paing on 18/3/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class AdaptiveButton: UIButton, AdaptiveElement {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        update(for: traitCollection)
    }
    
    func update(for incomingTraitCollection: UITraitCollection) {
        if incomingTraitCollection.userInterfaceIdiom == .pad {
            if let tb = titleLabel {
                tb.font = tb.font.withSize(tb.font.pointSize + (tb.font.pointSize*Constants.getDynamiciPadFontFactor()))
            }
            
        }
    }
}
