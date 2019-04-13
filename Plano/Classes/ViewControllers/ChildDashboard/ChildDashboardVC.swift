//
//  ChildDashboardVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SwiftDate
import PopupDialog
import RealmSwift
import SwiftyUserDefaults
import AVFoundation
import PKHUD
import Device
import ObjectMapper

class ChildDashboardVC : _BaseViewController {
    
    @IBOutlet weak var avatarHolder: UIView!
    @IBOutlet weak var gameAvatar: UIImageView!
    @IBOutlet weak var gameAvatarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarHolderConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHolderYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgBadge: UIImageView!
    @IBOutlet weak var imgGlasses: UIImageView!
    @IBOutlet weak var imgHat: UIImageView!
    @IBOutlet weak var imgHatBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblChildTimer: UILabel!
    @IBOutlet weak var lblChildPoints: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblPlay: AdaptiveLabel!
    @IBOutlet weak var imgPlay: UIImageView!
    
    @IBOutlet weak var speechBubbleView: UIView!
    @IBOutlet weak var speechBubbleText: UILabel!
    @IBOutlet weak var downArrowPlay: UIImageView!
    @IBOutlet weak var downArrowCustomise: UIImageView!
    @IBOutlet weak var downArrowShop: UIImageView!

    @IBOutlet weak var downArrowPlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var downArrowCustomiseTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var downArrowShopTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgCustomise: UIImageView!
    @IBOutlet weak var btnCustomise: UIButton!
    @IBOutlet weak var lblCustomise: AdaptiveLabel!
    
    @IBOutlet weak var imgShop: UIImageView!
    @IBOutlet weak var btnShop: UIButton!
    @IBOutlet weak var lblShop: AdaptiveLabel!
    @IBOutlet weak var vw_ShopView_Outlet: UIView!
    
    
    // iPhone X Support
    @IBOutlet weak var guideButtonOneTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var guideButtonTwoTopConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var guideViewHolder: UIView!
//    private var videoComponent: INVVideoComponent?

    var timer:Timer?
    var speechBubbleTimer:Timer?
    var randomGame = arc4random_uniform(1)
    
    var viewModel = ChildDashboardViewModel()
    
    var token : NotificationToken?
    
    var currentSpeechBubbleIndex = 0
    var speechBubbleGesture:UITapGestureRecognizer?
    var isChildFirstTimeHere = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
        
        subscribeRealmNotification()

        initView()

        if !Defaults[.displayedTurnoffChildModeGuide] {
            showGuide()
            Defaults[.displayedTurnoffChildModeGuide] = true
        }else{
            startSessionIfRequired()
        }
        
        if Device.size() == .screen5_8Inch{
            guideButtonOneTopConstraint.constant = 60
            guideButtonTwoTopConstraint.constant = 60
        }else{
            guideButtonOneTopConstraint.constant = 37
            guideButtonTwoTopConstraint.constant = 37
        }
        
        // eye calibration is started only after the session is started
        // check `childSessionStarted()` method in this file
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let childProfile = ActiveChildProfile.getProfileObj() {
            WoopraTrackingPage().childProfileInfo(name: "\(childProfile.firstName) \(childProfile.lastName)", country: (Locale.current as NSLocale).object(forKey: .countryCode) as! String, profileImage: (childProfile.profileImage ?? ""),deviceType: "iOS",deviceID: childProfile.childID, childID: childProfile.childID, childGender: childProfile.gender,gamePoint:childProfile.gamePoint)
            WoopraTrackingPage().trackEvent(mainMode:"Child Dashboard",pageName:"Child Dashboard",actionTitle:"Child dashboard Page")
        }
        equipExistingItems()
        UIApplication.shared.statusBarStyle = .default
        
//        let realm = try! Realm()
//        let obj = try! realm.objects(ActiveChildProfile.self).filter("isActive = 1").first
       
        //if ProfileData.getProfileObj()?.countryResidence == "SG"{
            vw_ShopView_Outlet.isHidden = false
//        }else{
//            vw_ShopView_Outlet.isHidden = true
//        }
        registerForChildSessionTimer()
        
