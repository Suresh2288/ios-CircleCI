 //
//  EyeDegreeListVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PopupDialog
import RealmSwift

protocol EyeDegreeListDelegate: class {
    func didRecieveEyeDegreeData(data: ListEyeDegrees)
}

class EyeDegreeListVC: _BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataList:Results<ListEyeDegrees>?

    var selectedObj:ListEyeDegrees?

    weak var delegate: EyeDegreeListDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        dataList = realm.objects(ListEyeDegrees.self)
        
        tableView.estimatedRowHeight = 54
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
        
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
        let cell:EyeDegreeCell = tableView.dequeueReusableCell(withIdentifier: EyeDegreeCell.className) as! EyeDegreeCell
        cell.config(data: dataList![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let del = self.delegate{
            del.didRecieveEyeDegreeData(data: self.dataList![indexPath.row])
        }
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
