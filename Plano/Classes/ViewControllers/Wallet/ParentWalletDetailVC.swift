//
//  ParentWalletDetailVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PopupDialog
import PKHUD
import SafariServices
import SwiftyUserDefaults
import Device

class ParentWalletDetailVC: _BaseViewController {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblPrize : UILabel!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    
    @IBOutlet weak var tblItemDetail : UITableView!
    var productID : Int = 0
    var isStar : Int = 0
    var isCheckout : String = ""
    var expandRowIndex = -1
    var isExpandDetail = false
    
    var viewModel = ParentWalletViewModel()
    let placeholderImage = UIImage()
    var productDetail : ParentProductDetail!
    
    // For button color changes
    var isExpired : Bool = false
    var appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isViewPresented : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Device.size() >= .screen7_9Inch{
            let color = UIColor.black
            let blackTrans = UIColor.withAlphaComponent(color)(0.8)
            self.view.backgroundColor = blackTrans
        }
        
        UIApplication.shared.statusBarStyle = .default
        
        initDetailView()
        setupDetailView()
        
        viewModelCallBack()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Shop Detail Page",pageName:"Shop Detail Page",actionTitle:"Entered in Shop Detail Page")

        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.getProductDetailForParent(success: { 
            
            self.productDetail = ParentProductDetail.getProductDetailObj()!
            self.lblTitle.text = self.productDetail.categoryName
            self.lblDescription.text = self.productDetail.productName
            if Double(self.productDetail.price) == 0.0{
                self.lblPrize.text = " \(self.productDetail.cost) pts"
                self.lblPrize.addImageWith(name: "iconGamePoint", behindText: false)
            }else{
                self.lblPrize.text = "$ \(self.productDetail.price)"
                self.lblPrize.removeImage()
            }
            
            self.lblStatus.text = self.setStatusLabel(date: Date(), expireDate: self.productDetail.expiry!)
            //
            
            UIView.transition(with: self.tblItemDetail, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                
                DispatchQueue.main.async {
                    self.tblItemDetail.reloadData()
                }
                
            }, completion: nil)
            
        }) { (errorMessage) in
            
            self.initDetailView()
            self.showErrorDialog(error_message: errorMessage)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        if (isViewPresented) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func setupDetailView() {
        
        tblItemDetail.register(UINib(nibName: "WalletDetailImageCell", bundle: nil), forCellReuseIdentifier: "WalletDetailImageCell")
        tblItemDetail.register(UINib(nibName: "DescriptionTextCell", bundle: nil), forCellReuseIdentifier: "DescriptionTextCell")
        tblItemDetail.register(UINib(nibName: "PromoCodeCell", bundle: nil), forCellReuseIdentifier: "PromoCodeCell")
        tblItemDetail.register(UINib(nibName: "BuyNowCell", bundle: nil), forCellReuseIdentifier: "BuyNowCell")
        tblItemDetail.register(UINib(nibName: "ViewProductCell", bundle: nil), forCellReuseIdentifier: "ViewProductID")
        
        tblItemDetail.showsVerticalScrollIndicator = false
        tblItemDetail.estimatedRowHeight = 100
        tblItemDetail.rowHeight = UITableView.automaticDimension
        
    }
    
    func initDetailView(){
        lblPrize.isHidden = true
        lblStatus.isHidden = true
        lblTitle.isHidden = true
        lblDescription.isHidden = true
    }
    
    func viewModelCallBack() {
        
        viewModel.productID = productID
        viewModel.isStar = isStar
        
        viewModel.beforeApiCall = {
            self.loadingIndicator.startAnimating()
        }
        
        viewModel.beforeRequestApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            self.loadingIndicator.stopAnimating()
            self.lblPrize.isHidden = false
            self.lblStatus.isHidden = false
            self.lblTitle.isHidden = false
            self.lblDescription.isHidden = false
        }
        
        viewModel.afterRequestApiCall = {
            HUD.hide()
        }
    }
    
    // MARK: - Error Dialog
    func showErrorDialog(error_message : String) {
        
        let message = error_message.localized()
        
        // Create the dialog
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            let vc = UIStoryboard.WalletNav()
            self.slideMenuController()?.changeMainViewController(vc, close: true)
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func setStatusLabel(date : Date,expireDate : Date) -> String{
        var remove7DaysComponents = DateComponents()
        remove7DaysComponents.day = -7
        let sevenDaysAgo = Calendar.current.date(byAdding: remove7DaysComponents, to: expireDate)
        if date >= expireDate{
            lblStatus.textColor = UIColor.lightGray
            isExpired = true
            return " Expired "
        }else if date < sevenDaysAgo!{
            lblStatus.textColor = Color.FlatRed.instance()
            isExpired = false
            return ""
        }else if date >= sevenDaysAgo! && date < expireDate{
            lblStatus.textColor = Color.FlatRed.instance()
            isExpired = false
            return " Expiring soon \(expireDate.toStringWith(format: "dd/MM/yyyy"))  "
        }
        return ""
    }
    
    @IBAction func btnBuyNowTapped(sender : UIButton){
        
        if ProfileData.getProfileObj()?.countryResidence == "SG"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Wallet", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CheckOutVC") as! CheckOutVC
            self.appdelegate.passPriceValue = productDetail.price
            nextViewController.productNameIs = productDetail.productName
            nextViewController.productIDIs = String(productDetail.productID)
            nextViewController.isFromProgressView = isViewPresented
            self.navigationController?.pushViewController(nextViewController,animated: true)
        } else {
            self.showAlert("Product is not available in your region".localized())
        }
        
    }
    
    @IBAction func btnViewProductTapped(sender : UIButton){
        
        viewModel.updatePurchaseProduct(success: { _ in
            self.goToNextScreen()
        }) { (errorMessage) in
            self.showAlert(errorMessage)
        }
        
    }
    
    func goToNextScreen(){
        let safariVC = SFSafariViewController(url: URL(string : productDetail.purchaseLink)!)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func btnSeeMoreTapped(sender : UIButton){
        
        let indexPath = IndexPath(item: 2, section: 0)
        let cell = tblItemDetail.cellForRow(at: indexPath) as! DescriptionTextCell
        
        if expandRowIndex == -1 {
            isExpandDetail = true
            expandRowIndex = indexPath.row
            cell.btnSeeMore.setTitle("See Less".localized(), for: .normal)
        }
        else {
            // there is no cell selected anymore
            isExpandDetail = false
            expandRowIndex = -1
            cell.btnSeeMore.setTitle("See More".localized(), for: .normal)
        }
        
        tblItemDetail.beginUpdates()
        tblItemDetail.endUpdates()
    }
    
    @IBAction func dismiss(){
        
        if (isViewPresented)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let vc = UIStoryboard.WalletNav()
            self.slideMenuController()?.changeMainViewController(vc, close: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ParentWalletDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productDetail == nil{
            return 0
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == expandRowIndex && isExpandDetail{
            return UITableView.automaticDimension
        }else if indexPath.row == 1{
            return 40
        }else if indexPath.row == 2{
            return 120
        }else if indexPath.row == 3{
            if productDetail.promoCode == ""{
                return 0
            }else{
                return UITableView.automaticDimension
            }
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletDetailImageCell") as! WalletDetailImageCell
            
            let imgs = productDetail.getProductImages()
            var imgWithImageViewHolder:[UIImageView] = []
            for img in imgs {
                let i = UIImageView() // new image holder
                i.kf.setImage(with: URL(string: img), placeholder: placeholderImage,options: [.transition(.fade(0.5))]) // placeholder
                imgWithImageViewHolder.append(i)
            }
            cell.imgArray = imgWithImageViewHolder
            
            if Double(productDetail.price) == 0.0{
                cell.blurView.isHidden = true
            }else{
                cell.blurView.isHidden = false
                cell.lblPrize.text = "  " + "$".localized() + productDetail.price + "  "
            }
            
            
            return cell
            
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViewProductID") as! ViewProductCell
            
            cell.lbl_ViewProduct_Outlet.text = "View Product".localized()
            cell.vw_BaseView_Outlet.addTarget(self, action: #selector(ParentWalletDetailVC.btnViewProductTapped(sender:)), for: .touchUpInside)
            
            return cell
        }else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTextCell") as! DescriptionTextCell
            
            cell.sizeToFit()
            cell.textLabel?.numberOfLines = 0
            cell.lblDetail.numberOfLines = 0
            cell.lblDescripton.text = "Description".localized()
            cell.lblDetail.text = productDetail.descriptionText.localized()
            
            cell.btnSeeMore.setTitle("See More".localized(), for: .normal)
            cell.btnSeeMore.addTarget(self, action: #selector(ParentWalletDetailVC.btnSeeMoreTapped(sender:)), for: .touchUpInside)
            
            return cell
            
        }else if indexPath.row == 3{
            
            if productDetail.promoCode == ""{
                return UITableViewCell()
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCodeCell") as! PromoCodeCell
                cell.lblPromoCode.text = "  \(productDetail.promoCode)  "
                cell.lblPromoTitle.text = "Promo Code".localized()
                
                return cell
            }
            
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BuyNowCell") as! BuyNowCell
            
            if isCheckout == "False"{
                cell.btnBuyNow.isHidden = true
            }else{
                cell.btnBuyNow.isHidden = false
            }
            if isExpired{
                cell.btnBuyNow.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
                cell.btnBuyNow.isEnabled = false
            }
            
            cell.btnBuyNow.addTarget(self, action: #selector(ParentWalletDetailVC.btnBuyNowTapped(sender:)), for: .touchUpInside)
            
            return cell
            
        }
    }
}
