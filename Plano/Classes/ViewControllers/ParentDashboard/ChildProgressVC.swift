//
//  ChildProgressVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/15/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import JTMaterialSwitch
import KDCircularProgress
import Device
import PKHUD
import RealmSwift
import Kingfisher
import PopupDialog
import PageMenu
import SwiftyUserDefaults
import ObjectMapper

class ChildProgressVC: _BaseViewController, UIScrollViewDelegate{
    
    override var analyticsScreenName:String? {
        get {
            return "childprogress"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "childprogress"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    @IBOutlet weak var deviceTrackingViewHeight : NSLayoutConstraint!
    @IBOutlet weak var deviceTrackingPagerViewHeight : NSLayoutConstraint!
    
    //MARK: - Eye Score
    @IBOutlet weak var lblEyeScore : UILabel!
    @IBOutlet weak var lblEyeScoreDescription : UILabel!
    @IBOutlet weak var lblLastMonthsNoRecordsFound : UILabel!
    @IBOutlet weak var lblLastMonthScore : UILabel!
    @IBOutlet weak var lblTodayScore : UILabel!
    @IBOutlet weak var lblLastMonthTotalScore : UILabel!
    @IBOutlet weak var lblTodayTotalScore : UILabel!
    @IBOutlet weak var lblTodayNoRecordsFound : UILabel!
    @IBOutlet weak var lblLastMonthTitle : UILabel!
    @IBOutlet weak var lblTodayTitle : UILabel!
    @IBOutlet weak var overAllProgress : KDCircularProgress!
    @IBOutlet weak var todayProgress : KDCircularProgress!
    
    //MARK: - Device Tracking
    @IBOutlet weak var lblDeviceTrackingTitle : UILabel!
    @IBOutlet weak var lblDeviceTrackingDescription : UILabel!
    @IBOutlet weak var timeUsageView : UIView!
    var pageMenu : CAPSPageMenu!
    
    //MARK: - Myopia Progress
    @IBOutlet weak var lblMyopiaProgressTitle : UILabel!
    @IBOutlet weak var lblMyopiaProgressDescriptions : UILabel!
    @IBOutlet weak var lblLastRecordsTitle : UILabel!
    @IBOutlet weak var lblLastRecords : UILabel!
    @IBOutlet weak var btnAddRecord : UIButton!
    @IBOutlet weak var progressLoading : UIActivityIndicatorView!
    
    //MARK: - Rewards Outlets
    @IBOutlet weak var rewardsView : UIView!
    @IBOutlet weak var colChildRewards : UICollectionView!
    @IBOutlet weak var colMoreRewards : UICollectionView!
    @IBOutlet weak var lblRewardsTitle : UILabel!
    @IBOutlet weak var lblYourChildWishListTitle : UILabel!
    @IBOutlet weak var lblSuggestedItemsTitle : UILabel!
    @IBOutlet weak var btnPlanoShop : UIButton!
    @IBOutlet weak var childRewardsConstrait : NSLayoutConstraint!
    @IBOutlet weak var suggestionConstraint : NSLayoutConstraint!
    @IBOutlet weak var rewardsConstriant : NSLayoutConstraint!
    @IBOutlet weak var rewardsLoading : UIActivityIndicatorView!
    
    //MARK: - General Reports
    @IBOutlet weak var lblReportTitle : UILabel!
    @IBOutlet weak var lblReportDescription : UILabel!
    @IBOutlet weak var lblWeeklyTitle : UILabel!
    @IBOutlet weak var lblMonthlyTitle : UILabel!
    @IBOutlet weak var weeklySwitch : MaterialSwitch!
    @IBOutlet weak var monthlySwitch : MaterialSwitch!
    
    @IBOutlet weak var lblDigitalEyeStrain: UILabel!
    @IBOutlet weak var lblPlanoPoints: UILabel!
    @IBOutlet weak var lblDigitalEyeBehaviour: UILabel!
    @IBOutlet weak var lblNextDueDate: UILabel!
    @IBOutlet weak var lblLastCheckedDate: UILabel!
    @IBOutlet weak var lblEyeCheckupSummary: UILabel!
    @IBOutlet weak var lblNextDueTitle: UILabel!
    @IBOutlet weak var lblLastCheckedTitle: UILabel!
    
    @IBOutlet weak var lblDigitalEyeStrainGoal: UILabel!
    @IBOutlet weak var lblDigitalEyeBehaviourGoal: UILabel!
    //MARK: - Required Variables
    var childID : Int = 0
    var custSettingID : Int = 0
    var progressDate : String = ""
    var dateUsed : String = ""
    var comeFromNotification : Bool = false
    
    //MARK: - For notification, we need to scroll down to child requested items
    var isChildRequestNotifications : Bool = false
    
    //MARK: - Flags
    var isPresented : Bool = false
    var isErrorOccured : Bool = false
    var isFirstTimeRequest : Bool = false
    
    //MARK: - ViewModel and Additional Data
    var viewModel = ChildProgressViewModel()
    var wishList : Results<WishList>!
    var suggestedList : Results<SuggestedList>!
    
    let placeholderImage = UIImage(named: "iconAvatar")
    
    //MARK: - For Circular Progress Angle
    var todayProgressAngle : Int?
    var overallProgressAngle : Int?
    
    @IBOutlet weak var MyopiaViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblWarningHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblPlanoEyeInfo: UILabel!
    @IBOutlet weak var btnBookNow: UIButton! {
        didSet{
            btnBookNow.layer.cornerRadius = 3
            btnBookNow.clipsToBounds = true
        }
    }
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBarWithAttributes(navtitle: "Child's progress".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        
        colChildRewards.register(UINib(nibName : "ChildRewardsCell", bundle : nil), forCellWithReuseIdentifier: "ChildRewardsCell")
        
        initView()
        viewModelCallBack()
        setUpCollectionViews()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Child Progress Page",pageName:"Child Progress Page",actionTitle:"Child Progress Actions")
        
        removeLeftMenuGesture()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initMyopiaAndReports()
        initChildRewards()
        
        GetChildEyeCheck()
        GetChildEyeHealth()
        isPresented = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addLeftMenuGesture()
    }
    
    // MARK: - Initialization
    func initView(){
        
        viewModel.childID = childID
        viewModel.weeklyReportActive = "0"
        viewModel.monthlyReportActive = "0"
        
        lblDeviceTrackingTitle.text = "Device tracking".localized()
        lblDeviceTrackingDescription.text = "View your child's device use.".localized()
        
        btnAddRecord.setTitle("Update Checkup".localized(), for: .normal)
        btnPlanoShop.setTitle("Redeem Now".localized(), for: .normal)
        btnPlanoShop.setTitle("Redeem Now".localized(), for: .normal)
        
        lblEyeCheckupSummary.text = "Eye Checkup Summary".localized()
        lblLastCheckedTitle.text = "Last checked:".localized()
        lblNextDueTitle.text = "Next Due:".localized()
        lblRewardsTitle.text = "Rewards".localized()
        lblYourChildWishListTitle.text = "Your child has earned enough points for :".localized()
        
        lblReportTitle.text = "Report".localized()
        lblReportDescription.text = "We will send you an email of your child's overall performance and eye health.".localized()
        lblMonthlyTitle.text = "Monthly".localized()
        lblWeeklyTitle.text = "Weekly".localized()
        
        weeklySwitch.delegate = self
        weeklySwitch.tag = 0
        monthlySwitch.delegate = self
        monthlySwitch.tag = 1
        
        deviceTrackingViewHeight.constant = 0
        deviceTrackingPagerViewHeight.constant = 0
        self.scrollView.layoutIfNeeded()
        
        //setUpDeviceTrackingView()
        
    }
    
    func setUpCollectionViews(){
        
        let horizontalPagingLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        horizontalPagingLayout.scrollDirection = .horizontal
        if Device.size() >= .screen7_9Inch{
            horizontalPagingLayout.sectionInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        }else{
            horizontalPagingLayout.sectionInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        }
        
        horizontalPagingLayout.itemSize = CGSize(width: 101, height: 101)
        horizontalPagingLayout.minimumInteritemSpacing = 0
        horizontalPagingLayout.minimumLineSpacing = 10
        
        let suggestionPagingLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        suggestionPagingLayout.scrollDirection = .horizontal
        
        if Device.size() >= .screen7_9Inch{
            suggestionPagingLayout.sectionInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        }else{
            suggestionPagingLayout.sectionInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        }
        
        suggestionPagingLayout.itemSize = CGSize(width: 101, height: 101)
        suggestionPagingLayout.minimumInteritemSpacing = 0
        suggestionPagingLayout.minimumLineSpacing = 10
        
        colChildRewards.delegate = self
        colChildRewards.dataSource = self
        
        colChildRewards.collectionViewLayout = horizontalPagingLayout
        colChildRewards.showsHorizontalScrollIndicator = false
        colChildRewards.isPagingEnabled = false
        
    }
    
    func initChildProgress(){
        viewModel.progressDate = Date().toStringWith(format: "yyyy-MM-dd")
        viewModel.dateUsed = Date().toStringWith(format: "yyyy-MM-dd")
        
        viewModel.getProgress(success: { _ in
            
            guard let childProgressObj : ChildProgress = ChildProgress.getChildProgressObj() else{
                return
            }
            
            self.todayProgressAngle = self.progresstoAngle(progress: childProgressObj.todayProgress)
            
            if childProgressObj.todayProgress == "0"{
                self.lblTodayNoRecordsFound.isHidden = false
                self.lblTodayNoRecordsFound.text = "No Records Found".localized()
            }else{
                self.lblTodayNoRecordsFound.isHidden = true
            }
            
            self.overAllProgress.animate(fromAngle: 0, toAngle: Double(self.overallProgressAngle!), duration: 0.3, completion: nil)
            self.todayProgress.animate(fromAngle: 0, toAngle: Double(self.todayProgressAngle!), duration: 0.3, completion: nil)
            
            if self.isChildRequestNotifications{
                let schedulePoint : CGPoint = self.scrollView.convert(.zero, from: self.rewardsView)
                self.scrollView.setContentOffset(schedulePoint, animated: true)
                self.isChildRequestNotifications = false
            }
            
        }) { (errorMessage) in
            
            self.overAllProgress.angle = 0
            self.todayProgress.angle = 0
            self.isErrorOccured = true
            
            self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
        }
    }
    
    func initMyopiaAndReports(){
        
        viewModel.getMyopiaLastRecordsAndReport(success: { _ in
            
            guard let myopiaAndReportData : ReportAndMyopiaData = ReportAndMyopiaData.getReportsAndMyopia() else{
                return
            }
            
            if myopiaAndReportData.myopiaDate != ""{
                
                // create dateFormatter with UTC time format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                if let myopiaDate = dateFormatter.date(from: myopiaAndReportData.myopiaDate){
                    
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    dateFormatter.timeZone = TimeZone.current
                    
                }
                
                //                print("Myopia Date : \(myopiaAndReportData.myopiaDate)")
                //
                //                let dateFormatter = DateFormatter()
                //                dateFormatter.dateFormat = "yyyy-MM-dd"
                //
                //                let myopiaDate = dateFormatter.date(from: myopiaAndReportData.myopiaDate)
                //
                //                dateFormatter.dateFormat = "dd MMM yyyy"
                //
                //                self.lblLastRecords.text = dateFormatter.string(from: myopiaDate!)
            }
            
            if myopiaAndReportData.weeklyReportActive != "" && myopiaAndReportData.monthlyReportActive != ""{
                
                self.weeklySwitch.isOn(state: myopiaAndReportData.weeklyReportActive.toBool()!)
                self.viewModel.weeklyReportActive = String(describing: myopiaAndReportData.weeklyReportActive.toIntFlag()!)
                self.monthlySwitch.isOn(state: myopiaAndReportData.monthlyReportActive.toBool()!)
                self.viewModel.monthlyReportActive = String(describing: myopiaAndReportData.monthlyReportActive.toIntFlag()!)
                
            }
            
        }) { (errorMessage) in
            
            self.weeklySwitch.setState(state: false)
            self.monthlySwitch.setState(state: false)
            
            self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            
        }
        
    }
    
    func initChildRewards(){
        
        viewModel.getRewards(success: { _ in
            
            self.wishList = WishList.getWishList()
            self.suggestedList = SuggestedList.getSuggestedList()
            
            if self.wishList.count == 0 && self.suggestedList.count != 0{
                
                self.childRewardsConstrait.constant = 0
                self.rewardsConstriant.constant = 0
                
                UIView.transition(with: self.scrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.scrollView.layoutIfNeeded()
                    
                }, completion: nil)
                
                
            }else if self.suggestedList.count == 0 && self.wishList.count != 0{
                
                self.rewardsConstriant.constant = 290
                
                UIView.transition(with: self.scrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.scrollView.layoutIfNeeded()
                    
                }, completion: nil)
                
            }else if self.wishList.count == 0 && self.suggestedList.count == 0{
                
                self.colChildRewards.collectionViewLayout.invalidateLayout()
                self.childRewardsConstrait.constant = 0
                self.rewardsConstriant.constant = 0
                
                UIView.transition(with: self.scrollView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.colChildRewards.reloadData()
                    self.scrollView.layoutIfNeeded()
                }, completion: nil)
                
            }else{
                
                self.rewardsConstriant.constant = 290
                
                UIView.transition(with: self.colChildRewards, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.colChildRewards.reloadData()
                    
                }, completion: nil)
                
            }
            
        }) { (errorMessage) in
            print("Error getting child rewards and suggested list")
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func GetChildEyeHealth() {
        
        if let parentProfile = ProfileData.getProfileObj() {
            //let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
            
            let request = ChildEyeHealthRequest(email: parentProfile.email, childId: String(childID), accessToken: parentProfile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ChildApiManager.sharedInstance.getChildEyeHealth(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ChildEyeHealthResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            
                            self.lblDigitalEyeBehaviour.text = String(response.DigitalEyeBehaviour)
                            self.lblDigitalEyeStrain.text = String(response.DigitalEyeStrain)
                            self.lblPlanoPoints.text = String(response.PlanoPoints)
                            self.lblDigitalEyeStrainGoal.text = "Goal: " + String(response.DigitalEyeStrainGoal)
                            self.lblDigitalEyeBehaviourGoal.text = "Goal: " + String(response.DigitalEyeBehaviourGoal)
                        }
                    }
                })
            }
        }
        
