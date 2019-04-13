//
//  VideoCaptureController.swift
//  face-it
//
//  Created by Derek Andre on 4/21/16.
//  Copyright © 2016 Derek Andre. All rights reserved.
//

import Foundation
import UIKit

class VideoCaptureController: UIViewController {
    var videoCapture: VideoCapture?
    @IBOutlet weak var cameraViewHolder: UIView!
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblAniTimer: UILabel!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        videoCapture = VideoCapture()
        registerNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCapturing()
    }
    
    override func didReceiveMemoryWarning() {
        stopCapturing()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        stopCapturing()
    }
    @IBAction func touchDown(_ sender: AnyObject) {
        let button = sender as! UIButton
        button.setTitle("Stop", for: UIControl.State())
        
//        startCapturing()
    }
    
    @IBAction func touchUp(_ sender: AnyObject) {
        let button = sender as! UIButton
        button.setTitle("Start", for: UIControl.State())
        
//        stopCapturing()
    }
    
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateDistance), name: NSNotification.Name(rawValue: "updateDistance"), object: nil)

    }
    
    @objc func updateDistance(notification: NSNotification){
        if let obj = notification.object as? CGFloat {
            let float = self.withToDistance(width: obj)
            lblDistance.text = String(format: "%.0f cm",float)
            
            if float < 29 {
                lblStatus.text = "You are too close to your device!"
            }else{
                lblStatus.text = "Well done!"
            }
        }else{
            lblDistance.text = "-"
            lblStatus.text = "You are too close or too far from your device!"
        }
    }
    
    func withToDistance(width:CGFloat) -> CGFloat {
        // 373 => 22 cm
        // 288 => 30 cm
        return (373/width)*22
    }
}
