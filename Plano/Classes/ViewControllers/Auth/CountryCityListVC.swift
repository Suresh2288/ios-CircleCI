//
//  CountryCityListVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PopupDialog
import RealmSwift

protocol CountryCityDataDelegate: class {
    func didRecieveCountryData(data: CountryData)
    func didRecieveCityData(data: CityData)
}

class CountryCityListVC: _BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataList:[AnyObject] = [AnyObject]()
    var countryList:Results<CountryData>?
    var cityList:Results<CityData>?

    var selectedObj:AnyObject?
    var selectedCountryObj:CountryData?
    var selectedCityObj:CityData?
    
    var viewModel = CountryCityViewModel()
    weak var delegate: CountryCityDataDelegate?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtFAQSearch : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup TableView
        
        tableView.estimatedRowHeight = 54
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.reloadData()
        if let countryList = countryList, let cityList = cityList {
            tableView.isHidden = countryList.count < 1 && cityList.count < 1
        }
        
        // Auto highlight selected object
        
        if let so = selectedCountryObj, let countryList = countryList {
            if let index = countryList.index(of: so) {
                let cellIndex:IndexPath = IndexPath(row: index, section: 0)
                self.tableView.selectRow(at: cellIndex, animated: false, scrollPosition: .middle)
            }
        }
        if let so = selectedCityObj, let cityList = cityList{
            if let index = cityList.index(of: so) {
                let cellIndex:IndexPath = IndexPath(row: index, section: 0)
                self.tableView.selectRow(at: cellIndex, animated: false, scrollPosition: .middle)
            }
        }
        
        txtFAQSearch.tintColor = Color.Cyan.instance()
        txtFAQSearch.delegate = self
        txtFAQSearch.autocorrectionType = .no
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = countryList{
            title = "Countries".localized()
        }
        else if let _ = cityList{
            title = "Cities".localized()
        }

        setUpNavBar()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        setUpNavBarForExit()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK:- Nav Setup

    func setUpNavBar(){
        let navigationTitleFont = FontBook.Bold.of(size: 16)
        let color = UIColor.black
        UIApplication.shared.statusBarStyle = .default
        setUpNavBarWithParams(navigationTitleFont,color)
    }
    
    func setUpNavBarForExit(){
        UIApplication.shared.statusBarStyle = .lightContent
        let navigationTitleFont = FontBook.Bold.of(size: 16)
        let color = UIColor.white
        setUpNavBarWithParams(navigationTitleFont,color)
    }
    
    func setUpNavBarWithParams(_ navigationTitleFont:UIFont, _ color:UIColor){
        self.navigationItem.setLeftBarButton(showBackBtn(), animated: false)
        
        
        if let nav = navigationController {
            nav.navigationBar.barTintColor = Color.Cyan.instance()
            nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: navigationTitleFont, NSAttributedString.Key.foregroundColor.rawValue: color])
        }
    }
    
    
    //MARK:- UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let countryList = countryList {
            return countryList.count
        }else if let cityList = cityList {
            return cityList.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CountryCityCell = tableView.dequeueReusableCell(withIdentifier: CountryCityCell.className) as! CountryCityCell
        if let countryList = countryList
        {
            cell.configCountry(data: countryList[indexPath.row])
        }else if let cityList = cityList {
            cell.configCity(data: cityList[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let del = self.delegate{
            if let countryList = countryList{
                del.didRecieveCountryData(data: countryList[indexPath.row])
            }
            else if let cityList = cityList{
                del.didRecieveCityData(data: cityList[indexPath.row])
            }
        }
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }
        
        dismissKeyboard()
    }
    
    func dismissKeyboard(){
        txtFAQSearch.resignFirstResponder()
    }
    
    func manageSearchText(searchText:String){
        if searchText.isEmpty
        {
            if let _ = countryList {
                countryList = CountryData.getAllObjects()
            }else if let _ = cityList {
                cityList = CityData.getAllObjects()
            }
        }
        else{
            if let _ = countryList {
                countryList = CountryData.getBySearchText(searchText: searchText)
            }else if let _ = cityList {
                cityList = CityData.getBySearchText(searchText: searchText)
            }
        }
        
        UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { () -> Void in
            
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            
        }, completion: nil)
    }
}

extension CountryCityListVC : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let searchText = txt.replacingCharacters(in: newRange, with: string).trimmingCharacters(in: .whitespaces)
            
            self.manageSearchText(searchText: searchText)

        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.manageSearchText(searchText: "")
        return true
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
