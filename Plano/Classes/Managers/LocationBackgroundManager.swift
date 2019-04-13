//
//  LocationBackgroundManager.swift
//  Plano
//
//  Created by Toe Wai Aung on 6/15/17.
//  Copyright © 2017 Codigo. All rights reserved.
//
import UIKit
import Foundation
import RealmSwift
import CoreLocation
import PopupDialog
import CoreLocation
import PopupDialog
import Localize_Swift

class LocationBackgroundManager {
    
    var customiseSettings : CustomiseSettings!
    var locationSettingsdata : Results<LocationSettingsData>!
    var viewModel = CustomiseSettingsViewModel()
    var geotifications: [LocationSettingsData] = []
    var locationManager = CLLocationManager()
    var locationManagerDelegate:CLLocationManagerDelegate?
    
    var newPlaceCoordinate = CLLocationCoordinate2D()

    
    static let sharedInstance = LocationBackgroundManager() // Singleton init
    
    //MARK: - StartMonitoring
    func startMonitoring(_ childID:Int?){
        var active : Int = 0
        if locationSettingsdata == nil{
            getCustomiseSettings(childID)
            return
        }
        
        locationManager.delegate = locationManagerDelegate

        // then add
        for i in 0..<self.locationSettingsdata.count{
            active = self.locationSettingsdata[i].active.toIntFlag()!
            if(active == 1){
                self.startMonitoring(geotification: locationSettingsdata[i])
            }
        }
    }
    
    //MAKR:- RequestAPI Data
    func getCustomiseSettings(_ childID:Int?){

        viewModel.getChildCustomiseSettings(success: { 
            // Getting objects
            self.locationSettingsdata = LocationSettingsData.getAllActiveLocationSettings()

            self.startMonitoring(nil)
            
        }) { (errorMessage) in
            
        }
    }
    
    func startMonitoring(geotification: LocationSettingsData) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            self.alertLocationSettingOpen("Error".localized(),"Geofencing is not supported on this device!".localized())
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            self.alertLocationSettingOpen("Background Location Access Disabled".localized(),"In order to be notified about child device usage, please open this app's settings and set location access to 'Always'.".localized())
        }
        // 3
        let region = self.region(withGeotification: geotification)
        // 4
        locationManager.startMonitoring(for: region)
    }
    
    //MARK:- RegionDataSet
    func region(withGeotification geotification: LocationSettingsData) -> CLCircularRegion {
        
        if let lat = Double(geotification.latitude), let lng = Double(geotification.longitude), let radius = Double(geotification.zoomsize){
            
            let newRadius = radius + Double(Constants.outsideSafeZoneBuffer) // 350m becomes 400 because Subha wants to have 50m buffer
            
            let newCoord : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
            let region = CLCircularRegion(center: newCoord, radius: newRadius, identifier: geotification.descriptionText)
            
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            return region
        }
        
        return CLCircularRegion()
    }
    
   //MARK:- StopMonitoring
    func stopMonitoring(){
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        locationSettingsdata = nil
    }
    
   //MARK:- ALertSetting
    func alertLocationSettingOpen(_ Title: String,_ Message: String){
        let alertController = UIAlertController(
            title: Title as String ,
            message: Message,
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Enable".localized(), style: .default) { (action) in
            if let url = NSURL(string:UIApplication.openSettingsURLString) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
        alertController.addAction(openAction)
        
        if let vc = UIViewController.topViewController() {            
            vc.present(alertController, animated: false, completion: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
