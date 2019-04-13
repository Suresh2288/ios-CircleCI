//
//  EyeCalibrationVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import AVFoundation
import PopupDialog
import CoreMotion

class EyeCalibrationVC : _BaseViewController {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblStatusBg: UIView!
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var lblPostureStatus: UILabel!
    @IBOutlet weak var lblPostureStatusBg: UIView!
    @IBOutlet weak var imgPostureStatus: UIImageView!
    
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblAniTimer: UILabel!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var cameraViewHolder: UIView!
    @IBOutlet weak var lblDescription: UILabel!
   
    
    var videoCapture: VideoCapture?
    var motionManager: MotionManager = MotionManager()

    var shouldTracking:Bool = true
    var timer:Timer?
    var timerCounter:Int = 5
    var currentDistance:String = ""
    
    var distanceCorrect = false
    var distanceCaliFinished = false
    var postureCorrect = false
    var postureCaliFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoCapture = VideoCapture()
        lblAniTimer.alpha = 0
        registerDistanceNotification()
        lblStatus.text = "You are too close or far from your device!".localized()
        
        if !requirePostureCalibration() {
            lblDescription.text = "Hold your phone 30cm or more from your face for 5 seconds.".localized()
        }
        
        /* Disable this to start Posture */
//        postureCorrect = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCapturing()
    }
    
    override func didReceiveMemoryWarning() {
        stopCapturing()
    }
    
    func requirePostureCalibration() -> Bool {
        
        if let obj = CustomiseSettingsSummary.getCustomiseSettingSummaryObj(), obj.shouldCalibratePosture() == true {
            // ask Posture Calibration
            return true
        }else{
            // no Posture Calibration
            return false
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        eyeCalibrationEnded()
        self.dismiss(animated: true) { 
            // quit
            if let parent = self.parentVC as? ChildDashboardVC {
                parent.perform(#selector(parent.userSkipCalibrationDeductPoint))
            }
        }
    }
    
    func eyeCalibrationEnded(){
        stopCapturing()
        clearTimer()
    }
    
    func animateTimer(_ counter:Int){
        lblAniTimer.text = "\(counter)"
        
        self.lblAniTimer.transform = CGAffineTransform(scaleX: 3, y: 3)
        self.lblAniTimer.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.lblAniTimer.transform = CGAffineTransform.identity
            self.lblAniTimer.alpha = 1
            
        }) { (complete) in
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.lblAniTimer.alpha = 0
            })
            
        }
    }
    
    // MARK: - Calibration Timer
    
    func startTimerIfRequired(){
        if timer != nil {
            return
        }
        
        /* Enable this to start Posture */
//         if distanceCorrect && postureCorrect {
        /* Disable this to start Posture */
        if distanceCorrect || postureCorrect {
            startCaliTimer()
        }
    }
    
    func startCaliTimer(){
        clearTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkCaliStatus), userInfo: nil, repeats: true)
    }
    
    @objc func checkCaliStatus(timer:Timer){
        animateTimer(timerCounter)
        
        timerCounter = max(0,timerCounter - 1)
        log.debug("Cali timer : \(self.timerCounter)")
        
        if(timerCounter < 1 && distanceCaliFinished){
            postureCaliFinished = true
            clearTimer()
            stopTracking()
            
            perform(#selector(showCompletePopup), with: nil, afterDelay: 1)
            
        }else if timerCounter < 1 { // time's up
            distanceTrackingSuccess()
            clearTimer()
            
            if requirePostureCalibration() {
                startPosture() // continue and check Posture
            }else{
                stopTracking() // that's all. show success popup
                perform(#selector(showCompletePopup), with: nil, afterDelay: 1)
            }
        }
    }
    
    
    func clearTimer(){
        if let tm = timer {
            tm.invalidate()
        }
        timer = nil
        timerCounter = 5
    }
    
    func userUnderCorrectDistance(){
        distanceCorrect = true
        if shouldTracking {
            startTimerIfRequired()
        }
    }
    
    func userUnderIncorrectDistance(){
        distanceCorrect = false
        if shouldTracking {
            clearTimer()
        }
    }
    
    func stopTracking(){
        shouldTracking = false
        motionManager.stopDeviceMotionUpdates()
    }
    
    @objc func showCompletePopup(timer:Timer){
        
        // Prepare the popup
        let title = "Calibration Success".localized()
        let message = "You have now set an optimal distance and has the correct posture while using the phone.\nKeep it up!".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let btn1 = DefaultButton(title: "OK".localized()) {

            self.eyeCalibrationEnded()
            
            ChildSessionManager.sharedInstance.updateToServerForEyeCalibration(didEyeChecked: true, eyeDistance: self.currentDistance)
            
            self.dismiss(animated: true) {
                if let parent = self.parentVC as? ChildDashboardVC {
                    parent.perform(#selector(parent.userHoldDeviceFor5SecWithCorrectDistance))
                }
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
        
        btn1.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([btn1])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)

    }
    
    // - MARK: Calibration
    
    
    func startCapturing() {
        do {
            try videoCapture!.startCapturing(self.cameraViewHolder)
        }
        catch {
            // Error
        }
    }
    
    
    func stopCapturing() {
        videoCapture!.stopCapturing()
    }
    
    func registerDistanceNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateDistance), name: NSNotification.Name(rawValue: "updateDistance"), object: nil)
    }
    func unRegisterDistanceNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateDistance"), object: nil)
    }
    
    
    @objc func updateDistance(notification: NSNotification){
        if let obj = notification.object as? CGFloat {
            let float = self.withToDistance(width: obj)
            currentDistance = String(format: "%.0f",float)
            
            lblDistance.text = "\(currentDistance) cm"
            
            if float < 29 {
                lblStatus.text = "You are too close to your device!".localized()
                imgStatus.image = UIImage(named: "iconCross")
                lblStatusBg.backgroundColor = UIColor(hexString: "ec533a", alpha: 0.5)
                userUnderIncorrectDistance()
            }else{
                lblStatus.text = "Distance is just right!".localized()
                imgStatus.image = UIImage(named: "iconTick")
                lblStatusBg.backgroundColor = UIColor(hexString: "68ced9", alpha: 0.5)
                userUnderCorrectDistance()
            }
        }else{
            currentDistance = ""
            lblDistance.text = "-"
            lblStatus.text = "You are too close or far from your device!".localized()
            imgStatus.image = UIImage(named: "iconCross")
            lblStatusBg.backgroundColor = UIColor(hexString: "ec533a", alpha: 0.5)
            userUnderIncorrectDistance()
        }
    }
    
    func withToDistance(width:CGFloat) -> CGFloat {
        // 373 => 22 cm
        // 288 => 30 cm
        return (373/width)*22
    }
    
    func distanceTrackingSuccess(){
        unRegisterDistanceNotification()
        lblStatusBg.isHidden = true
        distanceCaliFinished = true
    }
    
    // MARK: Update Posture 
    
    func startPosture(){
        /* Enable this to start Posture Tracking */
        ///*
        motionManager = MotionManager()
        motionManager.delegate = self
        motionManager.startDeviceMotionUpdates()
        // */
        
        lblStatusBg.isHidden = true
        lblPostureStatusBg.isHidden = false
    }
    
    func userUnderCorrectPosture(){
        postureCorrect = true
        if shouldTracking {
            startTimerIfRequired()
        }
    }
    func userUnderIncorrectPosture(){
        postureCorrect = false
        if shouldTracking {
            clearTimer()
        }
    }

}

