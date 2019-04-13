//
//  IntroVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SlideMenuControllerSwift
import SwiftyGif
import SnapKit
import RealmSwift
import PopupDialog

class IntroVC: _BaseViewController {
  
    @IBOutlet weak var btnTest: UIButton!
    
    @IBOutlet weak var introSplashHolder: UIView!
    
    @IBOutlet weak var languageTableView: UITableView!
    var viewModel = IntroViewModel()
    var LanguageSettingData : Results<Listlanguages>!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get Language Data
        self.LanguageSettingData = Listlanguages.getSettings()
     
        APIManager.sharedInstance.getVersionData(completed: { (apiResponseHandler, error) in
            
            // check if there is A ForceUpdate & Version is outdated
            if ForceUpdate.shouldForceUserToUpdate() && error == nil {
                self.showForceUpdatePopup()
            }else{
                
                // download setting data
                self.getMasterDataInBackground()
                
                // go to next screen
                self.perform(#selector(self.delayNextScreen), with: nil, afterDelay: 3.0)
            }
        })
        
        // animated splash image
        DispatchQueue.main.async {
            self.showAnimatedSplashImage()
        }
    }
    
    func showForceUpdatePopup(){
        
        let alertView = UIAlertController(title: "App Update".localized(), message: "To continue using plano,\nplease install the latest version of the app.".localized(), preferredStyle: .alert)
        
        let action = UIAlertAction(title: "UPDATE".localized(), style: .default) { (action) in
            
            // show AppStore URL from Local if cannot get from Server
            var appStoreUrl = Constants.API.AppstoreUrl
            if let obj = ForceUpdate.getVersionObject(), !obj.iOSAppLink.isEmpty {
                appStoreUrl = obj.iOSAppLink
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:appStoreUrl)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string:appStoreUrl)!)
            }
            
            // this line is to show the ForceUpdate Popup again
            // until user really update to next version
            self.showForceUpdatePopup()
        }
        
        alertView.addAction(action)
        
        // Present dialog
        self.present(alertView, animated: true, completion: nil)
    }
    
    func showAnimatedSplashImage(){
        // GIF
        let gifManager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "planosplash.gif")
        let imageView = UIImageView(gifImage: gif, manager: gifManager)
        imageView.contentMode = .scaleAspectFill
        introSplashHolder.addSubview(imageView)
        imageView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(introSplashHolder);
        }
        imageView.startAnimatingGif()
    }
        
    func delayNextScreenWithOnBoard(){
        
        let displayedOnBoard = Defaults[.displayedOnBoard]
        
        if(!displayedOnBoard){
            
            showOnBoard()
            
        }else{
            
            if viewModel.shouldShowChildDashboard() {
                
                showChildDashboardLanding()
                
            }else if viewModel.shouldShowParentDashboard() {
                
                showParentChildLandingScreen()
                
            }else{
                
                showAuthLanding()
            }
        }
    }
    
    @objc func delayNextScreen(){
        
        if viewModel.shouldShowChildDashboard() {
            
            showChildDashboardLanding()
            
        }else if viewModel.shouldShowParentDashboard() {
            
            showParentChildLandingScreen()
            
        }else{
            
            showAuthLanding()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func createMenuView() {
        
        // create viewController code...
        let menu = UIStoryboard.MenuVC()
//        let nav = UIStoryboard.ParentDashboardNav()
        let vc = UIStoryboard.MyFamily() as! MyFamilyVC
        
//        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
        
//        UINavigationBar.appearance().tintColor = UIColor(hex: "689F38")
//
//        leftViewController.mainViewController = menu
//
        let slideMenuController = SlideMenuController(mainViewController: vc, leftMenuViewController: menu)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = vc
//        self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        
//        self.window?.rootViewController = slideMenuController
//        self.window?.makeKeyAndVisible()
        navigationController?.viewControllers = [slideMenuController]
    }
    
    override func showParentChildLandingScreen(){
        viewModel.getChildRecord(completed: { (hasChildRecords) in
            if hasChildRecords {
                self.showChildRecordLanding()
            }else{
                self.showParentDashboardLanding()
            }
        })
    }

    func showOnBoard() {
        let storyboard = UIStoryboard(name: "OnBoard", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "OnBoardNav") as! UINavigationController
        UIApplication.shared.windows.first?.rootViewController = nav
    }
    
    func showAuthLanding() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "AuthNav") as! UINavigationController
        UIApplication.shared.windows.first?.rootViewController = nav
    }
    


    func showTermsVC(){
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "TermsNav") as! UINavigationController
        UIApplication.shared.windows.first?.rootViewController = nav
    }
    
    func showChildDashboardLanding(){
        let nav = UIStoryboard.ChildDashboardNav()
        UIApplication.shared.windows.first?.rootViewController = nav
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
       delayNextScreen()
    }

    func languageListsData(){
        if let _ = try! Realm().objects(Listlanguages.self).first{
        }
    }
}
extension IntroVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if LanguageSettingData == nil{
            return 0
        }
        return LanguageSettingData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat
    {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       
        
        let cell:LanguageTableViewCell = languageTableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        
        
        let languageList:[String] = ["English", "Chinese","Korean", "Japanese"]
        let selectedArray:[Int] = [0,0,0,0,0,0,0,0]
        let date_lbl = languageList[indexPath.row]
        cell.lblLanguage?.text = String("\(date_lbl) ")
        let cellValue = selectedArray[indexPath.row]
        let cellValueBool = cellValue == 1 ? true : false
        
        if cell.isSelected {
            cell.lblLanguage.font = UIFont.boldSystemFont(ofSize: 16.0)
        } else {
            // change color back to whatever it was
             cell.lblLanguage.font = UIFont.boldSystemFont(ofSize: 18.0)
        }


        cell.isSelected = cellValueBool
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:LanguageTableViewCell = tableView.cellForRow(at: indexPath) as! LanguageTableViewCell
//        label.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
//        
//        label.font = UIFont.boldSystemFontOfSize(16.0)
        if (indexPath.row == 0)
        {
//            cell.lblLanguage.font = UIFont.boldFont(ofSize: 16.0)
        }
//        cell.lblLanguage.font = UIFont.boldSystemFont(ofSize: 16.0)
//        let weight = (indexPath.row % 2 == 0) ? UIFontWeightBold : UIFontWeightRegular
//        let font = UIFont.systemFont(ofSize: 13, weight: weight)
//        cell.productName.font = font
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell:LanguageTableViewCell = tableView.cellForRow(at: indexPath) as! LanguageTableViewCell
        // tableView.reloadData()
        if (indexPath.row == 0)
        {
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
