//
//  MyOderListVCViewController.swift
//  Plano
//
//  Created by John Raja on 11/06/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit
import Alamofire

class MyOderListVC: _BaseViewController{
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var tblView_Outlet: UITableView!
    @IBOutlet weak var pageView_Outlet: UICollectionView!
    @IBOutlet weak var vw_Alert_Outlet: UIView!
    @IBOutlet weak var height_CollectionView: NSLayoutConstraint!
    @IBOutlet weak var vw_CollectionView_Outlet: UIView!
    @IBOutlet weak var lbl_PageCountHeader_Outlet: UILabel!
    @IBOutlet weak var height_PageCountHeader_Outlet: NSLayoutConstraint!
    @IBOutlet weak var lbl_NoOrderAlert_Outlet: UILabel!
    @IBOutlet weak var vw_OrderDetailView_Outlet: UIView!
    
    // OrderDetails values
    @IBOutlet weak var vw_Back_Outlet: UIView!
    @IBOutlet weak var lbl_PageHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_DateHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_OrderIdHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_ProductNameHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_PhoneHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_ShippingAddressHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_BillingAddressHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_DeliveryStatusHeader_Outlet: UILabel!
    @IBOutlet weak var lbl_Date_Outlet: UILabel!
    @IBOutlet weak var lbl_OrderId_Outlet: UILabel!
    @IBOutlet weak var lbl_ProductName_Outlet: UILabel!
    @IBOutlet weak var lbl_Phone_Outlet: UILabel!
    @IBOutlet weak var lbl_ShippingAddress_Outlet: UILabel!
    @IBOutlet weak var lbl_BillingAddress_Outlet: UILabel!
    @IBOutlet weak var lbl_DeliveryStatus_Outlet: UILabel!
    
