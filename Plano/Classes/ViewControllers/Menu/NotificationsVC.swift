//
//  NotificationsVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/29/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import Device

class NotificationsVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "notifications"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "notifications"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var noNotificationView : UIView!
    @IBOutlet weak var lblNoNotifications : UILabel!
    @IBOutlet weak var tblNotifications : UITableView!
    
    var viewModel = ParentNotificationsViewModel()
    var notificationsList : Results<NotificationsList>!
    var isPresented : Bool = false
    
    var notiIDs : [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Notifications Page",pageName:"Notifications Page",actionTitle:"Entered in Notifications page")

        setupMenuNavBarWithAttributes(navtitle: "Notifications", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))

        setUpNotificationsView()
        viewModelCallBack()
        
        tblNotifications.allowsMultipleSelection = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isPresented{
            viewModel.getNotifications(success: { 
                
                self.notificationsList = NotificationsList.getNotificationsList()
                
                if self.notificationsList.count > 0{
                    
                    NotificationsList.updateNotificationLocally()
                    
                    UIView.transition(with: self.tblNotifications, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                        
                        self.tblNotifications.reloadData()
                        
                    }, completion: nil)
                    
                    
                }else{
                    
                    self.noNotificationView.isHidden = false
                    
                }
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
            }
            isPresented = true
        }
        
    }
    
    func setUpNotificationsView(){
        
        noNotificationView.isHidden = true
        lblNoNotifications.text = "No notifications yet".localized()
        
        tblNotifications.register(UINib(nibName : "CriticalNotificationCell", bundle : nil), forCellReuseIdentifier: "CriticalNotificationCell")
        tblNotifications.register(UINib(nibName : "NormalNotificationCell", bundle : nil), forCellReuseIdentifier: "NormalNotificationCell")
        
        tblNotifications.estimatedRowHeight = 40
        tblNotifications.rowHeight = UITableView.automaticDimension
        tblNotifications.separatorInset.left = 0
        tblNotifications.separatorInset.right = 0
        tblNotifications.showsVerticalScrollIndicator = false
        tblNotifications.tableFooterView = UIView(frame: .zero)
        
        tblNotifications.delegate = self
        tblNotifications.dataSource = self
        
    }
    
    
    func viewModelCallBack(){
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.beforeSeenCall = {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        viewModel.afterSeenCall = {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }

}

extension NotificationsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificationsList == nil{
            return 0
        }
        return notificationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notifications = notificationsList[indexPath.row]
        switch notifications.type {
        case "4":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalNotificationCell") as! NormalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType4")
            
            return cell
        case "12":
            let cell = tableView.dequeueReusableCell(withIdentifier: "CriticalNotificationCell") as! CriticalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType12")
            
            return cell
        case "14":
            let cell = tableView.dequeueReusableCell(withIdentifier: "CriticalNotificationCell") as! CriticalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType14")
            
            return cell
        case "15":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalNotificationCell") as! NormalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType15")
            
            return cell
        case "18":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalNotificationCell") as! NormalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType18")
            
            return cell
        case "19":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalNotificationCell") as! NormalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType19")
            
            return cell
        case "22":
            let cell = tableView.dequeueReusableCell(withIdentifier: "CriticalNotificationCell") as! CriticalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType22")
            
            return cell
        case "23":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalNotificationCell") as! NormalNotificationCell
            
            cell.lblTitle.text = notifications.title
            cell.lblDescription.text = notifications.message
            cell.contentView.backgroundColor = notifications.seen.toBool()! ? UIColor.white : Color.FlatMilk.instance()
            cell.imgNotification.image = UIImage(named: "iconType23")
            
            return cell
        default :
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
        
        let notifications = notificationsList[indexPath.row]
        
        self.notiIDs.append(Int(notifications.pushID)!)
        
        self.viewModel.notificationIDs = self.notiIDs
        self.viewModel.seen = "1"
        
        self.viewModel.updateNotificationsSeen(success: {          
            self.notiIDs.removeAll()
            
            switch notifications.type {
            case "4":
                UIView.animate(withDuration: 0.5){
                    let nav = UIStoryboard.LinkedAccountsNav()
                    self.slideMenuController()?.changeMainViewController(nav, close: true)
                }
                break
            case "19":
                UIView.animate(withDuration: 0.5){
                    let nav = UIStoryboard.PremiumNav()
                    self.slideMenuController()?.changeMainViewController(nav, close: true)
                }
                break
            case "22":
                if Device.size() >= .screen7_9Inch{
                    if let vc = UIStoryboard.ChildProgressiPad() as? ChildProgressVCiPad {
                        vc.parentVC = self
                        vc.childID = Int(notifications.childID)!
                        vc.isChildRequestNotifications = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }else{
                    if let vc = UIStoryboard.ChildProgress() as? ChildProgressVC {
                        vc.parentVC = self
                        vc.childID = Int(notifications.childID)!
                        vc.isChildRequestNotifications = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                break
            default:
                break
            }
            
        }) { (errorMessage) in
            
            self.notiIDs.removeAll()
            
        }
        
        
        
    }
}
