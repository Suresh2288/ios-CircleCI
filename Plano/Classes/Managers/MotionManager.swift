//
//  MotionManager.swift
//  MotionMonitor
//
//  Created by Paing Pyi on 10/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import CoreMotion

protocol MotionManagerDelegate: class {
    func didRecieveMotionUpdates(attitude: CMAttitude)
}

class MotionManager {
    
    weak var delegate: MotionManagerDelegate?

    fileprivate let motionManager = CMMotionManager()
    fileprivate let queue = OperationQueue()
    
    func startDeviceMotionUpdates(){
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { (motions, error) in
                
                guard let motion = motions else {
                    return
                }
                
                let attitude = motion.attitude
               
                if let del = self.delegate {
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            del.didRecieveMotionUpdates(attitude: attitude)
                        }
                    }
                }
                
            })
        }
    }
    func stopDeviceMotionUpdates(){
        motionManager.stopDeviceMotionUpdates()
    }
    func degrees(_ x:Double) -> Double {
        return 180 * x / Double.pi
    }
}

