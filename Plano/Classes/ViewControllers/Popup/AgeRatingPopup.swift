//
//  AgeRatingPopup.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PopupDialog
import RealmSwift

protocol AgeRatingDelegate: class {
    func didRecieveAppRatingData(data: AppRatingMDM)
}

class AgeRatingPopup: _BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    override var analyticsScreenName:String? {
        get {
            return "blockapp"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "blockapp"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    var dataList:Results<AppRatingMDM>?
    
    var selectedObj:AppRatingMDM?
    
    let realm =  try! Realm()

    weak var delegate: AgeRatingDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = realm.objects(AppRatingMDM.self)
        
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Auto highlight selected object
        if let so = selectedObj, let dataList = dataList {
            if let index = dataList.index(of: so) {
                let cellIndex:IndexPath = IndexPath(row: index, section: 0)
                self.tableView.selectRow(at: cellIndex, animated: false, scrollPosition: .middle)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationTitleFont = FontBook.Bold.of(size: 16)
        let whiteColor = UIColor.white
        
        self.navigationItem.setLeftBarButton(showBackBtn(), animated: false)
        
        UIApplication.shared.statusBarStyle = .default
        
        if let nav = navigationController {
            nav.navigationBar.barTintColor = Color.Cyan.instance()
            nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: navigationTitleFont, NSAttributedString.Key.foregroundColor.rawValue: whiteColor])
        }
        
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AgeRatingCell = tableView.dequeueReusableCell(withIdentifier: AgeRatingCell.className) as! AgeRatingCell
        if let dl = dataList {
            cell.config(data: dl[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let del = self.delegate{
            
            selectedObj = self.dataList![indexPath.row]
            
            // pass to other page
            del.didRecieveAppRatingData(data:selectedObj!)
            
            // mark smaller ratings
            try! realm.write {
                
                // clear all selection first
                realm.objects(AppRatingMDM.self).setValue(0, forKeyPath: "isSelected")
                
                // select all rating below
                realm.objects(AppRatingMDM.self).filter("RatingID <= %@",selectedObj!.RatingID).setValue(1, forKeyPath: "isSelected")
            }
            
            tableView.reloadData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
