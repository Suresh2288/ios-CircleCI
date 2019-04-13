//
//  ParentNotificationsManager.swift
//  Plano
//
//  Created by Thiha Aung on 8/15/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift
import PopupDialog
import SlideMenuControllerSwift

class ParentNotificationsManager {
    
    static let sharedInstance = ParentNotificationsManager()
    
    func handleNotification(userInfo: [AnyHashable : Any]){
        
        // The main reason that it used NotificationCenter was we can't push using it's top view controller because it was slidemenucontroller. So,
        // we just send notification to _BaseViewController and do push navigation
        
        let nc = NotificationCenter.default
        
        if let type : String = userInfo["type"] as! String?{
            if type == "18"{
                showAlert("", "Complete your child's eye exam results A quick reminder to enter your child's eye power so we can ensure they are using the device properly. If you haven't already tested them, you can do so at your nearest optomitrist.".localized(), "ENTER NOW".localized(), "REMIND ME LATER".localized(), callBackOne: { _ in
                    
                    nc.post(name: Notification.Name("NotificationNav"), object: self, userInfo: ["ChildID": userInfo["childid"] as! String, "ScreenName" : "Progress"])
                    
                }, callBackTwo: nil)
            }else if type == "22"{
                showAlert("", "Your child has requested a reward! Congrats, your child is doing great. They have enough points to unlock a reward they want. Take a look to see what they'd like.".localized(), "OPEN REWARD".localized(), "VIEW LATER".localized(), callBackOne: { _ in
                    
                    nc.post(name: Notification.Name("NotificationNav"), object: self, userInfo: ["ChildID": userInfo["sender"] as! String, "ScreenName" : "Progress"])
                    
                }, callBackTwo: nil)
                
            }else if type == "19"{
                showAlert("Warning", "Your last day of free 30 days family package trial. Your account is about to expire. Subscribe now to continue using multiple child accounts or continue free and select one child account to use.".localized(), "SUBSCRIBE".localized(), "USE FOR FREE".localized(), callBackOne: { _ in
                    
                    nc.post(name: Notification.Name("NotificationNav"), object: self, userInfo: ["ScreenName" : "Premium"])
                    
                }, callBackTwo: nil)
            }else if type == "20"{
                showAlert("", "Your free 30 days family package trial ends in 5 days. We hope plano has been helpful for your child's device use. Subscribe to continue enjoying all plano family package functions.".localized(), "SUBSCRIBE".localized(), "REMIND ME LATER".localized(), callBackOne: { _ in
                    
                    nc.post(name: Notification.Name("NotificationNav"), object: self, userInfo: ["ScreenName" : "Premium"])
                    
                }, callBackTwo: nil)
            }else if type == "21"{
                showAlert("Warning","Your last day of free 30 days family package trial. Your account is about to expire. Subscribe now to continue enjoying all plano functions.".localized(), "SUBSCRIBE".localized(), callBackOne: { _ in
                    
                    nc.post(name: Notification.Name("NotificationNav"), object: self, userInfo: ["ScreenName" : "Premium"])
                    
                })
            }else if type == "4"{
                showAlert("", "Your linked account request has been accepted. Go to linked accounts to view, add and manage your account.".localized(), "OK".localized(), "GO TO LINKED ACCOUNTS".localized(), callBackOne: nil, callBackTwo: { _ in
                    
                    nc.post(name: Notification.Name("NotificationNav"), object: self, userInfo: ["ScreenName" : "LinkedAccounts"])
                    
                })
            }else if type == "23"{
                showAlert("","The plano app has been closed. Please reopen to continue tracking your child's device usage.".localized(), "OK".localized(), callBackOne: nil)
            }else if type == "14"{
                showAlert("","Child outside safe area. Your child has exited your set safe area.".localized(), "OK".localized(), callBackOne: nil)
            }else if type == "12"{
                showAlert("","Your child might need glasses/contacts. Records show your child is repeatedly holding the device too close to their face. You may want to check with an optomitrist to see if they need glasses.".localized(), "SEE RESULTS".localized(), callBackOne: nil)
            }else if type == "7"{
//                showAlert("Blocked App alert","Your child is trying to access an app that you have blocked.".localized(), "OK".localized(), callBackOne: nil)
            }else if type == "8"{
//                showAlert("","Your child might need glasses/contacts. Records show your child is repeatedly holding the device too close to their face. You may want to check with an optomitrist to see if they need glasses.".localized(), "SEE RESULTS".localized(), callBackOne: nil)
            }else if type == "11"{
                showAlert("Blocked App alert","Your child is trying to access an app that you have blocked.".localized(), "OK".localized(), callBackOne: nil)
            }
        }
    }
    
    func showAlert(_ title:String, _ message:String, _ firstButtonTitle:String,  callBackOne: (() -> Void)? )  {
        // Prepare the popup
        let title = title
        let message = message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: firstButtonTitle) {
            if let cb = callBackOne {
                cb()
            }
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        if let anotherTopVC = UIViewController.top {
            // display in Main queue for UI
            DispatchQueue.main.async {
                anotherTopVC.present(popup, animated: true, completion: nil)
            }
            
        }
    }
    
    
    func showAlert(_ title:String, _ message:String, _ firstButtonTitle:String, _ secondButtonTitle:String, callBackOne: (() -> Void)? ,callBackTwo: (() -> Void)?){
        // Prepare the popup
        let title = title
        let message = message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: firstButtonTitle) {
            if let cb = callBackOne {
                cb()
            }
        }
        
        let buttonTwo = CancelButton(title: secondButtonTitle) {
            if let cb = callBackTwo {
                cb()
            }
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne,buttonTwo])
        
        // Present dialog
        if let anotherTopVC = UIViewController.top {
            // display in Main queue for UI
            DispatchQueue.main.async {
                anotherTopVC.present(popup, animated: true, completion: nil)
            }
            
        }
    }

}
