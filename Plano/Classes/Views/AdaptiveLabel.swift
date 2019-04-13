//
//  AdaptiveLabel.swift
//  Plano
//
//  Created by Paing on 18/3/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

protocol AdaptiveElement {
    
    var traitCollection: UITraitCollection { get }
    func update(for incomingTraitCollection: UITraitCollection)
}

class AdaptiveLabel: UILabel, AdaptiveElement {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        update(for: traitCollection)
    }
    
    func update(for incomingTraitCollection: UITraitCollection) {
        if incomingTraitCollection.userInterfaceIdiom == .pad {
            font = font.withSize(font.pointSize + (font.pointSize*Constants.getDynamiciPadFontFactor()))
        }
    }
}

class AdaptiveTextView: UITextView, AdaptiveElement {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        update(for: traitCollection)
    }
    
    func update(for incomingTraitCollection: UITraitCollection) {
        if incomingTraitCollection.userInterfaceIdiom == .pad, let f = font {
            font = f.withSize(f.pointSize + (f.pointSize*Constants.getDynamiciPadFontFactor()))
        }
    }
}
