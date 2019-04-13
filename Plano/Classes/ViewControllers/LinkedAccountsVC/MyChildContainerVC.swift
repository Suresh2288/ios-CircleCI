//
//  MyChildContainerVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PageMenu
import Device

class MyChildContainerVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "mychild"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "mychild"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var containerView : UIView!
    
    var pageMenu : CAPSPageMenu?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBarWithAttributes(navtitle: "My Child", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        navigationItem.setRightBarButton(showAddBtn(), animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeLeftMenuGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpMyChildVCs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addLeftMenuGesture()
    }
    
    func showAddBtn() -> UIBarButtonItem {
        let img : UIImage? = UIImage.init(named: "iconAdd")!.withRenderingMode(.alwaysOriginal)
        let btn:UIBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(btnAddClicked(_:)))
        btn.imageInsets = UIEdgeInsets.init(top: 2,left: 0,bottom: 0,right: 0)
        return btn
    }
    
    func setUpMyChildVCs(){
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []

        let guardianVC : GuardiansVC = UIStoryboard.Guardians() as! GuardiansVC
        guardianVC.title = "Guardians".localized()
        controllerArray.append(guardianVC)
        
        let pendingRequestsVC : PendingRequestsVC = UIStoryboard.PendingRequests() as! PendingRequestsVC
        pendingRequestsVC.title = "Pending Requests".localized()
        controllerArray.append(pendingRequestsVC)
        
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
            .menuMargin(0.0),
            .menuHeight(60.0),
            .selectedMenuItemLabelColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor(hexString: "2B9CA8")!),
            .menuItemFont(FontBook.Bold.of(size: titleSize)),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(7),
            .menuItemSeparatorPercentageHeight(0.0),
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
    
    @IBAction func btnAddClicked(_ sender: Any){
        performSegue(withIdentifier: "ShowAddParent", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MyChildContainerVC : CAPSPageMenuDelegate{
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print("did move to page")
    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print("will move to page")
    }
}
