//
//  ChildShopDetailVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PopupDialog
import PKHUD
import SwiftyUserDefaults
import Device

class ChildShopDetailVC: _BaseViewController {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblPoints : UILabel!
    @IBOutlet weak var imgPoints : UIImageView!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    
    @IBOutlet weak var tblItemDetail : UITableView!
    var productID : Int = 0
    var expandRowIndex = -1
    var isExpandDetail = false
    var isRequested : Bool = false
    var viewModel = ChildShopViewModel()
    let placeholderImage = UIImage()
    var productDetail : ChildProductDetail!
    
    // For button color changes
    var isExpired : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .default
        
        if Device.size() >= .screen7_9Inch{
            let color = UIColor.black
            let blackTrans = UIColor.withAlphaComponent(color)(0.8)
            self.view.backgroundColor = blackTrans
        }
        
        initDetailView()
        setupDetailView()
        
        viewModelCallBack()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Child Shop Detail Page",pageName:"Child Shop Detail Page",actionTitle:"Child Shop Detail")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.getProductDetailForChild(success: { 
            
            self.productDetail = ChildProductDetail.getProductDetailObj()!
            self.lblTitle.text = self.productDetail.categoryName
            self.lblDescription.text = self.productDetail.productName
            self.lblPoints.text = "\(self.productDetail.cost) pts"
            self.lblStatus.text = self.setStatusLabel(date: Date(), expireDate: self.productDetail.expiry!)
            
            UIView.transition(with: self.tblItemDetail, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                
                self.tblItemDetail.reloadData()
                
            }, completion: nil)
            
        }) { (errorMessage) in
            
            self.initDetailView()
            self.showErrorDialog(error_message: errorMessage)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setupDetailView() {
        
        tblItemDetail.register(UINib(nibName: "ShopDetailImageCell", bundle: nil), forCellReuseIdentifier: "ShopDetailImageCell")
        tblItemDetail.register(UINib(nibName: "ShopDescriptionTextCell", bundle: nil), forCellReuseIdentifier: "ShopDescriptionTextCell")
        tblItemDetail.register(UINib(nibName: "RequestParentCell", bundle: nil), forCellReuseIdentifier: "RequestParentCell")
        
        tblItemDetail.showsVerticalScrollIndicator = false
        tblItemDetail.estimatedRowHeight = 100
        tblItemDetail.rowHeight = UITableView.automaticDimension
        
    }
    
    func initDetailView(){
        lblPoints.isHidden = true
        lblStatus.isHidden = true
        lblTitle.isHidden = true
        lblDescription.isHidden = true
        imgPoints.isHidden = true
    }
    
    func viewModelCallBack() {
        
        viewModel.productID = productID
        
        viewModel.beforeApiCall = {
            self.loadingIndicator.startAnimating()
        }
        
        viewModel.beforeRequestApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            self.loadingIndicator.stopAnimating()
            self.lblPoints.isHidden = false
            self.lblStatus.isHidden = false
            self.lblTitle.isHidden = false
            self.lblDescription.isHidden = false
            self.imgPoints.isHidden = false
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
            self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func btnSendRequestTapped(sender : UIButton){
        
        let indexPath = IndexPath(item: 2, section: 0)
        let cell = tblItemDetail.cellForRow(at: indexPath) as! RequestParentCell
        
        cell.btnSendRequest.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
        cell.btnSendRequest.setTitle("Requested", for: .normal)
        
        tblItemDetail.beginUpdates()
        tblItemDetail.endUpdates()
        
        viewModel.updateChildRequestProduct(success: { _ in
            self.goToNextScreen()
        }) { (errorMessage) in
            self.showAlert(errorMessage)
            
            let indexPath = IndexPath(item: 2, section: 0)
            let cell = self.tblItemDetail.cellForRow(at: indexPath) as! RequestParentCell
            
            cell.btnSendRequest.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
            cell.btnSendRequest.setTitle("Request", for: .normal)
            
            self.tblItemDetail.beginUpdates()
            self.tblItemDetail.endUpdates()
        }
        
    }
    
    func goToNextScreen(){
        if Device.size() >= .screen7_9Inch{
            if let vc = UIStoryboard.ChildShopRequestPromptiPad() as? ChildShopRequestPromptVC {
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }else{
            if let vc = UIStoryboard.ChildShopRequestPrompt() as? ChildShopRequestPromptVC {
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnSeeMoreTapped(sender : UIButton){
        
        let indexPath = IndexPath(item: 1, section: 0)
        let cell = tblItemDetail.cellForRow(at: indexPath) as! ShopDescriptionTextCell
        
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
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChildShopDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productDetail == nil{
            return 0
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == expandRowIndex && isExpandDetail{
            return UITableView.automaticDimension
        }else if indexPath.row == 1{
            return 120
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopDetailImageCell") as! ShopDetailImageCell

            let imgs = productDetail.getProductImages()
            var imgWithImageViewHolder:[UIImageView] = []
            for img in imgs {
                let i = UIImageView() // new image holder
                i.kf.setImage(with: URL(string: img), placeholder: placeholderImage,options: [.transition(.fade(0.5))]) // placeholder
                imgWithImageViewHolder.append(i)
            }
            cell.imgArray = imgWithImageViewHolder
            
            return cell
            
        }else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShopDescriptionTextCell") as! ShopDescriptionTextCell
            
            cell.lblDescripton.text = "Description".localized()
            cell.lblDetail.text = productDetail.descriptionText.localized()
            
            cell.btnSeeMore.setTitle("See More".localized(), for: .normal)
            cell.btnSeeMore.addTarget(self, action: #selector(ChildShopDetailVC.btnSeeMoreTapped(sender:)), for: .touchUpInside)
            
            return cell
            
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestParentCell") as! RequestParentCell
            
            if isExpired{
                cell.btnSendRequest.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
                cell.btnSendRequest.isEnabled = false
            }else if isRequested{
                cell.btnSendRequest.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
                cell.btnSendRequest.setTitle("Requested".localized(), for: .normal)
                cell.btnSendRequest.isEnabled = false
            }
            
            cell.btnSendRequest.addTarget(self, action: #selector(ChildShopDetailVC.btnSendRequestTapped(sender:)), for: .touchUpInside)
            
            return cell
            
        }
    }
}