extension EyeCalibrationVC : MotionManagerDelegate {
    func didRecieveMotionUpdates(attitude: CMAttitude) {
        log.debug("Pitch: \(attitude.pitch) - Yaw: \(attitude.yaw)")
//        let minimumPitch:Double = 0.35
//        let maximumPitch:Double = 1.4

        let minimumPitch:Double = 0.4
        let maximumPitch:Double = 1.6

        let maxYawFaceToward:Double = 3.0
        let minYawFaceToSide:Double = -1.6
        
        //// Pitch >>> 0.4  (\) >  1.3 (/)
        //// Yaw   >>> 0.03 (\) > -2.7 (/)

        //// Pitch >>> 0.4  (\) >  1.3 (/)
        //// Yaw   >>> 0.03 (\) > -2.7 (/)

        //// Pitch                  >>> 0.4 __   1.5 |   1.2 /   0 __
        //// Yaw (face to side)     >>> -0.2 __   -0.2|  -1.5 /  -1.9 __
        //// Yaw (face toward face) >>> -0.39 __   2.9|  2.6 /  2.77 __

        var isYawWithinRange = false
        if attitude.yaw >= 0 { // positive value
            isYawWithinRange = attitude.yaw <= maxYawFaceToward
        }else{ // negative value
            isYawWithinRange = attitude.yaw >= minYawFaceToSide
        }
        
//        if attitude.pitch >= minimumPitch && attitude.pitch <= maximumPitch && attitude.yaw > maxYaw {
        if attitude.pitch >= minimumPitch && attitude.pitch <= maximumPitch && isYawWithinRange {
            lblPostureStatus.text = "Good posture!".localized()
            imgPostureStatus.image = UIImage(named: "iconTick")
            lblPostureStatusBg.backgroundColor = UIColor(hexString: "68ced9", alpha: 0.5)
            userUnderCorrectPosture()
        }else{
            lblPostureStatus.text = "Sit up straight to correct your posture".localized()
            imgPostureStatus.image = UIImage(named: "iconCross")
            lblPostureStatusBg.backgroundColor = UIColor(hexString: "ec533a", alpha: 0.5)
            userUnderIncorrectPosture()
        }
    }
}