        btnPlay.isEnabled = viewModel.userCanPlayGame()
        if btnPlay.isEnabled {
            imgPlay.alpha = 1
        }else{
            imgPlay.alpha = 0.5
        }
        
        if Device.size() <= .screen4Inch {
            avatarHolderConstraint.constant = 200
            avatarHolderYConstraint.constant = -30
            self.view.layoutIfNeeded()
        }else if Device.size() <= .screen5_8Inch {
            avatarHolderConstraint.constant = 250
            imgHatBottomConstraint.constant = -120
            self.view.layoutIfNeeded()
        }else{ // iPads
            avatarHolderConstraint.constant = 400
            imgHatBottomConstraint.constant = -215
        }
        
        GetChildSessionCount()
    }
    
    // Get Active Child Session Number
    func GetChildSessionCount() {
        
        viewModel.getChildSessionCount { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess() {
                
                if let response = Mapper<GetChildSessionResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                    
                    
                    //                let dict = response.jsonObject as! NSDictionary
                    //                let dictData = dict.value(forKey: "Data")
                    //                let CurrentSession = (dictData as AnyObject).value(forKey: "ChildSessionCount") as! Int
                    
                    //print(String(response.ChildSessionCount))
                    UserDefaults.standard.set(String(response.ChildSessionCount), forKey: "ChildSessionNumber")
                    UserDefaults.standard.synchronize()
                    
                    //Get Child's plano points
                    self.viewModel.getPlanoPoints()
                    
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateGameAvatar()
//        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(animateGameAvatar), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterForChildSessionTimer()
        if let tm = timer {
            tm.invalidate()
        }
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

        if let acp = viewModel.activeChildProfile {
            token = acp.addNotificationBlock { change in
                switch change {
                case .change(let properties):
                    for property in properties {
                        if property.name == "gamePoint" {
                            if let value = property.newValue as? String {
                                self.gamePointCallback(value)
                            }
                        }
                        if property.name == "remainingGamePlayPerDay" {
                            if let value = property.newValue as? Int {
                                Constants.maximumGamePlayPerDay = value
                                self.remainingGamePlayPerDayCallback(value)
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
        
    }
    
    func unSubscribeRealmNotification(){
        token?.stop()
    }

    func startSessionIfRequired(){
        ChildSessionManager.sharedInstance.StartUpdatingLocation()
        ChildSessionManager.sharedInstance.startSessionIfRequired()
        
        // Get locations and start Monitoring if Location Service is active
        if let obj = CustomiseSettingsSummary.getCustomiseSettingSummaryObj(), obj.isLocationOptionActive() == true {
            ChildSessionManager.sharedInstance.startLocationMonitoring()
        }else{
            // no location tracking
        }
    }

    // MARK: - Game
    
    func performPlayGame() {
        
        var arr = [ChildSessionManager.childSessionPointStatus.text_play_game_plano_pairs.rawValue,
                   ChildSessionManager.childSessionPointStatus.text_play_game_eyecerxise.rawValue]

        let randomIndex = Int(arc4random_uniform(2))// 0 or 1
        let gameName = arr[randomIndex] // get Game name
        
        viewModel.deductPointForPlayingGame(gameName:gameName) {[weak self] (success) in

            if success {
                                if gameName == ChildSessionManager.childSessionPointStatus.text_play_game_plano_pairs.rawValue {
                                    let vc = UIStoryboard.PairGame()
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                }else{
                                    let vc = UIStoryboard.EyeGame()
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                }
            }else{
                self?.showAlert("Failed to deduct the point.\nPlease try again!")
            }
            
        }
        
    }
    
    // MARK: - Switch to parent
    func performSwitchToParent(password:String) {
        ChildSessionManager.sharedInstance.switchToParentMode()
        self.showParentDashboardLanding()
    }
    
    @IBAction func btnPlayClicked(_ sender: Any) {
        
        if !viewModel.userCanPlayGame() {
            let vc = UIStoryboard.PopupGamePlayed()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)

        }else{
            showCustomDialog()
        }
    }
    
    @IBAction func btnCustomiseClicked(_ sender: Any) {
        let vc = UIStoryboard.CustomiseAvatar()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnPlanoClicked(_ sender: Any) {
    }
    
    @IBAction func btnSwitchToParentClicked(_ sender: Any) {
        showSwitchToParentDialog()
    }

    @IBAction func btnShopClicked(_ sender: Any) {
        showChildShop()
    }
    
    
    func initView(){
        
        // show game point
        if let acp = viewModel.activeChildProfile {
            gamePointCallback(acp.gamePoint)
        }
        
        viewModel.getAllAvatarItems { (list) in
            self.equipExistingItems()
        }
        
        speechBubbleView.isHidden = true
        downArrowShop.isHidden = true
        downArrowCustomise.isHidden = true
        downArrowPlay.isHidden = true
        
        guideViewHolder.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissGuide(gesture:)))
        guideViewHolder.addGestureRecognizer(tap)

//        btnPlay.setTitle(btnPlay.titleLabel!.text!.localized(), for: .normal)
//        btnCustomise.setTitle(btnCustomise.titleLabel!.text!.localized(), for: .normal)
//        btnShop.setTitle(btnShop.titleLabel!.text!.localized(), for: .normal)
        lblPlay.text = lblPlay.text?.localized()
        lblCustomise.text = lblCustomise.text?.localized()
        lblShop.text = lblShop.text?.localized()
        
    }
    
    // MARK: - Guide view
    func showGuide(){
        if let guide = self.guideViewHolder {
            guide.isHidden = false
            guide.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                guide.alpha = 1
            }, completion: nil)
        }
    }
    
    @objc func dismissGuide(gesture:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.guideViewHolder?.alpha = 0
        }) { (complete) in
            self.guideViewHolder?.removeFromSuperview()
            self.startSessionIfRequired()
        }
    }

    func gamePointCallback(_ gamePoint:String){
        self.lblChildPoints.text = "\(gamePoint) pts"
    }
    
    func remainingGamePlayPerDayCallback(_ play:Int){
        btnPlay.isEnabled = viewModel.userCanPlayGame()
        if btnPlay.isEnabled {
            imgPlay.alpha = 1
        }else{
            imgPlay.alpha = 0.5
        }
    }
    
    // MARK: - Child Session Timer
    
    func registerForChildSessionTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(childSessionStarted(_:)), name: Notification.Name(ChildSessionManager.childSessionStartedIdentifier), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimerView(_:)), name: Notification.Name(ChildSessionManager.timerNotificationIdentifier), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEyeCalibrationPopupIfRequiredByNotification(_:)), name: Notification.Name(ChildSessionManager.eyeCalibrationNotiIdentifier), object: nil)
    }
    
    func unRegisterForChildSessionTimer(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(ChildSessionManager.timerNotificationIdentifier), object: nil);
        NotificationCenter.default.removeObserver(self, name: Notification.Name(ChildSessionManager.childSessionStartedIdentifier), object: nil);
        NotificationCenter.default.removeObserver(self, name: Notification.Name(ChildSessionManager.eyeCalibrationNotiIdentifier), object: nil);
    }

    
    @objc func updateTimerView(_ notification:Notification){
        if let value = notification.object as? String {
            // display in Main queue for UI
            DispatchQueue.main.async {
                self.lblChildTimer.text = value
            }
        }
    }
    
    // MARK: - Animations
    
    func animateGameAvatar() {
        
        self.gameAvatarBottomConstraint.constant = 14
        self.avatarHolder.layoutIfNeeded()
        self.gameAvatarBottomConstraint.constant = 30

//        self.gameAvatarBottomConstraint.constant = self.gameAvatarBottomConstraint.constant == 30 ? 14 : 30
        
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse,.repeat,.curveEaseOut], animations: {
            
            self.avatarHolder.layoutIfNeeded()
            
        }) { (completion) in
        }
    }
    
    // MARK: - Popup
    
    func showCustomDialog(animated: Bool = true) {
        
        // Create a custom view controller
        let vc = self.storyboard!.instantiateViewController(withIdentifier: PopupBeforeGameVC.className) as! PopupBeforeGameVC
        
        vc.parentVC = self
        
        // Create the dialog
        let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .bounceUp, tapGestureDismissal: true)
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    func showSwitchToParentDialog(){
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: SwitchToParentVC.className) as! SwitchToParentVC
        
        vc.IsForgotPassword = true
        vc.parentVC = self
        vc.modalPresentationStyle = .overFullScreen
            WoopraTrackingPage().trackEvent(mainMode:"Child Dashboard",pageName:"Child Dashboard",actionTitle:"Switching Child Dashboard to Parent Dashboard Page")
        present(vc, animated: true, completion: nil)
    }
    
    func showChildShop(){
        // bring to parent dashboard
        let vc = UIStoryboard.ChildShop() as! _BaseViewController
        vc.parentVC = self
        navigationController?.pushViewController(vc, animated: true)
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
        self.imgBadge.kf.setImage(with: URL(string: data.image), placeholder: nil, options: [.transition(.fade(0.5))])
        
    }
    func equipHat(_ data:AvatarItem){
        // update to new item
        viewModel.selectedAvatarItem = data
        self.imgHat.kf.setImage(with: URL(string: data.image), placeholder: nil, options: [.transition(.fade(0.5))])
    }
    func equipGlasses(_ data:AvatarItem){
        // update to new item
        viewModel.selectedAvatarItem = data
        self.imgGlasses.kf.setImage(with: URL(string: data.image), placeholder: nil, options: [.transition(.fade(0.5))])
    }
    
    
    // Child session
    
    @objc func childSessionStarted(_ notification:Notification){
        
        // this happen when ChildProgressScore is displayed
        if showEyeCalibrationPopupIfRequired() {
            // if EyeCalibration is show, it's guaranteed to call `showUsingDeviceAtNightIfRequired`
            // so nothing to do here
        }else{
            // if no need to show EyeCalibration, we need to invoke this method here
            ChildSessionManager.sharedInstance.showUsingDeviceAtNightIfRequired()
        }
    }
    
    // MARK: - Eye Calibration
    
    @objc func showEyeCalibrationPopupIfRequiredByNotification(_ noti:Notification){
        _ = showEyeCalibrationPopupIfRequired()
    }
    
    func showEyeCalibrationPopupIfRequired() -> Bool {
        if ChildSessionManager.sharedInstance.shouldShowEyeCalibration() {
            showEyeCalibrationPopup()
            return true
        }else{
            return false
        }
    }
    
    func showEyeCalibrationPopup(){

        if let vc = UIStoryboard.EyeCalibrationPopupShow() as? _BaseViewController {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func startEyeCalibration(){
        showEyeCalibrationVC()
    }

    func showEyeCalibrationVC(){
        
        if let vc = UIStoryboard.EyeCalibration() as? _BaseViewController {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
//        self.videoComponent = INVVideoComponent(
//            atViewController: self,
//            cameraType: .front,
//            withAccess: .video
//        )
//
//        self.videoComponent?.startLivePreview()
    }
    
    func userSkipCalibration(){
        if let vc = UIStoryboard.PopupRedTooClose() as? _BaseViewController {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
 
    func userSkipCalibrationDeductPoint(){
        // deduct point
        ChildSessionManager.sharedInstance.skipEyeCalibration()
        
        // no need to ask agian for today
        ChildSessionManager.sharedInstance.updateEyeCalibrationCount()
        
        // update to server for behaviour skipping
        ChildSessionManager.sharedInstance.updateToServerForBehaviourEyeCalibration(didEyeChecked: false)
        
        // show other popups
        eyeCalibrationProessDone()
    }
    
    func userHoldDeviceFor5SecWithCorrectDistance(){
        
        // save it so that no need to calibrate again in same day
        ChildSessionManager.sharedInstance.updateEyeCalibrationCount()

        // update to server for behaviour skipping
        ChildSessionManager.sharedInstance.updateToServerForBehaviourEyeCalibration(didEyeChecked: true)
        
        if let vc = UIStoryboard.PopupIsTextClear() as? _BaseViewController {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func userIsClearText(){
        // allow to use
        allowToUse()
    }
    
    func userIsNotClearText(){
        if viewModel.shouldRemindToWearGlass() {
            showPopupRedRememberToWear()
        }else{
            showPopupRedTimeToCheck()
        }
    }
    
    func showPopupRedRememberToWear(){
        if let vc = UIStoryboard.PopupRedRememberToWear() as? _BaseViewController {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func showPopupRedTimeToCheck(){
        if let vc = UIStoryboard.PopupRedTimeToCheck() as? _BaseViewController {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func allowToUse(){
        eyeCalibrationProessDone()
    }
    
    func eyeCalibrationProessDone(){
        perform(#selector(showSpeechBubbleIfRquired), with: nil, afterDelay: 1)
    }
    
    // MARK: - SpeechBubble
    
    @objc func showSpeechBubbleIfRquired(){
        if let acp = viewModel.activeChildProfile {
            if var bubbleList = Defaults[.displayedSpeechBubbleList] { // show Random Bubble
                if let _ = bubbleList.index(of: acp.childID){ // found childID so NO need to
                    if !acp.displayedSpeechBubbleForToday {
                        showRandomSpeechBubbles()
                        return
                    }
                }else{
                    isChildFirstTimeHere = true
                    showSpeechBubble() // show First3 Bubbles
                    bubbleList.append(acp.childID) // append childID so it won't display next time
                    Defaults[.displayedSpeechBubbleList] = bubbleList // save
                }
            }else{
                isChildFirstTimeHere = true
                showSpeechBubble() // show First3 Bubbles
                Defaults[.displayedSpeechBubbleList] = [acp.childID] // save
            }
        }
    }
    
    func showSpeechBubble(){
        
        currentSpeechBubbleIndex = 0
        
        speechBubbleGesture = UITapGestureRecognizer(target: self, action: #selector(hideSpeechBubble(_:)))
        speechBubbleView.addGestureRecognizer(speechBubbleGesture!)
        speechBubbleView.isUserInteractionEnabled = true

        showBubble1() // 1st Bubble of 3 Bubbles
        
        animateArrow(view: downArrowShop, constraint: downArrowShopTopConstraint)
        animateArrow(view: downArrowPlay, constraint: downArrowPlayTopConstraint)
        animateArrow(view: downArrowCustomise, constraint: downArrowCustomiseTopConstraint)
    }
    
    @objc func gotoNextSpeech(){
        hideSpeechBubble(UIGestureRecognizer())
    }
    
    @objc func hideSpeechBubble(_ gesture:UIGestureRecognizer){
        currentSpeechBubbleIndex = currentSpeechBubbleIndex+1
        
        fadeOut(view: speechBubbleView)
        fadeOut(view: downArrowPlay)
        fadeOut(view: downArrowShop)
        fadeOut(view: downArrowCustomise)

        if currentSpeechBubbleIndex == 1 {
            perform(#selector(showBubble2), with: nil, afterDelay: 0.6) // 2nd Bubble of 3 Bubbles
        }else if currentSpeechBubbleIndex == 2 {
            perform(#selector(showBubble3), with: nil, afterDelay: 0.6) // 3rd Bubble of 3 Bubbles
        }else{
            initial3BubblesEnded()
        }
    }
    
    func initial3BubblesEnded(){
        // clear bubbles
        resetSpeechBubbleTimer()
        currentSpeechBubbleIndex = 0
        if let tap = speechBubbleGesture {
            speechBubbleView.removeGestureRecognizer(tap)
        }
        
        // after 3 Bubbles, follow by Random bubbles
        self.perform(#selector(showRandomSpeechBubbles), with: nil, afterDelay: 1)
    }
    
    func resetSpeechBubbleTimer(){
        if let timer = speechBubbleTimer {
            timer.invalidate()
        }
        speechBubbleTimer = nil
    }
    
    func showBubble1(){
        speechBubbleText.text = "Hi! Follow my prompts and earn points to unlock prizes in the plano shop.".localized()
        downArrowPlay.isHidden = true
        downArrowCustomise.isHidden = true
        fadeIn(view: speechBubbleView)
        fadeIn(view: downArrowShop)
        
        resetSpeechBubbleTimer()
        speechBubbleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(gotoNextSpeech), userInfo: nil, repeats: false)

    }
    
    @objc func showBubble2(){
        speechBubbleText.text = "You can customise me and play games to earn more points.".localized()
        downArrowShop.isHidden = true
        fadeIn(view: speechBubbleView)
        fadeIn(view: downArrowPlay)
        fadeIn(view: downArrowCustomise)
        
        resetSpeechBubbleTimer()
        speechBubbleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(gotoNextSpeech), userInfo: nil, repeats: false)

    }
    
    @objc func showBubble3(){
        speechBubbleText.text = "Click the device home button and use as normal. But always remember to follow my prompts!".localized()
        downArrowShop.isHidden = true
        downArrowPlay.isHidden = true
        downArrowCustomise.isHidden = true
        fadeIn(view: speechBubbleView)
        
        resetSpeechBubbleTimer()
        speechBubbleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(gotoNextSpeech), userInfo: nil, repeats: false)

    }
    
    func fadeIn(view:UIView){
        view.isHidden = false
        view.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            view.alpha = 1
        }) { (completed) in
            //
        }
    }
    func fadeOut(view:UIView){
        UIView.animate(withDuration: 0.4, animations: {
            view.alpha = 0
        }) { (completed) in
            //
        }
    }
    func animateArrow(view:UIView, constraint:NSLayoutConstraint){
        constraint.constant = -50
        view.superview?.layoutIfNeeded()
        constraint.constant = -30
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.autoreverse,.repeat], animations: { 
            view.superview?.layoutIfNeeded()
        }) { (completed) in
            //
        }
    }
    
    @objc func showRandomSpeechBubbles(){
        let msgs = [
            "Keep the device 30cm to 40cm from your face.".localized(),
            "After 35 minutes, take a break.".localized(),
            "Have you been outdoors today?".localized(),
            "If you wear glasses, don’t forget to put them on.".localized(),
            "Exercise your eyes by looking far into the distance.".localized(),
            "Use the device in bright areas.".localized(),
            "You and your device need rest at night time.".localized(),
            "Check the plano shop to see what you’ve unlocked.".localized(),
            "Need a change? Customise me!".localized()
        ]
        
        let random = Int(arc4random_uniform(UInt32(msgs.count-1)))
        let randomMsg = msgs[random]
        
        speechBubbleText.text = randomMsg
        fadeIn(view: speechBubbleView)
        
        downArrowPlay.isHidden = true
        downArrowCustomise.isHidden = true
        downArrowShop.isHidden = true
        
        speechBubbleGesture = UITapGestureRecognizer(target: self, action: #selector(hideRandomSpeechBubbles(_:)))
        speechBubbleView.addGestureRecognizer(speechBubbleGesture!)

        speechBubbleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hideRandomSpeechBubbles), userInfo: nil, repeats: false)
        
        if let acp = viewModel.activeChildProfile {
            acp.updateDisplayedSpeechBubbleForToday(true)
        }
    }
    
    @objc func hideRandomSpeechBubbles(_ tap:UIGestureRecognizer){
        resetSpeechBubbleTimer()
        fadeOut(view: speechBubbleView)
        speechBubbleEnded()
    }
    
    func speechBubbleEnded(){
        
        // Show Child Progress if *NOT* first time here
        if !isChildFirstTimeHere {
            //
        }else{
            // if no need to show ChildProgressScore, we need to invoke DeviceAtNight manually
            ChildSessionManager.sharedInstance.showUsingDeviceAtNightIfRequired()
        }
    }
}
