//
//  MenuViewController.swift
//  Plano
//
//  Created by Thiha Aung on 9/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import PopupDialog
import Device

class MenuViewController: _BaseViewController{
    
    @IBOutlet weak var tblMenu : UITableView!
    
    // iPhone X Support
    @IBOutlet weak var tblMenuTopConstraint : NSLayoutConstraint!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var userProfile : ProfileData?
    var editProfileTapGesture = UITapGestureRecognizer()
    var unMarkedNotificationList : Results<NotificationsList>!
    var markedNotificationList : Results<NotificationsList>!
    var unSeenCount : Int = 0
    
    var shippingBillingData = [StoreData]()
    var profile = ProfileData.getProfileObj()
    var viewModel = MenuViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did Load")
        
        setUpMenuLayout()
        
        userProfile = ProfileData.getProfileObj()
        
        if Device.size() == .screen5_8Inch{
            tblMenuTopConstraint.constant = -44
        }else{
            tblMenuTopConstraint.constant = 0
        }
    }
    
    // MARK: - Set up Drawer
    func setUpMenuLayout(){
        
        editProfileTapGesture = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.showEditProfile))
        
        tblMenu.tableFooterView = UIView(frame: .zero)
        
        tblMenu.register(UINib(nibName : "HeaderMenuCell", bundle : nil), forCellReuseIdentifier: "HeaderMenuCell")
        tblMenu.register(UINib(nibName : "HeaderMenuCelliPad", bundle : nil), forCellReuseIdentifier: "HeaderMenuCelliPad")
        tblMenu.register(UINib(nibName : "MenuItemCell", bundle : nil), forCellReuseIdentifier: "MenuItemCell")
        
        tblMenu.separatorInset.left = 0
        tblMenu.separatorInset.right = 0
        tblMenu.showsVerticalScrollIndicator = false
        tblMenu.bounces = false
        
        // hide last table row's separator line
        // so that we don't have to fine-tune adjust to the height of each cell for different devices
        tblMenu.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblMenu.frame.size.width, height: 1))
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("View Did Appear Called")
        
        viewModel.getNotifications(success: { _ in
            
            print("Notification List : \(NotificationsList.getNotificationsList())")
            
            //if self.userProfile?.countryResidence == "SG"{
                let cell = self.tblMenu.cellForRow(at: IndexPath(row: 3, section: 0)) as! MenuItemCell
                let itemCell = self.tblMenu.cellForRow(at: IndexPath(row: 2, section: 0)) as! MenuItemCell
                
                self.unSeenCount = NotificationsList.getUnMarkedNotificationList().count
                itemCell.lblBadge.isHidden = true
                
                if self.unSeenCount == 0{
                    cell.lblNotiBadge.isHidden = true
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }else{
                    cell.lblNotiBadge.isHidden = false
                    cell.lblNotiBadge.text = String(self.unSeenCount)
                    UIApplication.shared.applicationIconBadgeNumber = self.unSeenCount
                }
//            } else {
//                let cell = self.tblMenu.cellForRow(at: IndexPath(row: 2, section: 0)) as! MenuItemCell
//                let itemCell = self.tblMenu.cellForRow(at: IndexPath(row: 3, section: 0)) as! MenuItemCell
//
//                self.unSeenCount = NotificationsList.getUnMarkedNotificationList().count
//                itemCell.lblNotiBadge.isHidden = true
//
//                if self.unSeenCount == 0{
//                    cell.lblBadge.isHidden = true
//                    UIApplication.shared.applicationIconBadgeNumber = 0
//                }else{
//                    cell.lblBadge.isHidden = false
//                    cell.lblBadge.text = String(self.unSeenCount)
//                    UIApplication.shared.applicationIconBadgeNumber = self.unSeenCount
//                }
//            }
            
            self.tblMenu.reloadData()
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("View Did Disappear")
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("View Will Disappear")
        tblMenu.reloadData()
    }
    
    
    // MARK: - Drawer Navigation
    @IBAction func btnMenuItemClicked(_ sender : UIButton){
        
        UIView.animate(withDuration: 0.05, animations: {
            sender.backgroundColor = UIColor.white
        },completion: { _ in
            sender.backgroundColor = UIColor.clear
            
            let cell = self.tblMenu.cellForRow(at: IndexPath(row: 3, section: 0)) as! MenuItemCell
            cell.lblBadge.isHidden = true
            cell.lblNotiBadge.isHidden = true
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            self.tblMenu.beginUpdates()
            self.tblMenu.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
            self.tblMenu.endUpdates()
            
            switch sender.tag {
            case 0:
                
                let vc = UIStoryboard.ParentDashboardNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 1:
                
                let vc = UIStoryboard.WalletNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 2:
                self.checkQuiz()
                
                break
            case 3:
                
                let vc = UIStoryboard.PremiumNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                
                break
            case 4:
                
                let vc = UIStoryboard.FAQNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 5:
                
                let vc = UIStoryboard.FeedbackNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 6:
                
                let vc = UIStoryboard.AboutNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 7:
                
                let vc = UIStoryboard.NotificationsNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 8:
                
                let vc = UIStoryboard.AlertSettingsNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            case 9:
                // MyOderListVC
                let vc = UIStoryboard.MyOderListVCNav()
                self.slideMenuController()?.changeMainViewController(vc, close: true)
                
                break
            default:
                break
            }
        })
    }
    
    func checkQuiz(){
        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID()]
        let url = URL(string: Constants.API.URL + "/Utilities/GetQuizLink")!
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
            if apiResponseHandler.isSuccess(){
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    let dataClassIs = StoreData()
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let DataIS = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        if (DataIS as AnyObject).object(forKey: "QuizLink") as? String != nil{
                            if (DataIS as AnyObject).object(forKey: "QuizLink") as! String != ""{
                                dataClassIs.setQuiz(QuizUrls: (DataIS as AnyObject).object(forKey: "QuizLink") as! String)
                                
                                let newURL = (DataIS as AnyObject).object(forKey: "QuizLink") as! String
                                
                                UserDefaults.standard.set(newURL, forKey: "QuizURL")
                                let vc = UIStoryboard.QuizNav()
                                self.slideMenuController()?.changeMainViewController(vc, close: true)
                                
                            }else{
                                dataClassIs.setQuiz(QuizUrls: "0")
                            }
                        }
                    }
                    
                }
            }else{
                self.showAlert(apiResponseHandler.errorMessage())
            }
        }
    }
    
    @objc func showEditProfile(){
        let vc = UIStoryboard.UpdateProfileNav()
        self.slideMenuController()?.changeMainViewController(vc, close: true)
    }
    
    
}

