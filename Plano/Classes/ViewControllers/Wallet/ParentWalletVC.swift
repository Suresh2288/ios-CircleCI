//
//  ParentWalletVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/8/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import PKHUD
import RealmSwift
import SafariServices
import SwiftyUserDefaults

class ParentWalletVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "parentshop"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "parentshop"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var featuredItemList2: UICollectionView!
    @IBOutlet weak var featuredItemList1: UICollectionView!
    @IBOutlet weak var colBanner : UICollectionView!
    @IBOutlet weak var colItemList : UICollectionView!
    @IBOutlet weak var walletScrollView : UIScrollView!
    @IBOutlet weak var lblCategory : UILabel!
    @IBOutlet weak var lblSort : UILabel!
    @IBOutlet weak var btnCategory : UIButton!
    @IBOutlet weak var btnSort : UIButton!
    @IBOutlet weak var colBannerHeight : NSLayoutConstraint!
    @IBOutlet weak var colItemListHeight : NSLayoutConstraint!
    @IBOutlet weak var featuredItemList2Width: NSLayoutConstraint!
    @IBOutlet weak var featuredItemList1Width: NSLayoutConstraint!
    // iPad
    @IBOutlet weak var sortContainerHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var sortItemOneSpacingConstraint : NSLayoutConstraint!
    @IBOutlet weak var sortItemTwoSpacingConstraint : NSLayoutConstraint!
    @IBOutlet weak var featuredproduct1Height: NSLayoutConstraint!
    @IBOutlet weak var featuredProductt2Height: NSLayoutConstraint!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var viewModel = ParentWalletViewModel()
    var bannerList : ParentProductsBannerList!
    var productList : Results<ParentProductsList>!
    let placeholderImage = UIImage()
    var selectedSorting = ""
    var selectedCategoryID = ""
    var selectedProductID : Int = 0
    var isSelectedStar : Int = 0
    var isCheckout  = ""
    var categoriesList : Results<AllCategories>!
    var categories : [String] = []
    var categoriesID : [String] = []
    var isPresented : Bool = false
    var comeFromProgress : Bool = false
    var comeFromDashboard : Bool = false
    var goingToDetail : Bool = false
    var edgeInsets1 = UIEdgeInsets()
    var edgeInsets2 = UIEdgeInsets()
    var edgeInsets3 = UIEdgeInsets()
    var frameSize1 = CGSize()
    var frameSize2 = CGSize()
    var miniInteriorSpace1 = CGFloat()
    var miniLineSpace1 = CGFloat()
    var miniInteriorSpace2 = CGFloat()
    var miniLineSpace2 = CGFloat()
    var profile = ProfileData.getProfileObj()
    var featuredProductsGroup2 = [StoreData]()
    var featuredProductsGroup1 = [StoreData]()
    var bannerImageArray = [String]()
    var bannerPurchaseLinkArray = [String]()
    var transitionTime = 0.0
    var slideTime = 0.0
    var counter = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Shop Page",pageName:"Shop Page",actionTitle:"Entered in Child Shop Page")
        
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
        
        registerWalletCells()
        setUpLayout()
        viewModelCallBack()
        self.getFeaturedProducts()
        self.getShopBanner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isPresented{
            
            viewModel.getAllCategories(success: { 
                
                self.categoriesList = AllCategories.getAllCategories()
                
                for i in 0..<self.categoriesList.count{
                    self.categories.append(self.categoriesList[i].CategoryName)
                    self.categoriesID.append(self.categoriesList[i].CategoryID)
                }
                
                // We need to add default cateogory "All" because server side no need to add that
                self.categories.insert("All", at: 0)
                self.categoriesID.insert("", at: 0)
                
                self.viewModel.getAllProductForParent(success: { 
                    
                    self.bannerList = ParentProductsBannerList.getBanner()
                    print("bannerList:\(self.bannerList)")
                    // prize will be set as initail datas in default
                    self.productList = ParentProductsList.getAllProducts()
                    
                    if self.bannerList == nil || self.bannerList.productImage == ""{
                        self.colBannerHeight.constant = 0
                    }else{
                        UIView.transition(with: self.colBanner, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                            
                            self.colBanner.reloadData()
                            
                        }, completion: nil)
                    }
                    
                    UIView.transition(with: self.colItemList, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                        
                        self.refreshProductList()
                        
                    }, completion: nil)
                    
                }) { (errorMessage) in
                    
                    self.showAlert(errorMessage)
                }
                
            }) { (errorMessage) in
                self.showAlert(errorMessage)
            }
            
            
            isPresented = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.timer.invalidate()
        if goingToDetail == false{
            if comeFromProgress == true{
                setUpNavBarWithAttributes(navtitle: "Child's progress", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16.0))
            }else if comeFromDashboard == true{
                addLeftMenuGesture()
                setupMenuNavBarWithAttributes(navtitle: "My Family".localized(), setStatusBarStyle: .default, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16.0))
            }
        }
    }
    
    func registerWalletCells() {
        colBanner.register(UINib(nibName : "WalletBannerCell", bundle : nil), forCellWithReuseIdentifier: "WalletBannerCell")
        colItemList.register(UINib(nibName : "WalletItemCell", bundle : nil), forCellWithReuseIdentifier: "WalletItemCell")
        featuredItemList1.register(UINib(nibName : "FeaturedProductList", bundle : nil), forCellWithReuseIdentifier: "FeaturedProductList")
        featuredItemList2.register(UINib(nibName : "FeaturedProductList", bundle : nil), forCellWithReuseIdentifier: "FeaturedProductList")
    }
    
    func setUpLayout() {
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let horizontalPagingLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let layout3: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // Setting layout for banner
        if Device.size() == .screen3_5Inch{
            edgeInsets1 = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            edgeInsets2 = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            edgeInsets3 = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            frameSize1 = CGSize(width: screenWidth, height: (screenHeight/2)-110)
            frameSize2 = CGSize(width: (screenWidth/2)-20, height: 170)
            miniInteriorSpace1 = 0
            miniLineSpace1 = 1
            miniInteriorSpace2 = 0
            miniLineSpace2 = 10
            horizontalPagingLayout.minimumInteritemSpacing = 0
            horizontalPagingLayout.minimumLineSpacing = 0
        }else if Device.size() == .screen4Inch{
            edgeInsets1 = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            edgeInsets2 = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            edgeInsets3 = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            frameSize1 = CGSize(width: screenWidth, height: (screenHeight/2)-110)
            frameSize2 = CGSize(width: (screenWidth/2)-20, height: 170)
            miniInteriorSpace1 = 0
            miniLineSpace1 = 1
            miniInteriorSpace2 = 0
            miniLineSpace2 = 10
            horizontalPagingLayout.minimumInteritemSpacing = 0
            horizontalPagingLayout.minimumLineSpacing = 0
        }else if Device.size() <= .screen5_5Inch{
            edgeInsets1 = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            edgeInsets2 = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            edgeInsets3 = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            frameSize1 = CGSize(width: screenWidth, height: (screenHeight/2)-180)
            frameSize2 = CGSize(width: (screenWidth/2)-20, height: 170)
            miniInteriorSpace1 = 0
            miniLineSpace1 = 1
            miniInteriorSpace2 = 0
            miniLineSpace2 = 10
            horizontalPagingLayout.minimumInteritemSpacing = 0
            horizontalPagingLayout.minimumLineSpacing = 0
        }else if Device.size() == .screen5_8Inch{
            edgeInsets1 = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            edgeInsets2 = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            edgeInsets3 = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            frameSize1 = CGSize(width: screenWidth, height: (screenHeight/2)-170)
            frameSize2 = CGSize(width: (screenWidth/2)-20, height: 170)
            miniInteriorSpace1 = 0
            miniLineSpace1 = 1
            miniInteriorSpace2 = 0
            miniLineSpace2 = 10
            horizontalPagingLayout.minimumInteritemSpacing = 0
            horizontalPagingLayout.minimumLineSpacing = 0
        }else{
            // iPad
            edgeInsets1 = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            edgeInsets2 = UIEdgeInsets(top: 25, left: 115, bottom: 25, right: 115)
            edgeInsets3 = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            frameSize1 = CGSize(width: screenWidth, height: (screenHeight/3)-160)
            frameSize2 = CGSize(width: (screenWidth/3)-85, height: 170)
            miniInteriorSpace1 = 5
            miniLineSpace1 = 5
            miniInteriorSpace2 = 5
            miniLineSpace2 = 20
            horizontalPagingLayout.minimumInteritemSpacing = 50
            horizontalPagingLayout.minimumLineSpacing = 0
        }
        
        horizontalPagingLayout.scrollDirection = .horizontal
        horizontalPagingLayout.sectionInset = edgeInsets1
        horizontalPagingLayout.itemSize = frameSize1
        
        
        layout.sectionInset = edgeInsets2
        layout.itemSize = frameSize2
        layout.minimumInteritemSpacing = miniInteriorSpace1
        layout.minimumLineSpacing = miniLineSpace2
        
        layout2.scrollDirection = .horizontal
        layout2.sectionInset = edgeInsets3
        layout2.itemSize = frameSize2
        layout2.minimumInteritemSpacing = miniInteriorSpace2
        layout2.minimumLineSpacing = miniLineSpace2
        
        layout3.scrollDirection = .horizontal
        layout3.sectionInset = edgeInsets3
        layout3.itemSize = frameSize2
        layout3.minimumInteritemSpacing = miniInteriorSpace2
        layout3.minimumLineSpacing = miniLineSpace2
        
        colBanner.collectionViewLayout = horizontalPagingLayout
        colBanner.showsHorizontalScrollIndicator = false
        colBanner.isPagingEnabled = true
        
        featuredItemList1.collectionViewLayout = layout2
        featuredItemList1.isScrollEnabled = true
        
        featuredItemList2.collectionViewLayout = layout3
        featuredItemList2.isScrollEnabled = true
        
        colItemList.collectionViewLayout = layout
        colItemList.isScrollEnabled = false
        
    }
    
    @objc func updateTimer(){
        self.counter += 1
        if self.counter <= self.bannerImageArray.count{
            let indexPath = IndexPath(row: self.counter-1, section: 0)
            colBanner.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: true)
        }else{
            self.counter = 0
            let indexPath = IndexPath(row: self.counter, section: 0)
            colBanner.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: true)
        }
    }
    
    func setUpCategoryPicker(){
        let categoryAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0..<categories.count{
            let alertAction = UIAlertAction(title: categories[i], style: .default, handler: { action in
                
                // this label will change selected menu text
                self.lblCategory.text = self.categories[i].localized()
                
                if self.categoriesID[i] == "1"{
                    // this one will fetch result based on user selected category
                    self.productList = ParentProductsList.getChildRequestedProductWithSort(category: self.categoriesID[i],sort: self.selectedSorting)
                }else{
                    // this one will fetch result based on user selected category
                    self.productList = ParentProductsList.getAllProductsByCategoryID(category: self.categoriesID[i],sort: self.selectedSorting)
                }
                
                // this one will refresh product on shop
                self.refreshProductList()
                
                // this one will be used at sorting with selected category
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
            self.productList = ParentProductsList.getSortedAtoZProducts(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "AEC"
        })
        let zToA_Action = UIAlertAction(title: "Alphabetical (Z-A)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Alphabetical (Z-A)".localized()
            self.productList = ParentProductsList.getSortedZtoAProducts(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "DEC"
        })
        let prizeHightoLow_Action = UIAlertAction(title: "Price (high to low)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Price (high to low)".localized()
            self.productList = ParentProductsList.getProductsCostHighToLow(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "DEC"
        })
        let prizeLowtoHigh_Action = UIAlertAction(title: "Price (low to high)".localized(), style: .default, handler: { action in
            self.lblSort.text = "Price (low to high)".localized()
            self.productList = ParentProductsList.getProductsCostLowToHigh(category: self.selectedCategoryID)
            self.refreshProductList()
            self.selectedSorting = "AEC"
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
        })
        
        sortByAlert.addAction(aToZ_Action)
        sortByAlert.addAction(zToA_Action)
        sortByAlert.addAction(prizeHightoLow_Action)
        sortByAlert.addAction(prizeLowtoHigh_Action)
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
        featuredItemList1.reloadData()
        featuredItemList2.reloadData()
        walletScrollView.layoutIfNeeded()
        colItemListHeight.constant = colItemList.contentSize.height + 15
        featuredItemList1Width.constant = featuredItemList1.contentSize.width + 10
        featuredItemList2Width.constant = featuredItemList2.contentSize.width + 10
        if featuredProductsGroup1.count == 0{
            featuredproduct1Height.constant = -10
        }else{
            featuredproduct1Height.constant = 160
        }
        if featuredProductsGroup2.count == 0{
            featuredProductt2Height.constant = -10
        }else{
            featuredProductt2Height.constant = 160
        }
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
    
    func getShopBanner(){
        self.bannerImageArray.removeAll()
        self.bannerPurchaseLinkArray.removeAll()
//        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID()]
//        let url = URL(string: Constants.API.URL + "/Parent/GetShopBanner")!
//        APIManager.sharedInstance.sendJSONRequest(method: .post, path: url, parameters: json) { (apiResponseHandler, error) -> Void in
//            print("URl:\(url)")
//            print("Payload:\(json)")
//            print("Response Request:\(apiResponseHandler.jsonObject)")
        
        viewModel.getShopBanner { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess(){
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let DataIs = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        //BannerItems
                        if DataIs.object(forKey: "BannerItems") as? NSArray != nil{
                            let BannerItems = DataIs.object(forKey: "BannerItems") as! NSArray
                            // ProductImage
                            for i in BannerItems{
                                if (i as AnyObject).object(forKey: "ProductImage") as? String != nil{
                                    let ProductImage = (i as AnyObject).object(forKey: "ProductImage") as! String
                                    self.bannerImageArray.append(ProductImage)
                                }
                                
                                if (i as AnyObject).object(forKey: "PruchaseLink") as? String != nil{
                                    let ProductImage = (i as AnyObject).object(forKey: "PruchaseLink") as! String
                                    self.bannerPurchaseLinkArray.append(ProductImage)
                                }
                            }
                        }
                        // BannerProperties
                        if DataIs.object(forKey: "BannerProperties") as? NSDictionary != nil{
                            let BannerProperties = DataIs.object(forKey: "BannerProperties") as! NSDictionary
                            // TransitionTime
                            if BannerProperties.object(forKey: "TransitionTime") as? String != nil{
                                self.transitionTime = Double(BannerProperties.object(forKey: "TransitionTime") as! String)!
                            }else if BannerProperties.object(forKey: "TransitionTime") as? Int != nil{
                                self.transitionTime = Double(BannerProperties.object(forKey: "TransitionTime") as! Int)
                            }else if BannerProperties.object(forKey: "TransitionTime") as? Double != nil{
                                self.transitionTime = BannerProperties.object(forKey: "TransitionTime") as! Double
                            }
                            else if BannerProperties.object(forKey: "TransitionTime") as? Float != nil{
                                self.transitionTime = Double(BannerProperties.object(forKey: "TransitionTime") as! Float)
                            }
                            // SlideTime
                            if BannerProperties.object(forKey: "SlideTime") as? String != nil{
                                self.slideTime = Double(BannerProperties.object(forKey: "SlideTime") as! String)!
                            }else if BannerProperties.object(forKey: "SlideTime") as? Int != nil{
                                self.slideTime = Double(BannerProperties.object(forKey: "SlideTime") as! Int)
                            }else if BannerProperties.object(forKey: "SlideTime") as? Double != nil{
                                self.slideTime = BannerProperties.object(forKey: "SlideTime") as! Double
                            }
                            else if BannerProperties.object(forKey: "SlideTime") as? Float != nil{
                                self.slideTime = Double(BannerProperties.object(forKey: "SlideTime") as! Float)
                            }
                            self.timer = Timer.scheduledTimer(timeInterval: self.slideTime, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
                        }
                    }
                }
            }
        }
    }
    
    func getFeaturedProducts(){
        self.featuredProductsGroup1.removeAll()
        self.featuredProductsGroup2.removeAll()
        
        //        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID()]
        //        let url = URL(string: Constants.API.URL + "/Parent/GetFeaturedProducts")!
        
        
        viewModel.getFeaturedProducts { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess(){
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let DataIS = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        // FeaturedProductsGroup1
                        if (DataIS as AnyObject).object(forKey: "FeaturedProductsGroup1") as? NSArray != nil{
                            let FeaturedProductsGroup1 = (DataIS as AnyObject).object(forKey: "FeaturedProductsGroup1") as! NSArray
                            for name in FeaturedProductsGroup1{
                                let dataClassIs = StoreData()
                                // ProductImage
                                if (name as AnyObject).object(forKey: "ProductImage") as? String != nil{
                                    dataClassIs.setProductImage(productImage: (name as AnyObject).object(forKey: "ProductImage") as! String)
                                }
                                // ProductName
                                if (name as AnyObject).object(forKey: "ProductName") as? String != nil{
                                    dataClassIs.setProductName(productName: (name as AnyObject).object(forKey: "ProductName") as! String)
                                }
                                
                                // MerchantName
                                if (name as AnyObject).object(forKey: "MerchantName") as? String != nil{
                                    dataClassIs.setMerchantName(merchantName: (name as AnyObject).object(forKey: "MerchantName") as! String)
                                }
                                
                                // ProductID
                                if (name as AnyObject).object(forKey: "ProductID") as? String != nil{
                                    dataClassIs.setProductID(productID: (name as AnyObject).object(forKey: "ProductID") as! String)
                                }
                                
                                // CheckOut
                                if (name as AnyObject).object(forKey: "IsCheckout") as? String != nil{
                                    dataClassIs.setCheckOutValue(checkOutValue: (name as AnyObject).object(forKey: "IsCheckout") as! String)
                                }
                                
                                // Price
                                if (name as AnyObject).object(forKey: "Price") as? String != nil{
                                    dataClassIs.setPrice(price: (name as AnyObject).object(forKey: "Price") as! String)
                                }else if (name as AnyObject).object(forKey: "Price") as? Int != nil{
                                    dataClassIs.setPrice(price: String((name as AnyObject).object(forKey: "Price") as! Int))
                                }else if (name as AnyObject).object(forKey: "Price") as? Double != nil{
                                    dataClassIs.setPrice(price: String((name as AnyObject).object(forKey: "Price") as! Double))
                                    
                                }else if (name as AnyObject).object(forKey: "Price") as? Float != nil{
                                    dataClassIs.setPrice(price: String((name as AnyObject).object(forKey: "Price") as! Float))
                                }
                                self.featuredProductsGroup1.append(dataClassIs)
                            }
                            self.featuredItemList2.reloadData()
                        }
                        // FeaturedProductsGroup2
                        if (DataIS as AnyObject).object(forKey: "FeaturedProductsGroup2") as? NSArray != nil{
                            let FeaturedProductsGroup2 = (DataIS as AnyObject).object(forKey: "FeaturedProductsGroup2") as! NSArray
                            for name in FeaturedProductsGroup2{
                                let dataClassIs = StoreData()
                                // ProductImage
                                if (name as AnyObject).object(forKey: "ProductImage") as? String != nil{
                                    dataClassIs.setProductImage(productImage: (name as AnyObject).object(forKey: "ProductImage") as! String)
                                }
                                // ProductName
                                if (name as AnyObject).object(forKey: "ProductName") as? String != nil{
                                    dataClassIs.setProductName(productName: (name as AnyObject).object(forKey: "ProductName") as! String)
                                }
                                
                                // ProductID
                                if (name as AnyObject).object(forKey: "ProductID") as? String != nil{
                                    dataClassIs.setProductID(productID: (name as AnyObject).object(forKey: "ProductID") as! String)
                                }
                                
                                // CheckOut
                                if (name as AnyObject).object(forKey: "IsCheckout") as? String != nil{
                                    dataClassIs.setCheckOutValue(checkOutValue: (name as AnyObject).object(forKey: "IsCheckout") as! String)
                                }
                                
                                // Price
                                if (name as AnyObject).object(forKey: "Price") as? String != nil{
                                    dataClassIs.setPrice(price: (name as AnyObject).object(forKey: "Price") as! String)
                                }else if (name as AnyObject).object(forKey: "Price") as? Int != nil{
                                    dataClassIs.setPrice(price: String((name as AnyObject).object(forKey: "Price") as! Int))
                                }else if (name as AnyObject).object(forKey: "Price") as? Double != nil{
                                    dataClassIs.setPrice(price: String((name as AnyObject).object(forKey: "Price") as! Double))
                                    
                                }else if (name as AnyObject).object(forKey: "Price") as? Float != nil{
                                    dataClassIs.setPrice(price: String((name as AnyObject).object(forKey: "Price") as! Float))
                                }
                                self.featuredProductsGroup2.append(dataClassIs)
                            }
                            self.featuredItemList2.reloadData()
                        }
                    }
                }
                else{
                    self.showAlert(apiResponseHandler.errorMessage())
                }
            }
        }
    }
}

