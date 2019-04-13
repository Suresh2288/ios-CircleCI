//
//  ChildShopVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/10/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift
import Device
import SwiftyUserDefaults

class ChildShopVC: _BaseViewController {
    
    @IBOutlet weak var colItemList : UICollectionView!
    @IBOutlet weak var lblCategory : UILabel!
    @IBOutlet weak var lblSort : UILabel!
    @IBOutlet weak var btnCategory : UIButton!
    @IBOutlet weak var btnSort : UIButton!
    
    // iPad
    @IBOutlet weak var sortContainerHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var sortItemOneSpacingConstraint : NSLayoutConstraint!
    @IBOutlet weak var sortItemTwoSpacingConstraint : NSLayoutConstraint!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var viewModel = ChildShopViewModel()
    var productList : Results<ChildProductsList>!
    let placeholderImage = UIImage()
    var selectedSorting = ""
    var selectedCategoryID = ""
    var categoriesList : Results<AllCategories>!
    var categories : [String] = []
    var categoriesID : [String] = []
    var selectedProductID : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if parentVC != nil {
            
            removeLeftMenuGesture()
            
            setUpNavBarWithAttributes(navtitle: "plano shop", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }else{
            
            setupMenuNavBarWithAttributes(navtitle: "plano shop", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
            
        }
        
        // iPad
        if Device.size() >= .screen7_9Inch{
            sortContainerHeightConstraint.constant = 60
            sortItemOneSpacingConstraint.constant = 45
            sortItemTwoSpacingConstraint.constant = 45
        }
        
        registerShopCells()
        setUpLayout()
        viewModelCallBack()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Child Shop Page",pageName:"Child Shop Page",actionTitle:"Child Shop")

        if parentVC != nil {
            if let nav = navigationController {
                nav.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.getAllCategories(success: { 
            
            self.categoriesList = AllCategories.getAllCategoriesForChild()
            
            self.categories.removeAll()
            self.categoriesID.removeAll()
            
            for i in 0..<self.categoriesList.count{
                self.categories.append(self.categoriesList[i].CategoryName)
                self.categoriesID.append(self.categoriesList[i].CategoryID)
            }
            
            // We need to add default cateogory "All" because server side no need to add that
            self.categories.insert("All", at: 0)
            self.categoriesID.insert("", at: 0)
            
            self.viewModel.getAllProductForChild(success: { 
                
                // This is the initail response from the api without doing any sorting option in the product list.
                self.productList = ChildProductsList.getAllProducts()
                
                UIView.transition(with: self.colItemList, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.refreshProductList()
                    
                }, completion: nil)
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
            }
            
            
        }) { (errorMessage) in
            self.showAlert(errorMessage)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func registerShopCells() {
        
        colItemList.register(UINib(nibName : "ShopItemCell", bundle : nil), forCellWithReuseIdentifier: "ShopItemCell")
        
    }
    
    func setUpLayout() {
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // Setting layout for banner
        if Device.size() == .screen3_5Inch {
            
            layout.sectionInset = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            layout.itemSize = CGSize(width: (screenWidth/2)-20, height: (screenHeight/2)-20)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 1
            
        }else if Device.size() == .screen4Inch{
            
            layout.sectionInset = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            layout.itemSize = CGSize(width: (screenWidth/2)-20, height: (screenHeight/2)-70)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 1
            
        }else if Device.size() <= .screen5_5Inch{
            
            layout.sectionInset = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            layout.itemSize = CGSize(width: (screenWidth/2)-20, height: (screenHeight/2)-87)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 1
            
        }else if Device.size() == .screen5_8Inch{
            
            layout.sectionInset = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            layout.itemSize = CGSize(width: (screenWidth/2)-20, height: (screenHeight/2)-137)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 1
            
        }else{
            // iPad
            
            layout.sectionInset = UIEdgeInsets(top: 25, left: 115, bottom: 25, right: 115)
            layout.itemSize = CGSize(width: (screenWidth/3)-85, height: (screenHeight/3)-90)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            
        }
        
        colItemList.collectionViewLayout = layout
        colItemList.isScrollEnabled = true
        
    }
    
    func setUpCategoryPicker(){
        let categoryAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<categories.count{
            let alertAction = UIAlertAction(title: categories[i], style: .default, handler: { action in
                self.lblCategory.text = self.categories[i].localized()
                self.productList = ChildProductsList.getAllProductsByCategoryID(category: self.categoriesID[i],sort: self.selectedSorting)
                self.refreshProductList()
                self.selectedCategoryID = self.categoriesID[i]
            })
            categoryAlert.addAction(alertAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
        })
        categoryAlert.addAction(cancelAction)

        if let popOver = categoryAlert.popoverPresentationController {
            let anchorRect = CGRect(x: 0, y: 0, width: btnCategory.frame.size.width, height: btnCategory.frame.size.height)
            popOver.sourceRect = anchorRect
            popOver.sourceView = btnCategory // works for both iPhone & iPad
        }
        
        self.present(categoryAlert, animated: true, completion: nil)
    }
    
    func setUpSortPicker(){
        let sortByAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let aToZ_Action = UIAlertAction(title: "Alphabetical (A-Z)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Alphabetical (A-Z)".localized()
            self.productList = ChildProductsList.getSortedAtoZProducts(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "AEC"
        })
        let zToA_Action = UIAlertAction(title: "Alphabetical (Z-A)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Alphabetical (Z-A)".localized()
            self.productList = ChildProductsList.getSortedZtoAProducts(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "DEC"
        })
        let pointsHightoLow_Action = UIAlertAction(title: "Points (high to low)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Points (high to low)".localized()
            self.productList = ChildProductsList.getProductsCostHighToLow(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "DEC"
        })
        let pointsLowtoHigh_Action = UIAlertAction(title: "Points (low to high)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Points (low to high)".localized()
            self.productList = ChildProductsList.getProductsCostLowToHigh(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "AEC"
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
        })
        
        sortByAlert.addAction(aToZ_Action)
        sortByAlert.addAction(zToA_Action)
        sortByAlert.addAction(pointsHightoLow_Action)
        sortByAlert.addAction(pointsLowtoHigh_Action)
        sortByAlert.addAction(cancelAction)
        
        if let popOver = sortByAlert.popoverPresentationController {
            let anchorRect = CGRect(x: 0, y: 0, width: btnSort.frame.size.width, height: btnSort.frame.size.height)
            popOver.sourceRect = anchorRect
            popOver.sourceView = btnSort // works for both iPhone & iPad
        }
        
        self.present(sortByAlert, animated: true, completion: nil)
    }
    
    func viewModelCallBack(){
                
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
    
    func refreshProductList(){
        colItemList.reloadData()
    }
    
    @IBAction func btnCategoryTapped(_ sender : UIButton){
        setUpCategoryPicker()
    }
    
    @IBAction func btnSortTapped(_ sender : UIButton){
        setUpSortPicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChildShopVC : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if productList == nil{
            return 0
        }else{
            return productList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopItemCell", for: indexPath) as! ShopItemCell
        
        let products = productList[indexPath.row]
        
        cell.lblItemTitle.text = products.MerchantName
        cell.lblItemDescription.text = products.productName
        if products.productImage.isEmpty{
            cell.imgItem.image = UIImage(named:"AppIcon.png")
        }else{
            cell.imgItem.kf.setImage(with: URL(string: products.productImage), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if error != nil{
                    cell.imgItem.image = UIImage(named:"AppIcon.png")
                }
            })
        }
        
        cell.lblStatus.text = cell.setStatusLabel(date: Date(), expireDate: products.expiry!, isRequested: products.requestedProduct.toBool()!)
        cell.lblPoints.text = "\(Int(products.cost)) pts"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopItemCell", for: indexPath) as! ShopItemCell
        cell.backgroundColor = UIColor.lightGray
        let products = productList[indexPath.row]
        selectedProductID = products.productID
        
        UIView.animate(withDuration: 0.1) {
            cell.backgroundColor = UIColor.white
            
            if Device.size() >= .screen7_9Inch{
                if let vc = UIStoryboard.ChildShopDetailiPad() as? ChildShopDetailVC{
                    vc.productID = self.selectedProductID
                    vc.isRequested = ChildProductsList.getRequestedStateByProductID(productID: self.selectedProductID).requestedProduct.toBool()!
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                if let vc = UIStoryboard.ChildShopDetail() as? ChildShopDetailVC{
                    vc.productID = self.selectedProductID
                    vc.isRequested = ChildProductsList.getRequestedStateByProductID(productID: self.selectedProductID).requestedProduct.toBool()!
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
    }
}