// MARK: - Drawer Gesture Delegates Bug Fix
extension MenuViewController : UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.slideMenuController()?.removeLeftGestures()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.slideMenuController()?.addLeftGestures()
    }
}

// MARK: - Drawer Datasource and Delegates
extension MenuViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if userProfile?.countryResidence == "SG"{
            return 5
//        }else{
//            return 4
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            // Setting layout for banner
            if Device.size() == .screen5_8Inch{
                return 270
            }else if Device.size() == .screen5_5Inch{
                return 250
            }else if Device.size() < .screen5_5Inch{
                return 230
            }else if Device.size() == .screen7_9Inch || Device.size() == .screen9_7Inch{
                return 350
            }else{ // iPads
                return 400
            }
        }else{
            if Device.size() == .screen5_8Inch{
                return 135.25
            }else if Device.size() == .screen5_5Inch{
                return 121.25
            }else if Device.size() < .screen5_5Inch{
                return 109.25
            }else if Device.size() == .screen7_9Inch || Device.size() == .screen9_7Inch{
                let extraSpaceToBeRemoved:CGFloat = 6 // this fix is important to clear menu to have extra white pixel when scrolldown
                return ((self.view.frame.size.height-350)/4) - extraSpaceToBeRemoved
            }else{ // iPads
                let extraSpaceToBeRemoved:CGFloat = 6 // this fix is important to clear menu to have extra white pixel when scrolldown
                return ((self.view.frame.size.height-400)/4) - extraSpaceToBeRemoved
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "HeaderMenuCell") as! HeaderMenuCell
            
            if Device.size() >= .screen7_9Inch {
                cell = tableView.dequeueReusableCell(withIdentifier: "HeaderMenuCelliPad") as! HeaderMenuCelliPad
            }
            
            cell.lblFirstItem.text = "Home".localized()
            cell.imgFirstItem.image = UIImage(named: "iconHome")
            cell.btnFirstItem.tag = 0
            cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
            //if userProfile?.countryResidence == "SG"{
                cell.lblSecondItem.text = "Shop".localized()
                cell.imgSecondItem.image = UIImage(named: "iconParentShop")
                cell.btnSecondItem.tag = 1
                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }else{
//                cell.lblSecondItem.text = "Premium".localized()
//                cell.imgSecondItem.image = UIImage(named: "iconPremium")
//                cell.btnSecondItem.tag = 3
//                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }
            
            guard let profile = userProfile else {
                return cell
            }
            
            let placeholderImage = UIImage(named: "iconAvatar")
            cell.imgProfile.kf.setImage(with: URL(string: profile.profileImage!), placeholder: placeholderImage,options: [.transition(.fade(0.5))])
            cell.imgProfile.addGestureRecognizer(editProfileTapGesture)
            
            cell.lblParentName.text = profile.firstName + " " +  profile.lastName
            
            return cell
            
        }else if indexPath.row == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
            //if userProfile?.countryResidence == "SG"{
                cell.lblFirstItem.text = "Premium".localized()
                cell.imgFirstItem.image = UIImage(named: "iconPremium")
                cell.btnFirstItem.tag = 3
                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
                cell.lblSecondItem.text = "FAQ".localized()
                cell.imgSecondItem.image = UIImage(named: "iconFaq")
                cell.btnSecondItem.tag = 4
                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }else{
//                cell.lblFirstItem.text = "FAQ".localized()
//                cell.imgFirstItem.image = UIImage(named: "iconFaq")
//                cell.btnFirstItem.tag = 4
//                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//                cell.lblSecondItem.text = "Feedback".localized()
//                cell.imgSecondItem.image = UIImage(named: "iconFeedback")
//                cell.btnSecondItem.tag = 5
//                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }
            
            return cell
            
        }else if indexPath.row == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
            //if userProfile?.countryResidence == "SG"{
                cell.lblFirstItem.text = "Feedback".localized()
                cell.imgFirstItem.image = UIImage(named: "iconFeedback")
                cell.btnFirstItem.tag = 5
                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
                cell.lblSecondItem.text = "About plano".localized()
                cell.imgSecondItem.image = UIImage(named: "iconAbout")
                cell.btnSecondItem.tag = 6
                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }else{
//                cell.lblFirstItem.text = "About plano".localized()
//                cell.imgFirstItem.image = UIImage(named: "iconAbout")
//                cell.btnFirstItem.tag = 6
//                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//                cell.lblSecondItem.text = "Notifications".localized()
//                cell.imgSecondItem.image = UIImage(named: "iconMessage")
//                cell.btnSecondItem.tag = 7
//                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }
            return cell
            
        }else if indexPath.row == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
            //if userProfile?.countryResidence == "SG"{
                cell.lblFirstItem.text = "Notifications".localized()
                cell.imgFirstItem.image = UIImage(named: "iconMessage")
                cell.btnFirstItem.tag = 7
                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
                cell.lblSecondItem.text = "My Orders".localized()
                cell.imgSecondItem.image = UIImage(named: "ic_nav_myorder")
                cell.btnSecondItem.tag = 9
                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//            }else{
//                cell.lblFirstItem.text = "Settings".localized()
//                cell.imgFirstItem.image = UIImage(named: "iconSetting")
//                cell.btnFirstItem.tag = 8
//                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//                cell.lblSecondItem.text = "".localized()
//                cell.imgSecondItem.image = UIImage(named: "")
//            }
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
            //if userProfile?.countryResidence == "SG"{
                cell.lblFirstItem.text = "Settings".localized()
                cell.imgFirstItem.image = UIImage(named: "iconSetting")
                cell.btnFirstItem.tag = 8
                
                cell.lblSecondItem.text = "".localized()
                cell.imgSecondItem.image = UIImage(named: "")
//                cell.btnSecondItem.tag = 9
                
                
                cell.btnFirstItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
//                cell.btnSecondItem.addTarget(self, action: #selector(MenuViewController.btnMenuItemClicked(_:)), for: .touchUpInside)
            //}
            return cell
        }
    }
}
