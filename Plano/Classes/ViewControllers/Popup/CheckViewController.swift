//
//  CheckViewController.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/29/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit
import GoogleMaps
import Device

class CheckViewController: _BaseViewController {
    var str1 : NSString = ""
    var str2 : NSString = ""
    var GMSPosition : GMSCameraPosition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBarWithAttributes(navtitle: "Location", setStatusBarStyle: .lightContent , isTransparent: false , tintColor: Color.Cyan.instance(), titleColor: UIColor.white , titleFont: FontBook.Bold.of(size: 16))//       self.userLocationMapDelegate = true
        // Do any additional setup after loading the view.
        if let nav = navigationController {
            nav.setNavigationBarHidden(false, animated: true)
        }
        
    }
    func didPeriodData(_ SchedulePeriod:String,_ FromTime:String, _ ToTime:String,_ ScheduleTitle:String){
        print("UserData ->\n SchedulePeriod ->\(SchedulePeriod)\n FromTime ->\(FromTime)\n ToTime ->\(ToTime)\n ScheduleTitle ->\(ScheduleTitle)\n")
    }
    @IBAction func btnPeriodClicked(_ sender: Any) {
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func didRecieveMapData(_ boundaryName: String, _ placeID: String, _ userMapPosition: CLLocationCoordinate2D, _ Address: String,_ AddressTitle:String, _ description: String, _ boundarySize: String) {
        print("UserData ->\n Description ->\(description)\n BoundaryName->\(boundaryName)\n Latitude ->\(userMapPosition.latitude)\n Longitude->\(userMapPosition.longitude)\n PlaceID\(placeID)\n Address->\(Address)\n AddressTitle->\(AddressTitle)\n Boundarysize->\(boundarySize)\n")
    }
    //   func diduserPeriodDat
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap" {
            let sendingVC: ChildrenLocationVC = segue.destination as! ChildrenLocationVC
            sendingVC.mapdelegate = self
        }
        
        if segue.identifier == "ShowPeriod" {
            let sendingVC: PopAddSchedulePeriodVC = segue.destination as! PopAddSchedulePeriodVC
            sendingVC.periodelegate = self
        }
        
    }
}

extension CheckViewController : userLocationMapDelegate{
    internal func didUpdateMapData(_ locationID: Int, _ boundaryName: String, _ placeID: String, _ userMapPosition: CLLocationCoordinate2D, _ Address: String, _ AddressTitle: String, _ description: String, _ boundarySize: String) {
        
    }
}

extension CheckViewController : userperiodDelegate{
    internal func didDataUpdated(_ ScheduleID: Int, _ SchedulePeriod: String, _ FromTime: String, _ ToTime: String, _ ScheduleTitle: String) {
        
    }

}

