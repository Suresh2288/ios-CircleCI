//
//  LinkedAccountsVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device

class LinkedAccountsVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "linked"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "linked"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var imgMyChild : UIImageView!{
        didSet{
            imgMyChild.clipsToBounds = true
            imgMyChild.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var imgOtherChild : UIImageView!{
        didSet{
            imgOtherChild.clipsToBounds = true
            imgOtherChild.layer.cornerRadius = 5.0
        }
    }
    
    @IBOutlet weak var lblMyChild : UILabel!
    @IBOutlet weak var lblOtherChild : UILabel!
    @IBOutlet weak var lblMyChildDescription : UILabel!
    @IBOutlet weak var lblOtherChildDescription : UILabel!
    
    @IBOutlet weak var myChildIconVerticalContraint : NSLayoutConstraint!
    @IBOutlet weak var otherChildIconVerticalConstraint : NSLayoutConstraint!

    
    @IBOutlet weak var btnMyChild : UIButton!{
        didSet{
            btnMyChild.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var btnOtherChild : UIButton!{
        didSet{
            btnOtherChild.layer.cornerRadius = 5.0
        }
    }
    
    override func loadView() {
        super.loadView()
        setUpLinkedAccountLanding()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Linked Accounts Page",pageName:"Linked Accounts Page",actionTitle:"Entered in linked accounts page")

        if parentVC != nil {
            removeLeftMenuGesture()
            setUpNavBarWithAttributes(navtitle: "Linked accounts".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }else{
            setupMenuNavBarWithAttributes(navtitle: "Linked accounts".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }
        
        if Device.size() == .screen3_5Inch{
            myChildIconVerticalContraint.constant = -120
            otherChildIconVerticalConstraint.constant = -100
        }else if Device.size() == .screen4_7Inch {
            myChildIconVerticalContraint.constant = -100
            otherChildIconVerticalConstraint.constant = -80
        }
        self.view.layoutIfNeeded()
    }
    
    func setUpLinkedAccountLanding(){
        lblMyChild.text = "My Children".localized()
        lblMyChildDescription.text = "Parents/Carers that you allow to \nmanage your children.".localized()
        lblOtherChild.text = "Other Children".localized()
        lblOtherChildDescription.text = "Others Parents/Carers that allow \nyou to manage their children.".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func goToMyChildLinkedAccounts(_ sender : UIButton){
        UIView.animate(withDuration: 0.05, animations: {
            sender.backgroundColor = UIColor.white
        },completion: { _ in
            sender.backgroundColor = UIColor.clear
            let vc = UIStoryboard.MyChildContainer()
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @IBAction func goToOtherChildLinkedAccounts(_ sender : UIButton){
        UIView.animate(withDuration: 0.05, animations: {
            sender.backgroundColor = UIColor.white
        },completion: { _ in
            sender.backgroundColor = UIColor.clear
            let vc = UIStoryboard.OtherChildsContainer()
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
}
