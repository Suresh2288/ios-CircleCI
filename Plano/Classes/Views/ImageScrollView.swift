//
//  ImageScrollView.swift
//  Plano
//
//  Created by Paing Pyi on 2/20/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit


class ImageScrollView: UIScrollView {
    
    @IBOutlet weak var pager: UIPageControl!

    var imgArray:[UIImageView]! {
        didSet{
            // clear scrollview
            self.subviews.forEach{$0.removeFromSuperview()}
            
            var lastX:CGFloat = 0.0
            
            // add images one by one
            for imgv in imgArray {
                var frame = imgv.frame
                frame.size.width = self.frame.width
                frame.size.height = self.frame.height
                frame.origin.x = lastX
                frame.origin.y = 0
                
                lastX = lastX + frame.size.width
                
                imgv.clipsToBounds = true
                imgv.contentMode = .scaleToFill
                imgv.frame = frame
                self.addSubview(imgv)
            }
            
            // this line is important to have
            // if we don't set this, scrollView won't auto set it's content width
            self.showsHorizontalScrollIndicator = false
            pager.numberOfPages = imgArray.count
            pager.currentPage = 0
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshImageView()
    }
    
    func refreshImageView(){
        var lastX:CGFloat = 0.0
        
        for imgv in self.subviews {
            var frame = imgv.frame
            frame.size.width = self.frame.width
            frame.size.height = self.frame.height
            frame.origin.x = lastX
            frame.origin.y = 0
            
            lastX = lastX + frame.size.width
            
            imgv.frame = frame
        }
        
        self.contentSize.width = CGFloat(imgArray.count) * self.frame.width
    }
    
    func scrollViewDidEndDecelerating() {
        let pageNumber = round(self.contentOffset.x / self.frame.size.width)
        pager.currentPage = Int(pageNumber)
    }
}
