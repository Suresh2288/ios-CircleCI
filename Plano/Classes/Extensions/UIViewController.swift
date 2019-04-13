//
//  UIViewController.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

public extension UIViewController {

    typealias alertCallback = () -> Void

    func showNativeAlert(_ message:String){
        let alertController = UIAlertController(
            title: "Error".localized(),
            message: message,
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(_ message:String) {
        showAlert(message, callBack: nil)
    }
    
    
    func showAlert(_ message:String, callBack: (() -> Void)? )  {
        showAlert("", message, callBack: callBack)
    }
    
    
    func showAlert(_ title:String, _ message:String, callBack: (() -> Void)? ){
        showAlert(title, message, "OK".localized(), callBack: callBack)
    }
    
    
    func showAlert(_ title:String, _ message:String, _ buttonTitle:String, callBack: (() -> Void)? ){
        // Prepare the popup
        let title = title
        let message = message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonThree = CancelButton(title: buttonTitle) {
            if let cb = callBack {
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
        
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonThree])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func showAlert(_ title:String, _ message:String, _ buttonTitle:String, _ buttonTitleTwo:String , callBackOne: (() -> Void)?, callBackTwo: (() -> Void)?){
        // Prepare the popup
        let title = title
        let message = message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: buttonTitle) {
            if let cb = callBackOne {
                cb()
            }
        }
        let buttonTwo = DefaultButton(title: buttonTitleTwo) {
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
        self.present(popup, animated: true, completion: nil)
    }


    // top view
    
    static var top: UIViewController? {
        get {
            return topViewController()
        }
    }
    
    static var root: UIViewController? {
        get {
            return UIApplication.shared.delegate?.window??.rootViewController
        }
    }
    
    static func topViewController(from viewController: UIViewController? = UIViewController.root) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
}