//        viewModel.getChildEyeHealth { (response) in
//
//            if (response.jsonObject != nil) {
//                let dict = response.jsonObject as! NSDictionary
//                let dictData = dict.value(forKey: "Data")
//                let DigitalEyeBehaviour = (dictData as AnyObject).value(forKey: "DigitalEyeBehaviour") as! Int
//                let DigitalEyeStrain = (dictData as AnyObject).value(forKey: "DigitalEyeStrain") as! Int
//
//                let DigitalEyeBehaviourGoal = (dictData as AnyObject).value(forKey: "DigitalEyeBehaviourGoal") as! Int
//                let DigitalEyeStrainGoal = (dictData as AnyObject).value(forKey: "DigitalEyeStrainGoal") as! Int
//                let PlanoPoints = (dictData as AnyObject).value(forKey: "PlanoPoints") as! Int
//
//                self.lblDigitalEyeBehaviour.text = String(DigitalEyeBehaviour)
//                self.lblDigitalEyeStrain.text = String(DigitalEyeStrain)
//                self.lblPlanoPoints.text = String(PlanoPoints)
//                self.lblDigitalEyeStrainGoal.text = "Goal: " + String(DigitalEyeStrainGoal)
//                self.lblDigitalEyeBehaviourGoal.text = "Goal: " + String(DigitalEyeBehaviourGoal)
//            }
//        }
    }
    
    func GetChildEyeCheck() {
        
        if let parentProfile = ProfileData.getProfileObj() {
            //let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
            
            let request = ChildEyeHealthRequest(email: parentProfile.email, childId: String(childID), accessToken: parentProfile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ChildApiManager.sharedInstance.getChildEyeCheck(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ChildEyeCheckResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if (Int(response.WarningLevel) == 0) {
                                self.lblPlanoEyeInfo.textColor = UIColor.black
                            } else if (Int(response.WarningLevel) == 1) {
                                self.lblPlanoEyeInfo.textColor = UIColor.red
                            }
                            
                            if (Int(response.IsShowMessage) == 0) {
                                self.lblPlanoEyeInfo.isHidden = true
                                self.MyopiaViewHeightConstraint.constant = 330
                                self.lblWarningHeightConstraint.constant = 10
                            } else if (Int(response.IsShowMessage) == 1) {
                                self.lblPlanoEyeInfo.isHidden = false
                                self.MyopiaViewHeightConstraint.constant = 375
                                self.lblWarningHeightConstraint.constant = 40
                            }
                            
                            self.lblLastCheckedDate.text = response.PreviousEyeVisitDate
                            self.lblNextDueDate.text = response.UpcomingEyeVisitDate
                            self.lblPlanoEyeInfo.text = response.Description
                        }
                    }
                })
            }
        }
        
