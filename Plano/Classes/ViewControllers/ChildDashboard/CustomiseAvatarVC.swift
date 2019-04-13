//
//  CustomiseAvatarVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import PKHUD
import RealmSwift
import Kingfisher

class CustomiseAvatarVC : _BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnBadge: UIButton!
    @IBOutlet weak var btnHat: UIButton!
    @IBOutlet weak var btnGlasses: UIButton!
    @IBOutlet weak var btnBuy: UIButton!

    @IBOutlet weak var imgBadge: UIImageView!
    @IBOutlet weak var imgGlasses: UIImageView!
    @IBOutlet weak var imgHat: UIImageView!
    @IBOutlet weak var imgHatBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var lblChildTimer: UILabel!
    @IBOutlet weak var lblChildPoints: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var avatorShopTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var avatorShopHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var avatarHolderConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHolderYConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgeXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shopBtn_Outlet: UIButton!
    // iPhone X Support
    @IBOutlet weak var avatorShopTitleTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var backTopConstraint : NSLayoutConstraint!
    
    
    var viewModel = ChildDashboardViewModel()
    var token : NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeRealmNotification()
        
        initView()
        
        setUpLayout()
        
        callApi()
        
        if Device.size() == .screen5_8Inch{
            avatorShopTitleTopConstraint.constant = 66
            backTopConstraint.constant = 47
        }else{
            avatorShopTitleTopConstraint.constant = 46
            backTopConstraint.constant = 27
        }
        
    }
    
    func setUpLayout() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // Setting layout for banner
        if Device.size() == .screen3_5Inch{
            
            imgHatBottomConstraint.constant = -110
            avatorShopHeightConstraint.constant = 150
            avatorShopTopConstraint.constant = 63
            
            collectionView.register(UINib(nibName : "AvatarCell_3_5Inch", bundle : nil), forCellWithReuseIdentifier: "AvatarCell_3_5Inch")
            layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: 69, height: 97)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 9
            layout.scrollDirection = .horizontal
            
        }else{
            
            collectionView.register(UINib(nibName : "AvatarCell", bundle : nil), forCellWithReuseIdentifier: "AvatarCell")
            layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: 109, height: 137)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 9
            layout.scrollDirection = .horizontal
            
        }
        collectionView.collectionViewLayout = layout
        collectionView.isScrollEnabled = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Child Customise Avatar Page",pageName:"Customise Avatar Page",actionTitle:"Customising Avatar")
        if ProfileData.getProfileObj()?.countryResidence == "SG"{
            shopBtn_Outlet.isHidden = false
        }else{
            shopBtn_Outlet.isHidden = true
        }
        registerForChildSessionTimer()
        if Device.size() <= .screen4Inch {
            avatarHolderConstraint.constant = 200
            avatarHolderYConstraint.constant = -50
            self.view.layoutIfNeeded()
        }else if Device.size() <= .screen5_8Inch {
            avatarHolderConstraint.constant = 250
            avatarHolderYConstraint.constant = -50
            imgHatBottomConstraint.constant = -120
            self.view.layoutIfNeeded()
        }else{ // iPads
            avatarHolderConstraint.constant = 400
            imgHatBottomConstraint.constant = -215
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
        
        unRegisterForChildSessionTimer()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - RealmNotification
    deinit {
        unSubscribeRealmNotification()
    }
    
    func subscribeRealmNotification(){
        
        guard let acp = viewModel.activeChildProfile else {
            return
        }
        
        token = acp.addNotificationBlock { change in
            switch change {
            case .change(let properties):
                for property in properties {
                    if property.name == "gamePoint" {
                        if let value = property.newValue as? String {
                            self.gamePointCallback(value)
                        }
                    }
                }
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
            
        }
        
    }
    
    func unSubscribeRealmNotification(){
        token?.stop()
    }
    
    func gamePointCallback(_ gamePoint:String){
        self.lblChildPoints.text = "\(gamePoint) pts".localized()
        
    }
    
    // MARK: - Child Session Timer
    
    func registerForChildSessionTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimerView(_:)), name: Notification.Name(ChildSessionManager.timerNotificationIdentifier), object: nil)
        
    }
    
    func unRegisterForChildSessionTimer(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(ChildSessionManager.timerNotificationIdentifier), object: nil);
    }
    
    @objc func updateTimerView(_ notification:Notification){
        if let value = notification.object as? String {
            lblChildTimer.text = value
        }
    }
    
    
    // MARK: - Views
    
    func initView(){
        imgGlasses.image = nil
        imgHat.image = nil
        imgBadge.image = nil
        
        if let acp = viewModel.activeChildProfile {
            gamePointCallback(acp.gamePoint)
        }

        viewModel.setActiveToExistingItem = {(success) in
            if success == true {
                HUD.show(.success)
            }else{
                HUD.show(.error)
            }
            HUD.hide(afterDelay: 0.5)
            self.updateViewsAfterAddUpdateItem(success)
            self.btnBuy.isSelected = false
        }
        
        viewModel.buyNewItem = {(_ validation:ValidationObj) in
            if validation.isValid == true {
                HUD.show(.success)
                HUD.hide(afterDelay: 0.5)

            }else{
                
                // show message if there is message
                if let msg = validation.message() {
                    HUD.hide()
                    self.showAlert("Sorry!".localized(), msg, callBack: nil)
                }else{
                    // show just error image if no message
                    HUD.show(.error)
                    HUD.hide(afterDelay: 0.5)

                }
            }
            self.btnBuy.isSelected = false
            self.updateViewsAfterAddUpdateItem(validation.isValid)
        }
        
        viewModel.beforeApiCall = {
            HUD.show(.progress)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
    }
    
    func callApi(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // equip bought items
        self.equipExistingItems()
        
        // auto show Badge cells
        self.btnBadgeClicked(self.btnBadge)
    }
    
    func callApi11(){
        
        self.collectionView.isHidden = true
        
        // get from Api
        viewModel.getAllAvatarItems { (list) in
            // choose Badge as default selection
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        
            self.collectionView.isHidden = false
            self.collectionView.delegate = self
            self.collectionView.dataSource = self

            // equip bought items
            self.equipExistingItems()

            // auto show Badge cells
            self.btnBadgeClicked(self.btnBadge)
        }
    }
    
    func updateViewsAfterAddUpdateItem(_ success:Bool){
        self.btnBuy.isEnabled = true
        self.btnBuy.isSelected = false
        // reset the views
        self.clearTempItems()
        self.equipExistingItems()
        self.activateActiveButton()
    }
    
    // MARK: - Buttons
    
    @IBAction func btnBackClicked(_ sender: Any) {
        print("Button Touch")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBadgeClicked(_ sender: UIButton) {
        viewModel.getBadgeList()
        self.collectionView.reloadData()
        btnBadge.isSelected = true
        btnHat.isSelected = false
        btnGlasses.isSelected = false
    }
    
    @IBAction func btnHatClicked(_ sender: UIButton) {
        viewModel.getHatList()
        self.collectionView.reloadData()
        btnBadge.isSelected = false
        btnHat.isSelected = true
        btnGlasses.isSelected = false
    }

    @IBAction func btnGlassesClicked(_ sender: UIButton) {
        viewModel.getGlassesList()
        self.collectionView.reloadData()
        btnBadge.isSelected = false
        btnHat.isSelected = false
        btnGlasses.isSelected = true
    }
    
    @IBAction func btnBuyClicked(_ sender: Any) {
        
        viewModel.performBuyAction()
    }
    @IBAction func btnTestClicked(_ sender: Any) {
        log.debug(#function)
    }
    
    @IBAction func btnShopClicked(_ sender: Any) {
        // bring to parent dashboard
        let vc = UIStoryboard.ChildShop() as! _BaseViewController
        vc.parentVC = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func activateActiveButton(){
        if btnBadge.isSelected {
            btnBadgeClicked(btnBadge)
        }else if btnHat.isSelected {
            btnHatClicked(btnHat)
        }else if btnGlasses.isSelected {
            btnGlassesClicked(btnGlasses)
        }
    }

    // MARK: - Avatar UI
    
    func equipExistingItems(){
        if let data = viewModel.getActiveHatItem() {
            equipHat(data)
        }
        if let data = viewModel.getActiveBadgeItem() {
            equipBadge(data)
        }
        if let data = viewModel.getActiveGlassesItem() {
            equipGlasses(data)
        }
    }
    
    func equipBadge(_ data:AvatarItem){
        // update to new item
        viewModel.selectedAvatarItem = data
        self.imgBadge.kf.setImage(with: URL(string: data.image), placeholder: nil, options: [.transition(.fade(0.2))])

    }
    func equipHat(_ data:AvatarItem){
        // update to new item
        viewModel.selectedAvatarItem = data
        self.imgHat.kf.setImage(with: URL(string: data.image), placeholder: nil, options: [.transition(.fade(0.2))])
    }
    func equipGlasses(_ data:AvatarItem){
        // update to new item
        viewModel.selectedAvatarItem = data
        self.imgGlasses.kf.setImage(with: URL(string: data.image), placeholder: nil, options: [.transition(.fade(0.2))])
    }
    
    func clearTempItems(){
        self.imgBadge.image = nil
        self.imgHat.image = nil
        self.imgGlasses.image = nil
    }
}

extension CustomiseAvatarVC : UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let list = viewModel.selectedAvatarGroup {
            return list.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if Device.size() == .screen3_5Inch{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell_3_5Inch", for: indexPath) as! AvatarCell_3_5Inch
            
            let data = viewModel.selectedAvatarGroup![indexPath.row]
            cell.configCellWithData(data: data)
            
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
            
            let data = viewModel.selectedAvatarGroup![indexPath.row]
            cell.configCellWithData(data: data)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.selectedAvatarGroup![indexPath.row]
        
        // reset selected temp items and replace with bought items
        clearTempItems()
        equipExistingItems()
        
        if data.isBadge(){
            equipBadge(data)
        }else if data.isHat() {
            equipHat(data)
        }else if data.isGlasses(){
            equipGlasses(data)
        }
        
        self.btnBuy.isSelected = true
    }
    
}

