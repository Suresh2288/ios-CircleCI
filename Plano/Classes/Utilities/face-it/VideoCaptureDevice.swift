//
//  VideoCaptureDevice.swift
//  face-it
//
//  Created by Derek Andre on 4/25/16.
//  Copyright © 2016 Derek Andre. All rights reserved.
//

import Foundation
import AVFoundation
import Crashlytics

class VideoCaptureDevice {
    
    enum VideoCaptureDeviceError:Error {
        case DeviceMissing
    }
    
    static func create() -> AVCaptureDevice {
        var device: AVCaptureDevice?
        
        AVCaptureDevice.devices(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))).forEach { videoDevice in
            if ((videoDevice as AnyObject).position == AVCaptureDevice.Position.front) {
                device = videoDevice as? AVCaptureDevice
            }
        }
        
        if (device == nil) {
            device = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        }
        
        if (device == nil){
            Crashlytics.sharedInstance().recordError(VideoCaptureDeviceError.DeviceMissing)
        }
        
        return device!
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