    var viewModel = ParentWalletViewModel()
    @IBOutlet weak var lbl_Notes_Outlet: UILabel!
    var profile = ProfileData.getProfileObj()
    var myOrderArray = [StoreData]()
    var pageCountIS = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        setupMenuNavBarWithAttributes(navtitle: "My Orders".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        // Registering TableView Cell
        self.tblView_Outlet.register(UINib(nibName : "MyOrderList", bundle : nil), forCellReuseIdentifier: "MyOrderListCell")
        // Registering Collection View Cell
        self.pageView_Outlet.delegate = self
        self.pageView_Outlet.dataSource = self
        self.pageView_Outlet.register(UINib(nibName: "PaginationCell", bundle: nil), forCellWithReuseIdentifier: "paginationCell")
        // Hide Order detail Page
        self.vw_Back_Outlet.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(self.vw_Back_Action)))
        self.vw_Back_Outlet.isUserInteractionEnabled = true
        // language
        self.lbl_PageCountHeader_Outlet.text = "Number of Pages".localized()
        self.lbl_NoOrderAlert_Outlet.text = "No Orders yet".localized()
        self.lbl_PageHeader_Outlet.text = "Order Details".localized()
        self.lbl_DateHeader_Outlet.text = "Date".localized()
        self.lbl_OrderIdHeader_Outlet.text = "Order Id".localized()
        self.lbl_ProductNameHeader_Outlet.text = "Product Name".localized()
        self.lbl_PhoneHeader_Outlet.text = "Phone".localized()
        self.lbl_ShippingAddressHeader_Outlet.text = "Shipping Address".localized()
        self.lbl_BillingAddressHeader_Outlet.text = "Billing Address".localized()
        self.lbl_DeliveryStatusHeader_Outlet.text = "Delivery Status".localized()
        self.lbl_Notes_Outlet.text = "For enquires on your order status, Kindly contact us at orders@plano.co".localized()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        WoopraTrackingPage().trackEvent(mainMode:"Parent Order List Page",pageName:"My Order List Page",actionTitle:"Entered in myorder list page")
        self.gettingMyOrderLists(pageNumber:1)
        self.vw_OrderDetailView_Outlet.isHidden = true
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    func gettingMyOrderLists(pageNumber:Int){
        self.myOrderArray.removeAll()
//        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID(),"pageSize": "10","pageNo": "\(pageNumber)"]
//        let url = URL(string: Constants.API.URL + "/Payment/GetProductOrders")!
//        print("url:\(url)")
//        print("json:\(json)")
        
        viewModel.pageNumber = String(pageNumber)
        viewModel.getProductOrders { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess(){
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let myDataIs = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        if myDataIs.object(forKey: "OrderItems") as? NSArray != nil{
                            let myOrderItemsIS = myDataIs.object(forKey: "OrderItems") as! NSArray
                            for orderData in myOrderItemsIS{
                                var dataClassIs = StoreData()
                                // OrderUUID
                                if (orderData as AnyObject).object(forKey: "OrderUUID") as? String != nil{
                                    dataClassIs.setOrderUUID(orderUUID: (orderData as AnyObject).object(forKey: "OrderUUID") as! String)
                                }else{
                                    dataClassIs.setOrderUUID(orderUUID: "0")
                                }
                                // ProductName
                                if (orderData as AnyObject).object(forKey: "ProductName") as? String != nil{
                                    dataClassIs.setProductName(productName: (orderData as AnyObject).object(forKey: "ProductName") as! String)
                                }else{
                                    dataClassIs.setProductName(productName: "Product Name Not Available")
                                }
                                // PurchaseDate
                                if (orderData as AnyObject).object(forKey: "PurchaseDate") as? String != nil{
                                    dataClassIs.setPurchaseDate(purchaseDate: (orderData as AnyObject).object(forKey: "PurchaseDate") as! String)
                                }else if (orderData as AnyObject).object(forKey: "PurchaseDate") as? Int != nil{
                                    dataClassIs.setPurchaseDate(purchaseDate: String((orderData as AnyObject).object(forKey: "PurchaseDate") as! Int))
                                }else{
                                    dataClassIs.setPurchaseDate(purchaseDate: "0")
                                }
                                // DeliveryStatus
                                if (orderData as AnyObject).object(forKey: "DeliveryStatus") as? String != nil{
                                    dataClassIs.setDeliveryStatus(deliveryStatus: (orderData as AnyObject).object(forKey: "DeliveryStatus") as! String)
                                }else{
                                    dataClassIs.setDeliveryStatus(deliveryStatus: "Not Available")
                                }
                                self.myOrderArray.append(dataClassIs)
                            }
                        }
                        // TotalCount
                        if (myDataIs as AnyObject).object(forKey: "TotalCount") as? String != nil{
                            let totalCountIs = Double((myDataIs as AnyObject).object(forKey: "TotalCount") as! String)
                            self.pageCountIS = Int(round(totalCountIs! / 10.0))
                        }else if (myDataIs as AnyObject).object(forKey: "TotalCount") as? Int != nil{
                            let totalCountIs = Double((myDataIs as AnyObject).object(forKey: "DeliveryStatus") as! Int)
                            self.pageCountIS = Int(Double(round(totalCountIs / 10.0)))
                        }else{
                            self.pageCountIS = 0
                        }
                        self.pageCountIS = 1 * self.pageCountIS
                        if self.pageCountIS > 1{
                            self.showingHeaderForPage(value:false,heightIs: 30.0)
                        }else{
                            self.showingHeaderForPage(value:false,heightIs: 30.0)
                        }
                        print("self.myOrderArray.count\(self.myOrderArray.count)")
                        if self.myOrderArray.count > 0{
                            self.tblView_Outlet.reloadData()
                        }
                        self.pageView_Outlet.reloadData()
                    }
                }
            }
        }
    }
    
    // Getting OrderDetail
    func gettingMyOrderDetail(passOrderId:String){
//        let json: [String: Any] = ["email":self.profile!.email,"access_Token":self.profile!.accessToken,"languageID": LanguageManager.sharedInstance.getSelectedLanguageID(),"orderUUID": passOrderId]
//        let url = URL(string: Constants.API.URL + "/Payment/GetProductOrderDetails")!
        
        viewModel.orderID = passOrderId
        viewModel.getProductOrderDetails { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess(){
                print("apiResponseHandler:\(apiResponseHandler)")
                if apiResponseHandler.jsonObject as? NSDictionary != nil{
                    let myRespondataIs = apiResponseHandler.jsonObject as! NSDictionary
                    if myRespondataIs.object(forKey: "Data") as? NSDictionary != nil{
                        let myDataIs = myRespondataIs.object(forKey: "Data") as! NSDictionary
                        if myDataIs.object(forKey: "OrderDetails") as? NSDictionary != nil{
                            let OrderDetailsIs = myDataIs.object(forKey: "OrderDetails") as! NSDictionary
                            // UpdatedDate
                            if OrderDetailsIs.object(forKey: "UpdatedDate") as? String != nil{
                                self.lbl_Date_Outlet.text = OrderDetailsIs.object(forKey: "UpdatedDate") as! String
                            }else if OrderDetailsIs.object(forKey: "UpdatedDate") as? Int != nil{
                                self.lbl_Date_Outlet.text = String(OrderDetailsIs.object(forKey: "UpdatedDate") as! Int)
                            }else{
                                self.lbl_Date_Outlet.text = "Date not available".localized()
                            }
                            // OrderUUID
                            if OrderDetailsIs.object(forKey: "OrderUUID") as? String != nil{
                                self.lbl_OrderId_Outlet.text = OrderDetailsIs.object(forKey: "OrderUUID") as! String
                            }else if OrderDetailsIs.object(forKey: "OrderUUID") as? Int != nil{
                                self.lbl_OrderId_Outlet.text = String(OrderDetailsIs.object(forKey: "OrderUUID") as! Int)
                            }else{
                                self.lbl_Date_Outlet.text = "OrderId not available".localized()
                            }
                            // ProductName
                            if OrderDetailsIs.object(forKey: "ProductName") as? String != nil{
                                self.lbl_ProductName_Outlet.text = OrderDetailsIs.object(forKey: "ProductName") as! String
                            }else{
                                self.lbl_ProductName_Outlet.text = "Name not available".localized()
                            }
                            // ContactCountryCode
                            var countryCodeIs = ""
                            if OrderDetailsIs.object(forKey: "ContactCountryCode") as? String != nil{
                                countryCodeIs = OrderDetailsIs.object(forKey: "ContactCountryCode") as! String
                            }else if OrderDetailsIs.object(forKey: "ContactCountryCode") as? Int != nil{
                                countryCodeIs = String(OrderDetailsIs.object(forKey: "ContactCountryCode") as! Int)
                            }else{
                                countryCodeIs = "0"
                            }
                            // ContactNumber
                            var contactNumberIS = ""
                            if OrderDetailsIs.object(forKey: "ContactNumber") as? String != nil{
                                contactNumberIS = OrderDetailsIs.object(forKey: "ContactNumber") as! String
                            }else if OrderDetailsIs.object(forKey: "ContactNumber") as? Int != nil
                            {
                                contactNumberIS = String(OrderDetailsIs.object(forKey: "ContactNumber") as! Int)
                            }else{
                                contactNumberIS = "0"
                            }
                            if contactNumberIS != "0"{
                                self.lbl_Phone_Outlet.text = "\(countryCodeIs) \(contactNumberIS)"
                            }else{
                                self.lbl_Phone_Outlet.text = "Contact number not availble".localized()
                            }
                            // ShippingAddress
                            if OrderDetailsIs.object(forKey: "ShippingAddress") as? String != nil{
                                self.lbl_ShippingAddress_Outlet.text = OrderDetailsIs.object(forKey: "ShippingAddress") as! String
                            }else{
                                self.lbl_ShippingAddress_Outlet.text = "Shipping address not available".localized()
                            }
                            // BillingAddress
                            if OrderDetailsIs.object(forKey: "BillingAddress") as? String != nil{
                                self.lbl_BillingAddress_Outlet.text = OrderDetailsIs.object(forKey: "BillingAddress") as! String
                            }else{
                                self.lbl_BillingAddress_Outlet.text = "Billing address not available".localized()
                            }
                            // DeliveryStatus
                            if OrderDetailsIs.object(forKey: "DeliveryStatus") as? String != nil
                            {
                                self.lbl_DeliveryStatus_Outlet.text = OrderDetailsIs.object(forKey: "DeliveryStatus") as! String
                            }else{
                                self.lbl_DeliveryStatus_Outlet.text = "Delivery Status not available".localized()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getCollectionViewPagination(value:Bool,heightIs: CGFloat){
        self.vw_CollectionView_Outlet.isHidden = value
        self.height_CollectionView.constant = heightIs
    }
    
    // If page size is 1 there was header available
    func showingHeaderForPage(value:Bool,heightIs: CGFloat){
        self.lbl_PageCountHeader_Outlet.isHidden = value
        self.height_PageCountHeader_Outlet.constant = heightIs
    }
    
    // Hiding the Order Detail Page
    @objc func vw_Back_Action(){
        self.vw_OrderDetailView_Outlet.isHidden = true
    }
}

extension MyOderListVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if myOrderArray.count > 0{
            self.vw_Alert_Outlet.isHidden = true
            self.getCollectionViewPagination(value:false,heightIs: 100)
        }else{
            self.vw_Alert_Outlet.isHidden = false
            self.getCollectionViewPagination(value:true,heightIs: 0.0)
        }
        return self.myOrderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderListCell") as! MyOrderList
        cell.lbl_OrderName.text = self.myOrderArray[indexPath.row].getProductName()
        cell.lbl_OrderDate.text = self.myOrderArray[indexPath.row].getPurchaseDate()
        cell.lbl_OrderStatus.text = self.myOrderArray[indexPath.row].getDeliveryStatus()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        self.vw_OrderDetailView_Outlet.isHidden = false
        self.gettingMyOrderDetail(passOrderId:self.myOrderArray[indexPath.row].getOrderUUID())
        WoopraTrackingPage().trackEvent(mainMode:"Parent Order Detail Page",pageName:"Order Detail Page",actionTitle:"Checking Order Details")

    }
}

extension MyOderListVC : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.pageCountIS == 0{
            self.lbl_PageCountHeader_Outlet.isHidden = true
        }else{
            self.lbl_PageCountHeader_Outlet.isHidden = false
        }
        return self.pageCountIS
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paginationCell", for: indexPath) as! PaginationCell
        cell.lbl_PageNumber_Outlet.text = String(indexPath.row + 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.gettingMyOrderLists(pageNumber:indexPath.row + 1)
    }
}