extension ParentWalletVC : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colBanner{
            if bannerList == nil{
                return 0
            }else{
                return self.bannerImageArray.count
            }
        }else if collectionView == featuredItemList1{
            if productList == nil{
                return 0
            }else{
                return self.featuredProductsGroup1.count
            }
        }else if collectionView == featuredItemList2{
            if productList == nil{
                return 0
            }else{
                return self.featuredProductsGroup2.count
            }
        }else{
            if productList == nil{
                return 0
            }else{
                return productList.count
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colBanner{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletBannerCell", for: indexPath) as! WalletBannerCell
            if (bannerList) != nil{
                cell.imgBanner.kf.setImage(with: URL(string: self.bannerImageArray[indexPath.row]), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error != nil{
                        cell.imgBanner.image = UIImage(named:"AppIcon.png")
                    }
                })
            }else{
                cell.imgBanner.image = UIImage(named:"AppIcon.png")
            }
            return cell
        }else if collectionView == featuredItemList1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedProductList", for: indexPath) as! FeaturedProductList
            if featuredProductsGroup1[indexPath.row].getProductImage() != ""{
                cell.imageIs.kf.setImage(with: URL(string: featuredProductsGroup1[indexPath.row].getProductImage()), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error != nil{
                        cell.imageIs.image = UIImage(named:"AppIcon.png")
                    }
                })
            }else{
                cell.imageIs.image = UIImage(named:"AppIcon.png")
            }
            cell.productName.text = featuredProductsGroup1[indexPath.row].getProductName()
            cell.price.text =  "$" + featuredProductsGroup1[indexPath.row].getPrice()
            cell.MerchantName.text = featuredProductsGroup1[indexPath.row].getMerchantName()
            return cell
        }else if collectionView == featuredItemList2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedProductList", for: indexPath) as! FeaturedProductList
            if featuredProductsGroup2[indexPath.row].getProductImage() != ""{
                cell.imageIs.kf.setImage(with: URL(string: featuredProductsGroup2[indexPath.row].getProductImage()), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error != nil{
                        cell.imageIs.image = UIImage(named:"AppIcon.png")
                    }
                })
            }else{
                cell.imageIs.image = UIImage(named:"AppIcon.png")
            }
            cell.productName.text = featuredProductsGroup2[indexPath.row].getProductName()
            cell.price.text = "$" + featuredProductsGroup2[indexPath.row].getPrice()
            cell.MerchantName.text = featuredProductsGroup1[indexPath.row].getMerchantName()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletItemCell", for: indexPath) as! WalletItemCell
            
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
            
            // remove this line after safe break
            guard let expireDate : Date = products.expiry else{
                return cell
            }
            cell.lblStatus.text = cell.setStatusLabel(date: Date(), expireDate: expireDate)
            
            if products.price == 0.0{
                cell.lblPrice.text = " \(products.cost) pts"
                cell.lblPrice.addImageWith(name: "iconGamePoint", behindText: false)
            }else{
                cell.lblPrice.text = "   $\(products.itemPrice)  "
                cell.lblPrice.removeImage()
            }
            cell.isStar.isHidden = !(products.isStar.toBool())
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colBanner{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletBannerCell", for: indexPath) as! WalletBannerCell
            
            if self.bannerPurchaseLinkArray[indexPath.row] != nil{
                UIView.animate(withDuration: 0.1) {
                    cell.backgroundColor = UIColor.white
                    let safariVC = SFSafariViewController(url: URL(string : self.bannerPurchaseLinkArray[indexPath.row])!)
                    self.present(safariVC, animated: true, completion: nil)
                }
            }
            
            goingToDetail = true
            
        }else if collectionView == colItemList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletItemCell", for: indexPath) as! WalletItemCell
            cell.backgroundColor = UIColor.lightGray
            let products = productList[indexPath.row]
            selectedProductID = products.productID
            isSelectedStar = products.isStar
            isCheckout = products.isCheckout
            
            
            
            UIView.animate(withDuration: 0.1) {
                cell.backgroundColor = UIColor.white
                if Device.size() >= .screen7_9Inch{
                    let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
                    let vc = UIStoryboard.WalletDetailiPad() as! ParentWalletDetailVC
                    vc.productID = self.selectedProductID
                    vc.isStar = self.isSelectedStar
                    vc.isCheckout = self.isCheckout
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vc,animated: true)
                }else{
                    let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
                    let vc = UIStoryboard.WalletDetail() as! ParentWalletDetailVC
                    vc.productID = self.selectedProductID
                    vc.isStar = self.isSelectedStar
                    vc.isCheckout = self.isCheckout
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            }
            
            goingToDetail = true
        }
        else if collectionView == featuredItemList1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedProductList", for: indexPath) as! FeaturedProductList
            
            cell.backgroundColor = UIColor.lightGray
            selectedProductID = Int(featuredProductsGroup1[indexPath.row].getProductID())!
            isCheckout = featuredProductsGroup1[indexPath.row].getCheckOutValue()
            
            UIView.animate(withDuration: 0.1) {
                cell.backgroundColor = UIColor.white
                if Device.size() >= .screen7_9Inch{
                    let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
                    let vc = UIStoryboard.WalletDetailiPad() as! ParentWalletDetailVC
                    vc.productID = self.selectedProductID
                    vc.isStar = self.isSelectedStar
                    vc.isCheckout = self.isCheckout
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vc,animated: true)
                }else{
                    let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
                    let vc = UIStoryboard.WalletDetail() as! ParentWalletDetailVC
                    vc.productID = self.selectedProductID
                    vc.isStar = self.isSelectedStar
                    vc.isCheckout = self.isCheckout
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            }
            
            goingToDetail = true
        }
        else if collectionView == featuredItemList2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedProductList", for: indexPath) as! FeaturedProductList
            
            cell.backgroundColor = UIColor.lightGray
            selectedProductID = Int(featuredProductsGroup2[indexPath.row].getProductID())!
            isCheckout = featuredProductsGroup2[indexPath.row].getCheckOutValue()
            
            UIView.animate(withDuration: 0.1) {
                cell.backgroundColor = UIColor.white
                if Device.size() >= .screen7_9Inch{
                    let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
                    let vc = UIStoryboard.WalletDetailiPad() as! ParentWalletDetailVC
                    vc.productID = self.selectedProductID
                    vc.isStar = self.isSelectedStar
                    vc.isCheckout = self.isCheckout
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vc,animated: true)
                }else{
                    let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
                    let vc = UIStoryboard.WalletDetail() as! ParentWalletDetailVC
                    vc.productID = self.selectedProductID
                    vc.isStar = self.isSelectedStar
                    vc.isCheckout = self.isCheckout
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vc,animated: true)
                }
            }
            
            goingToDetail = true
        }
    }
}

extension UILabel {
    
    func addImageWith(name: String, behindText: Bool) {
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}
