//
//  ChildShopVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/10/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class ChildShopVC: _BaseViewController {
    
    @IBOutlet weak var colItemList : UICollectionView!
    @IBOutlet weak var btnCategory : UIButton!
    @IBOutlet weak var btnSort : UIButton!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // Sample data
    var bannerData = ["Banner","Banner","Banner","Banner"]
    var itemListData = [ShopItem(imageURL : "Item1", itemName : "Vouchers", itemDescription : "Toys \"R\" Us", isNew : true, isFav : true), ShopItem(imageURL : "Item2", itemName : "Tickets", itemDescription : "USS, Singapore", isNew : false, isFav : false), ShopItem(imageURL : "Item3", itemName : "Tickets", itemDescription : "Adventure Cove, Sentosa", isNew : true, isFav : false), ShopItem(imageURL : "Item4", itemName : "Tickets", itemDescription : "Sea Aquarium", isNew : false, isFav : false),ShopItem(imageURL : "Item1", itemName : "Vouchers", itemDescription : "Toys \"R\" Us", isNew : false, isFav : false), ShopItem(imageURL : "Item2", itemName : "Tickets", itemDescription : "USS, Singapore", isNew : true, isFav : false), ShopItem(imageURL : "Item3", itemName : "Tickets", itemDescription : "Adventure Cove, Sentosa", isNew : false, isFav : false), ShopItem(imageURL : "Item4", itemName : "Tickets", itemDescription : "Sea Aquarium", isNew : false, isFav : false)]
    
    var detailData : ShopItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuNavBarWithAttributes(navtitle: "plano shop", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        
        colItemList.register(UINib(nibName : "ShopItemCell", bundle : nil), forCellWithReuseIdentifier: "ShopItemCell")
        
        setUpLayout()
        // Do any additional setup after loading the view.
    }
    
    func setUpLayout() {
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        // Setting layout for column list
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
        layout.itemSize = CGSize(width: (screenWidth/2)-20, height: (screenHeight/2)-90)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 1
        colItemList.collectionViewLayout = layout
        colItemList.allowsSelection = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setUpCategoryPicker(){
        let categoryAlert = UIAlertController(title: "Choose a category", message: "", preferredStyle: .actionSheet)
        
        let educationAction = UIAlertAction(title: "Education", style: .default, handler: { action in
            self.btnCategory.setTitle("Education".localized(), for: .normal)
        })
        let healthAction = UIAlertAction(title: "Health", style: .default, handler: { action in
            self.btnCategory.setTitle("Health".localized(), for: .normal)
        })
        let recreationalAction = UIAlertAction(title: "Recreational", style: .default, handler: { action in
            self.btnCategory.setTitle("Recreational".localized(), for: .normal)
        })
        let retailAction = UIAlertAction(title: "Retail", style: .default, handler: { action in
            self.btnCategory.setTitle("Retail".localized(), for: .normal)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        })
        
        categoryAlert.addAction(educationAction)
        categoryAlert.addAction(healthAction)
        categoryAlert.addAction(recreationalAction)
        categoryAlert.addAction(retailAction)
        categoryAlert.addAction(cancelAction)
        
        self.present(categoryAlert, animated: true, completion: nil)
    }
    
    func setUpSortPicker(){
        let categoryAlert = UIAlertController(title: "Sort by", message: "", preferredStyle: .actionSheet)
        
        let aToZ_Action = UIAlertAction(title: "Alphabet (A-Z)", style: .default, handler: { action in
            self.btnSort.setTitle("Alphabet (A-Z)".localized(), for: .normal)
            self.btnSort.titleLabel?.font = FontBook.Bold.of(size: 12)
        })
        let zToA_Action = UIAlertAction(title: "Alphabet (Z-A)", style: .default, handler: { action in
            self.btnSort.setTitle("Alphabet (Z-A)".localized(), for: .normal)
            self.btnSort.titleLabel?.font = FontBook.Bold.of(size: 12)
        })
        let highToLowAction = UIAlertAction(title: "Points (High to low)", style: .default, handler: { action in
            self.btnSort.setTitle("Points (High to low)".localized(), for: .normal)
            self.btnSort.titleLabel?.font = FontBook.Bold.of(size: 12)
        })
        let lowToHighAction = UIAlertAction(title: "Points (Low to high)", style: .default, handler: { action in
            self.btnSort.setTitle("Points (Low to high)".localized(), for: .normal)
            self.btnSort.titleLabel?.font = FontBook.Bold.of(size: 12)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        })
        
        categoryAlert.addAction(aToZ_Action)
        categoryAlert.addAction(zToA_Action)
        categoryAlert.addAction(highToLowAction)
        categoryAlert.addAction(lowToHighAction)
        categoryAlert.addAction(cancelAction)
        
        self.present(categoryAlert, animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowItemDetail"{
            let destinationController = segue.destination as! ChildShopDetailVC
            destinationController.detailData = detailData
        }
    }
}

extension ChildShopVC : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopItemCell", for: indexPath) as! ShopItemCell
        
        let itemList = itemListData[indexPath.row]
        
        cell.lblItemTitle.text = itemList.itemName
        cell.lblItemDescription.text = itemList.itemDescription
        cell.imgItem.image = UIImage(named: itemList.imageURL)
        cell.newItemView.isHidden = !(itemList.isNew)
        cell.favItemView.isHidden = !(itemList.isFav)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopItemCell", for: indexPath) as! ShopItemCell
        detailData = itemListData[indexPath.row]
        cell.backgroundColor = UIColor.lightGray
        UIView.animate(withDuration: 0.1) {
            cell.backgroundColor = UIColor.white
            self.performSegue(withIdentifier: "ShowItemDetail", sender: nil)
        }
        
    }
}
