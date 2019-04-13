//
//  OtherChildContainerVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PageMenu
import Device

class OtherChildContainerVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "linkedothers"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "linkedothers"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    var pageMenu : CAPSPageMenu?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBarWithAttributes(navtitle: "Others", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeLeftMenuGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpOtherChildVCs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addLeftMenuGesture()
    }
    
    func setUpOtherChildVCs(){
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let parentsVC : ParentsVC = UIStoryboard.Parents() as! ParentsVC
        parentsVC.title = "Parents".localized()
        controllerArray.append(parentsVC)
        
        let requestsVC : RequestsVC = UIStoryboard.Requests() as! RequestsVC
        requestsVC.title = "Requests".localized()
        controllerArray.append(requestsVC)
        
        var titleSize : CGFloat = 0.0
        if Device.size() >= .screen7_9Inch{
            titleSize = 18.0
        }else{
            titleSize = 16.0
        }
        
        // Customize page menu
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(0.0),
            .scrollMenuBackgroundColor(Color.DarkCyan.instance()),
            .viewBackgroundColor(UIColor.white),
            .bottomMenuHairlineColor(UIColor.clear),
            .selectionIndicatorColor(UIColor.clear),
            .menuMargin(60.0),
            .menuHeight(60.0),
            .selectedMenuItemLabelColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor(hexString: "2B9CA8")!),
            .menuItemFont(FontBook.Bold.of(size: titleSize)),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(7),
            .menuItemSeparatorPercentageHeight(0.1),
            .iconIndicator(true),
            .iconIndicatorView(self.getIndicatorView())
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x:0.0, y:0.0, width:self.view.frame.width, height:self.view.frame.height - 62.0), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
    }
    
    // Set up custom indicator view
    private func getIndicatorView()->UIView{
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 7))
        imgView.image = UIImage(named: "iconTriangle")
        imgView.contentMode = .scaleAspectFill
        return imgView
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

extension OtherChildContainerVC : CAPSPageMenuDelegate{
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print("did move to page")
    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print("will move to page")
    }
}
