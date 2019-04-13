//
//  AuthLandingVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import SwiftyUserDefaults
import PKHUD

class AuthLandingVC: _BaseViewController {
    
    let viewModel = SignInViewModel()

    @IBOutlet weak var introText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ProfileData.clearProfileData()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("New to ",introText.getLabelFontSize())
            .bold("plano",introText.getLabelFontSize())
            .normal("? Register now \nto better manage your child’s device use and \nreward them with great family activities \nfrom our partners in the plano store!",introText.getLabelFontSize())
        introText.attributedText = formattedString

        // Register notification
        self.perform(#selector(registerNotification), with: nil, afterDelay: 1)
        
        viewModel.checkAccountType0Callback = {[weak self](registerDataModel) in
            if let vc = UIStoryboard.ResetPassword() as? ResetPasswordVC {
                vc.viewModel.registerDataModel = registerDataModel
                vc.parentLockPassword = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        viewModel.checkAccountType1Callback = {[weak self](email, fbToken) in
            if let vc = UIStoryboard.LinkWithFacebook() as? LinkWithFacebookVC {
                vc.viewModel.email = email
                vc.viewModel.fbToken = fbToken
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }

        viewModel.checkAccountType2Callback = {[weak self](validationObj) in
            if validationObj.isValid {
                self?.goToNextScreen()
            }else{
                if let msg = validationObj.message() {
                    self?.showAlert(msg)
                }

            }
        }

        viewModel.checkAccountType3Callback = {[weak self](success,error) in
            if !success, let msg = error {
                self?.showAlert(msg)
            }else{
                self?.goToNextScreen()
            }
        }

        viewModel.beforeApiCall = {() in
            HUD.show(.systemActivity)
        }

        viewModel.afterApiCall = {() in
            HUD.hide()
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
        UIApplication.shared.statusBarStyle = .default
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = navigationController {
            nav.setNavigationBarHidden(false, animated: true)
        }
    }
    @IBAction func signInWithFacebook(_ sender: Any) {

        //loginWithFacebook()
    }

    @objc func registerNotification(){
        // Register notification
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.registerForNotification()
        }
    }
    
    /*
    func loginWithFacebook(){
        let loginManager = LoginManager()
        
        // to avoid `com.facebook.sdk.login Code=304` error
        loginManager.logOut()
        
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                log.debug(error)
            case .cancelled:
                log.debug("User cancelled login")
            case .success( _, _, let accessToken):
                
                let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name,first_name,last_name"], accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)
                
                request.start {[weak self] response, result in
                    switch result {
                        case .success(let response):

                            if let email = response.dictionaryValue?["email"] as? String,
                                let fn = response.dictionaryValue?["first_name"] as? String,
                                let ln = response.dictionaryValue?["last_name"] as? String,
                                let id = response.dictionaryValue?["id"] as? String
                                {
                                    self?.checkEmailFirst(email: email, fbid: id, fbToken:accessToken.authenticationToken, firstName: fn, lastName: ln)
//                                    self?.callToApiServerToLoginWithFacebook(accessToken.authenticationToken, email)
                            }
//                            let fn = "\(response.dictionaryValue?["first_name"])"
//                            let ln = "\(response.dictionaryValue?["last_name"])"
//                            let id = "\(response.dictionaryValue?["id"])"

                        case .failed(_):
                            self?.showAlert("Cannot retrieve profile.\nPlease try again!")
                    }
                 }
            }
        }
    }
    */
    
    func checkEmailFirst(email:String, fbid:String, fbToken:String, firstName:String, lastName:String){
        viewModel.email = email
        viewModel.firstName = firstName
        viewModel.lastName = lastName
        viewModel.fbid = fbid
        viewModel.fbToken = fbToken

        viewModel.checkAccountBeforeRegister(success: { (validationObj) in
            
            // do nothing
            
        }) { (validationObj) in
            if let msg = validationObj.message() {
                self.showAlert(msg)
            }
        }
    }

    func callToApiServerToLoginWithFacebook(_ accessToken:String, _ email:String){
        
        viewModel.fbToken = accessToken
        viewModel.email = email
        
        viewModel.loginWithFacebook(success: {[weak self] validationObj in

            log.debug("Finally Login Success")

            self?.goToNextScreen()

        }, failure: {[weak self] validationObj in

            if let msg = validationObj.message() {
                if !msg.isEmpty {
                    self?.showAlert(msg)
                }
            }
        })

    }
    
    func goToNextScreen(){
        
        self.showParentChildLandingScreen()
        
        self.getMasterDataInBackground()
    }
    
    
}
