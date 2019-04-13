//
//  PairGameCell.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class PairGameCell: UICollectionViewCell {
    
    @IBOutlet weak var upperView: UIImageView!
    @IBOutlet weak var hiddenView: UIImageView!
    @IBOutlet weak var bgView: UIImageView!
    
    var pairGameObj:PairGameObj?
    
    func configCellWithData(data:PairGameObj){
        self.hiddenView.image = data.objType.image()
        upperView.isHidden = false
        hiddenView.isHidden = true
    }
    
    func revealCell(data:PairGameObj){
        if data.revealed {
            hideItem()
            data.revealed = false
        }else{
            revealItem()
            data.revealed = true
        }
    }
    
    func closeCell(data:PairGameObj){
        hideItem()
        data.revealed = false
    }
    
    func revealItem(){
        flip(firstView: upperView, secondView: hiddenView)
    }
    
    func hideItem(){
        flip(firstView: hiddenView, secondView: upperView)
    }
    
    func flip(firstView:UIView, secondView:UIView) {

        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight]
        
        // flip firstView
        UIView.transition(with: firstView, duration: 0.4, options: transitionOptions, animations: {
            firstView.isHidden = true
        })
        
        // flip bg
        UIView.transition(with: bgView, duration: 0.4, options: transitionOptions, animations:nil)
        
        // flip secondView
        UIView.transition(with: secondView, duration: 0.4, options: transitionOptions, animations: {
            secondView.isHidden = false
        })
    
    }
    
    func animateCell(){
        self.hiddenView.transform = CGAffineTransform(scaleX: 1, y: 1)
        
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
//            if !self.hiddenView.isHidden {
//                self.hiddenView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
//            }
//        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            if !self.hiddenView.isHidden {
                self.hiddenView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            }
        }) { (complete) in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                if !self.hiddenView.isHidden {
                    self.hiddenView.transform = CGAffineTransform.identity
                }
            }, completion: nil)
        }
        
//        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 15, initialSpringVelocity: 20, options: .curveEaseOut, animations: {
//            if !self.hiddenView.isHidden {
//                self.hiddenView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
//            }
//        }) { (complete) in
//           
//            
//        }
        
    }
    
}