//        viewModel.getChildEyeCheck { (response) in
//
//            if (response.jsonObject != nil) {
//                let dict = response.jsonObject as! NSDictionary
//                let dictData = dict.value(forKey: "Data")
//                let PreviousEyeVisitDate = (dictData as AnyObject).value(forKey: "PreviousEyeVisitDate") as! String
//                let UpcomingEyeVisitDate = (dictData as AnyObject).value(forKey: "UpcomingEyeVisitDate") as! String
//                let WarningLevel = (dictData as AnyObject).value(forKey: "WarningLevel") as! String
//                let Description = (dictData as AnyObject).value(forKey: "Description") as! String
//                let IsShowMessage = (dictData as AnyObject).value(forKey: "IsShowMessage") as! String
//
//                if (Int(WarningLevel) == 0) {
//                    self.lblPlanoEyeInfo.textColor = UIColor.black
//                } else if (Int(WarningLevel) == 1) {
//                    self.lblPlanoEyeInfo.textColor = UIColor.red
//                }
//
//                if (Int(IsShowMessage) == 0) {
//                    self.lblPlanoEyeInfo.isHidden = true
//                    self.MyopiaViewHeightConstraint.constant = 330
//                    self.lblWarningHeightConstraint.constant = 10
//                } else if (Int(IsShowMessage) == 1) {
//                    self.lblPlanoEyeInfo.isHidden = false
//                    self.MyopiaViewHeightConstraint.constant = 375
//                    self.lblWarningHeightConstraint.constant = 40
//                }
//
//                self.lblLastCheckedDate.text = PreviousEyeVisitDate
//                self.lblNextDueDate.text = UpcomingEyeVisitDate
//                self.lblPlanoEyeInfo.text = Description
//            }
//        }
    }
    
    // MARK: - CallBack
    func viewModelCallBack() {
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.progressBeforeApiCall = {
            self.progressLoading.startAnimating()
        }
        
        viewModel.rewardsBeforeApiCall = {
            self.lblYourChildWishListTitle.isHidden = true
            self.btnPlanoShop.isHidden = true
            self.rewardsLoading.startAnimating()
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.progressAfterApiCall = {
            self.progressLoading.stopAnimating()
        }
        
        viewModel.rewardsAfterApiCall = {
            self.lblYourChildWishListTitle.isHidden = false
            self.btnPlanoShop.isHidden = false
            self.rewardsLoading.stopAnimating()
        }
    }
    
    @IBAction func btnAddRecordTapped(_ sender: Any) {
        if let vc = UIStoryboard.MyopiaProgress() as? MyopiaProgressVC {
            vc.parentVC = self
            vc.childID = childID
            vc.comeFromProgress = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnPlanoShopTapped(_ sender: Any) {
        if let vc = UIStoryboard.Wallet() as? ParentWalletVC{
            vc.parentVC = self
            vc.comeFromProgress = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnBookNowClicked() {
        guard let url = URL(string: "https://eyecareplano.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK: - Device Tracking
    func setUpDeviceTrackingView(){
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let yesterdayUsageProgressVC : UsageProgressVC = UIStoryboard.UsageProgress() as! UsageProgressVC
        yesterdayUsageProgressVC.title = "Yesterday".localized()
        yesterdayUsageProgressVC.childID = childID
        yesterdayUsageProgressVC.dateUsed = Date().getYesterday().toStringWith(format: "yyyy-MM-dd")
        controllerArray.append(yesterdayUsageProgressVC)
        
        let todayUsageProgressVC : UsageProgressVC = UIStoryboard.UsageProgress() as! UsageProgressVC
        todayUsageProgressVC.title = "Today".localized()
        todayUsageProgressVC.childID = childID
        todayUsageProgressVC.dateUsed = Date().toStringWith(format: "yyyy-MM-dd")
        controllerArray.append(todayUsageProgressVC)
        
        // Customize page menu
        var parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(0.0),
            .scrollMenuBackgroundColor(Color.Cyan.instance()),
            .viewBackgroundColor(UIColor.white),
            .bottomMenuHairlineColor(UIColor.clear),
            .selectionIndicatorColor(UIColor.clear),
            .menuHeight(50.0),
            .menuMargin(0.0),
            .selectedMenuItemLabelColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor(hexString: "2B9CA8")!),
            .menuItemFont(FontBook.Bold.of(size: 16.0)),
            .useMenuLikeSegmentedControl(false),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(7),
            .menuItemSeparatorPercentageHeight(0.1),
            .iconIndicator(true),
            .iconIndicatorView(self.getIndicatorView())
        ]
        
        if Device.size() == .screen3_5Inch || Device.size() == .screen4Inch{
            parameters[6] = .menuMargin(35.0)
        }else if Device.size() == .screen4_7Inch{
            parameters[6] = .menuMargin(55.0)
        }else{
            parameters[6] = .menuMargin(65.0)
        }
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x:0.0, y:0.0, width:self.timeUsageView.frame.width, height:self.timeUsageView.frame.height), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.timeUsageView.addSubview(pageMenu!.view)
        
        pageMenu.moveToPage(1)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getTimeUsage"), object: nil)
    }
    
    // Set up custom indicator view
    private func getIndicatorView()->UIView{
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 7))
        imgView.image = UIImage(named: "iconTriangle")
        imgView.contentMode = .scaleAspectFill
        return imgView
    }
    
    // Score to Degree Convertion [Use it for Circular Angle]
    func progresstoAngle(progress : String) -> Int{
        var angle = 0
        switch progress{
        case "1":
            angle = 30
            break
        case "2":
            angle = 60
            break
        case "3":
            angle = 120
            break
        case "4":
            angle = 150
            break
        case "5":
            angle = 180
            break
        case "6":
            angle = 210
            break
        case "7":
            angle = 240
            break
        case "8":
            angle = 300
            break
        case "9":
            angle = 330
            break
        case "10":
            angle = 360
            break
        default :
            break
        }
        return angle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Popups
    func showCompletionAlert(server_message : String, isSuccess : Bool){
        
        var title = ""
        
        if isSuccess{
            title = "Successful".localized()
        }
        
        let message = server_message.localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.initMyopiaAndReports()
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
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMoreSettings"{
            let destination = segue.destination as! CustomiseSettingsVC
            destination.childID = childID
        }
    }
    
    
}

// MARK: - Page Menu Delegate
extension ChildProgressVC : CAPSPageMenuDelegate{
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getTimeUsage"), object: nil)
    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        timeUsageView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension ChildProgressVC : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colChildRewards{
            if wishList == nil || wishList.count == 0{
                return 0
            }
            return wishList.count
        }else{
            if suggestedList == nil || suggestedList.count == 0{
                return 0
            }
            return suggestedList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == colChildRewards{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildRewardsCell", for: indexPath) as! ChildRewardsCell
            
            let childWishList = wishList[indexPath.row]
            
            if childWishList.productImage.isEmpty{
                cell.imgItem.image = UIImage(named:"AppIcon.png")
            }else{
                cell.imgItem.kf.setImage(with: URL(string: childWishList.productImage), completionHandler:{
                    (image, error, cacheType, imageUrl) in
                    if error != nil{
                        cell.imgItem.image = UIImage(named:"AppIcon.png")
                    }
                })
            }
            
            // remove this line after safe break
            guard let expireDate : Date = childWishList.expiry else{
                return cell
            }
            cell.lblStatus.text = cell.setStatusLabel(date: Date(), expireDate: expireDate)
            
            return cell
            
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildRewardsCell", for: indexPath) as! ChildRewardsCell
            
            let suggested = suggestedList[indexPath.row]
            
            if suggested.productImage.isEmpty{
                cell.imgItem.image = UIImage(named:"AppIcon.png")
            }else{
                cell.imgItem.kf.setImage(with: URL(string: suggested.productImage), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error != nil{
                        cell.imgItem.image = UIImage(named:"AppIcon.png")
                    }
                })
            }
            
            // remove this line after safe break
            guard let expireDate : Date = suggested.expiry else{
                return cell
            }
            cell.lblStatus.text = cell.setStatusLabel(date: Date(), expireDate: expireDate)
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colChildRewards{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildRewardsCell", for: indexPath) as! ChildRewardsCell
            let selectedWishList = wishList[indexPath.row]
            cell.backgroundColor = UIColor.lightGray
            UIView.animate(withDuration: 0.1) {
                cell.backgroundColor = UIColor.white
                if Device.size() >= .screen7_9Inch{
                    if let vc = UIStoryboard.WalletDetailiPad() as? ParentWalletDetailVC {
                        vc.parentVC = self
                        vc.productID = selectedWishList.productID
                        vc.modalPresentationStyle = .overCurrentContext
                        vc.modalTransitionStyle = .crossDissolve
                        vc.isViewPresented = true
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                }else{
                    if let vc = UIStoryboard.WalletDetail() as? ParentWalletDetailVC {
                        vc.parentVC = self
                        vc.productID = selectedWishList.productID
                        vc.modalPresentationStyle = .overCurrentContext
                        vc.modalTransitionStyle = .crossDissolve
                        vc.isViewPresented = true
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                }
            }
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildRewardsCell", for: indexPath) as! ChildRewardsCell
            let selectedSuggestedList = suggestedList[indexPath.row]
            cell.backgroundColor = UIColor.lightGray
            UIView.animate(withDuration: 0.1) {
                cell.backgroundColor = UIColor.white
                
                if Device.size() >= .screen7_9Inch{
                    if let vc = UIStoryboard.WalletDetailiPad() as? ParentWalletDetailVC {
                        vc.parentVC = self
                        vc.productID = selectedSuggestedList.productID
                        vc.modalPresentationStyle = .overCurrentContext
                        vc.modalTransitionStyle = .crossDissolve
                        vc.isViewPresented = true
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                }else{
                    if let vc = UIStoryboard.WalletDetail() as? ParentWalletDetailVC {
                        vc.parentVC = self
                        vc.productID = selectedSuggestedList.productID
                        vc.modalPresentationStyle = .overCurrentContext
                        vc.modalTransitionStyle = .crossDissolve
                        vc.isViewPresented = true
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                }
            }
        }
    }
    
}

// MARK: - MaterialSwitchDelegates
extension ChildProgressVC : MaterialSwitchDelegate{
    
    func switchDidChangeState(currentSwitch: MaterialSwitch, currentState: MaterialSwitchState) {
        
        if currentSwitch.tag == 0{
            viewModel.weeklyReportActive = String(currentState.rawValue)
            viewModel.updateReports(success: { (message) in
                self.showCompletionAlert(server_message: message, isSuccess : true)
            }) { (errorMessage) in
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }
        }else if currentSwitch.tag == 1{
            viewModel.monthlyReportActive = String(currentState.rawValue)
            viewModel.updateReports(success: { (message) in
                self.showCompletionAlert(server_message: message, isSuccess : true)
            }) { (errorMessage) in
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }
        }
    }
    
    func switchDidTouched(currentSwitch: MaterialSwitch, currentState: MaterialSwitchState) {
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
