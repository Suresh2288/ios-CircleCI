//
//  MyopiaProgressVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import ACTabScrollView
import PKHUD
import RealmSwift
import PopupDialog

// Created delegate for you
protocol MyopiaProgressVCDelegate {
    func giveChildID(data: AnyObject!)
}

class MyopiaProgressVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "myopia"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "myopia"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    // Those data can get from other screen
    var childID : Int = 0
    var yearFrom : Int = 0
    var yearTo : Int = 0
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var txtDate: SkyFloatingLabelTextField!
    @IBOutlet weak var dateView : UIView!
    @IBOutlet weak var datePicker : UIDatePicker!
    @IBOutlet weak var imgArrow : UIImageView!
    
    @IBOutlet weak var txtLeftEye: SkyFloatingLabelTextField!
    @IBOutlet weak var txtRightEye: SkyFloatingLabelTextField!
    @IBOutlet weak var leftEyeViewHolder: UIView!
    @IBOutlet weak var rightEyeViewHolder: UIView!
    
    @IBOutlet weak var imgLeftEye : UIImageView!
    @IBOutlet weak var imgRightEye : UIImageView!
    
    @IBOutlet weak var pickerheight : NSLayoutConstraint!
    @IBOutlet weak var resultViewHeight : NSLayoutConstraint!
    
    @IBOutlet weak var chartPager : ACTabScrollView!
    @IBOutlet weak var noRecordsView : UIView!
    
    @IBOutlet weak var myopiaProgressScrollView : UIScrollView!
    
    @IBOutlet weak var btnAddRecords : UIButton!
    
    @IBOutlet weak var dateBefore: UIView!
    @IBOutlet weak var btnDateBefore : UIButton!
    
    var comeFromPicker : Bool = false
    let nc = NotificationCenter.default
    
    var activePicker:UIView?
    
    // MARK: - Data model
    var chartViewControllers: [UIView] = []
    var yearPagerTitle : [String] = []
    var myopiaProgressList : Results<MyopiaProgressList>!
    var viewModel = MyopiaProgressViewModel()
    
    // MARK: - Flags and Constant
    var isDatePickerShown : Bool = false
    var isSuccessfullyUpdated : Bool = false
    var isFirstTimeAddRecord : Bool = false
    let eyeDegreeLimitLength = 4
    var comeFromProgress = false
    
    var isPresented : Bool = false
    var isValidLeftEye : Bool = false
    var isValidRightEye : Bool = false

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Myopia View Did Load")
        
        title = "Myopia Progress".localized()
        customizeNavBar()
        UIApplication.shared.statusBarStyle = .lightContent
        
        initMyopiaView()
        initFloatingLabels()
        viewModelCallBack()
        
        
        viewModel.childID = childID
        let currentdate = Date()
        let calendar = Calendar.current
        viewModel.fromYear = Int((calendar.date(byAdding: .year, value: -4, to: currentdate)?.year)!)
        viewModel.toYear = calendar.component(.year, from: currentdate)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Myopia Progress Page",pageName:"Myopia Progress Page",actionTitle:"Child Myopia Progress")
        
        removeLeftMenuGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if comeFromPicker{
            comeFromPicker = false
        }else{
            self.getMyopiaProgress()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addLeftMenuGesture()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if comeFromProgress == true{
            setUpNavBarWithAttributes(navtitle: "Child's progress".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16.0))
        }
    }
    
    // MARK: - Initialization
    func initFloatingLabels() {
        
        configFloatingLabel(txtDate)
        configFloatingLabel(txtLeftEye)
        configFloatingLabel(txtRightEye)
        txtDate.delegate = self
        txtLeftEye.delegate = self
        txtRightEye.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showLeftEyePicker(_:)))
        leftEyeViewHolder.addGestureRecognizer(tap)
        txtLeftEye.isEnabled = false
        
        let tapRight = UITapGestureRecognizer(target: self, action: #selector(showRightEyePicker(_:)))
        rightEyeViewHolder.addGestureRecognizer(tapRight)
        txtRightEye.isEnabled = false
    }
    
    func initMyopiaView(){
        
        // Hide the picker at first
        pickerheight.constant = 0
        resultViewHeight.constant = 441 - 150
        
        dateBefore.isHidden = true
        chartPager.isHidden = true
        noRecordsView.isHidden = true
        
        if let profile = ChildProfile.getChildProfileById(childId: String(childID)){
            datePicker.minimumDate = profile.dob
        }
        datePicker.maximumDate = Date()
        
        chartPager.defaultPage = 0
        chartPager.dataSource = self
        chartPager.delegate = self
        chartPager.cachedPageLimit = 0
        
        // Setting NumberPad and Adding Done Toolbar button
        txtRightEye.keyboardType = .numberPad
        txtLeftEye.keyboardType = .numberPad
        //addDoneButtonOnKeyboard()
        
        // Setting Gesture Recognizer
        let datePickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(MyopiaProgressVC.setUpDatePicker))
        dateView.addGestureRecognizer(datePickerTapGesture)
        
        //let scrollViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(MyopiaProgressVC.dismissNumberPad))
        //myopiaProgressScrollView.addGestureRecognizer(scrollViewTapGesture)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        txtDate.text = strDate
        viewModel.pickedDate = datePicker.date
        
    }
    
    // MARK: - Myopia [No Records]
    func showNoMyopiaRecords(){
        
        chartPager.isHidden = true
        noRecordsView.isHidden = false
        dateBefore.isHidden = true
        
        // Setting txtDate to nil to work validation error callback if user didn't choose a date
        txtDate.text = nil
        
        txtLeftEye.text = ""
        txtRightEye.text = ""
        
        // The button should be gray if there is no records. Used at callbacks
        isFirstTimeAddRecord = true
        
        btnAddRecords.isEnabled = false
        btnAddRecords.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
    }
    
    // MARK: - Myopia [With Records]
    func showMyopiaRecords(){
        // Setting the current date to txtDate
        
        // hide validation error view cuase current date will be set as default
        dateBefore.isHidden = true
        
        // set current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let strDate = dateFormatter.string(from: Date())
        txtDate.text = strDate
        
        // since it will use for update purpose, it should be empty
        txtLeftEye.text = ""
        txtRightEye.text = ""
        
        chartPager.isHidden = false
        noRecordsView.isHidden = true
        
        btnAddRecords.isEnabled = false
        btnAddRecords.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
        
        viewModel.selectedLeftEye = nil
        viewModel.selectedRightEye = nil

    }
    
    // MARK: - Myopia Progress ViewPager
    func setUpViewPager(){
        
        
        // Here we assign yearPagerTitle from realm
        // yearPagerTitle = ["Overview" + Realm distinct record by year]
        
        let realm = try! Realm()
        let yearlistFromMyopia = Set(realm.objects(MyopiaProgressList.self).value(forKey: "year") as! [String])
        yearPagerTitle = Array(yearlistFromMyopia.sorted())
        let yearlistFromMyopiaSummary = Set(realm.objects(MyopiaProgressSummary.self).value(forKey: "peroid") as! [String])
        
        // Since the list only return year, we have to add 'Overview' as additional
        yearPagerTitle.insert("Overview", at: 0)
        
        if isSuccessfullyUpdated{
            chartViewControllers.removeAll()
            isSuccessfullyUpdated = false
        }
        
        for title in self.yearPagerTitle {
            // here we create view controller for pager
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChartsVC") as! ChartsVC
            vc.chartsTitle = title
            if title == "Overview"{
                vc.isOverView = true
                vc.yearsData = Array(yearlistFromMyopiaSummary.sorted())
            }else{
                vc.isOverView = false
            }
            // you can also assign data here
            
            self.addChild(vc) // don't forget, it's very important
            self.chartViewControllers.append(vc.view)
            
        }
        self.chartPager.reloadData()
    }
    
    // MARK: - Callbacks
    func viewModelCallBack() {
        
        viewModel.isLeftEyeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                self?.isValidLeftEye = validationObj.isValid
                if (validationObj.isValid){
                    me.txtLeftEye.errorMessage = ""
                    me.imgLeftEye.image = UIImage(named: "iconLeftEyeSelected")
                }else{
                    me.imgLeftEye.image = UIImage(named: "iconLeftEye")
                    me.txtLeftEye.errorMessage = validationObj.message()
                }
            }
        }
        
        viewModel.isRightEyeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                self?.isValidRightEye = validationObj.isValid
                if (validationObj.isValid){
                    me.imgRightEye.image = UIImage(named: "iconRightEyeSelected")
                    me.txtRightEye.errorMessage = ""
                }else{
                    me.imgRightEye.image = UIImage(named: "iconRightEye")
                    me.txtRightEye.errorMessage = validationObj.message()
                }
            }
        }
        
        viewModel.isPickedDateValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if(validationObj.isValid){
                    me.btnDateBefore.setTitleColor(Color.DarkGrey.instance(), for: .normal)
                }else{
                    me.btnDateBefore.setTitleColor(Color.Red.instance(), for: .normal)
                }
            }
        }
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.isMyopiaProgressValid = {[weak self](valid:Bool) in
            if (valid && (self?.isValidLeftEye)! && (self?.isValidRightEye)!){
                self?.btnAddRecords.isEnabled = true
                self?.btnAddRecords.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
            }else{
                // if there is no record added, button should gray for disable state
                if (self?.isFirstTimeAddRecord)!{
                    self?.btnAddRecords.setBackgroundImage(UIImage(named : "buttonBgGray"), for: .normal)
                }else{
                    // if there were records added, button should static for disable state
                    self?.btnAddRecords.setBackgroundImage(UIImage(named : "buttonBgStatic"), for: .normal)
                }
            }
        }
        
        viewModel.leftEyeUpdatedCallback = {[weak self]() in
            self?.txtLeftEye.text = self?.viewModel.selectedLeftEye?.EyeDegreeDescription
        }
        viewModel.rightEyeUpdatedCallback = {[weak self]() in
            self?.txtRightEye.text = self?.viewModel.selectedRightEye?.EyeDegreeDescription
        }
        
    }
    
    // MARK: - Get Myopia
    
    func getMyopiaProgress(){
        
        viewModel.getMyopiaProgressRecord(completed: { (hasMyopiaProgressRecords) in
            if hasMyopiaProgressRecords{
                
                self.viewModel.getMyopiaProgressSummary(completed: { (hasSummary) in
                    
                    self.showMyopiaRecords()
                    self.setUpViewPager()
                    
                }, failure: { (errorMessage,errorCode) in
                    if self.isPremiumValid(errorCode: Int(errorCode)){
                        self.showAlert(errorMessage)
                    }else{
                        self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL".localized(), "SIGN UP".localized(), callBackOne: {
                            _ = self.navigationController?.popViewController(animated: true)
                        }, callBackTwo: {
                            self.goToPremium()
                        })
                    }
                })
            }else{
                self.showNoMyopiaRecords()
            }
        },failure: { (errorMessage,errorCode) in
            if self.isPremiumValid(errorCode: Int(errorCode)){
                self.showAlert(errorMessage)
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL".localized(), "SIGN UP".localized(), callBackOne: {
                    _ = self.navigationController?.popViewController(animated: true)
                }, callBackTwo: {
                    self.goToPremium()
                })
            }
        })
        
    }
    
    // MARK: - Left Eye and Right Eye Picker
    
    @objc func showLeftEyePicker(_ tap:UITapGestureRecognizer){
        activePicker = leftEyeViewHolder
        showEyePicker(viewModel.selectedLeftEye)
    }
    
    @objc func showRightEyePicker(_ tap:UITapGestureRecognizer){
        activePicker = rightEyeViewHolder
        showEyePicker(viewModel.selectedRightEye)
    }
    
    func showEyePicker(_ selectedObj:ListEyeDegrees?){
        comeFromPicker = true
        let vc:EyeDegreeListVC = UIStoryboard.EyeDegreeList() as! EyeDegreeListVC
        vc.delegate = self
        vc.selectedObj = selectedObj
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Update Myopia
    
    @IBAction func btnAddRecordsClicked(_ sender: Any) {
        
        viewModel.updateMyopiaProgress(success: { (validationObj:ValidationObj) in
            
            self.updatedProgressSuccessfully()
            WoopraTrackingPage().trackEvent(mainMode:"Parent Myopia Progress Page",pageName:"Myopia Progress Page",actionTitle:"Myopia Report Added")
            
        }) { (validationObj:ValidationObj,errorCode) in
            
            if self.isPremiumValid(errorCode: Int(errorCode)){
                if let msg = validationObj.message() {
                    self.showAlert(msg)
                }
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL".localized(), "SIGN UP".localized(), callBackOne: {
                    _ = self.navigationController?.popViewController(animated: true)
                }, callBackTwo: {
                    self.goToPremium()
                })
            }
            
            
        }
    }
    
    // MARK: - DatePicker Implementation
    
    @IBAction func btnDatePickerBeforeClicked(_ sender: Any) {
        setUpDatePicker()
    }
    
    @objc func setUpDatePicker(){
        
        if isDatePickerShown {
            // close
            self.pickerheight.constant = 0
            self.resultViewHeight.constant = 441 - 150
        }else{
            // open
            self.pickerheight.constant = 150
            self.resultViewHeight.constant = 441
        }
        
        isDatePickerShown = !isDatePickerShown
        datePicker.alpha = isDatePickerShown ? 1 : 0
        
        UIView.animate(withDuration: 0.3) {
            self.imgArrow.transform = self.isDatePickerShown ? CGAffineTransform(rotationAngle: CGFloat.pi) : CGAffineTransform.identity
            self.myopiaProgressScrollView.layoutIfNeeded()
        }
    }
    
    @IBAction func datePickerValueChanged(sender: AnyObject) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        
        if ChildProfile.isLessThanDOB(inputDate: datePicker.date, childID: String(childID)){
            btnAddRecords.isEnabled = false
            txtDate.text = strDate
            return
        }
        
        txtDate.text = strDate
        viewModel.pickedDate = datePicker.date
        self.dateBefore.isHidden = true
        self.txtDate.isHidden = false
    }
    
    // MARK: - Done Button on ToolBar of NumberPad
    
    //    func addDoneButtonOnKeyboard(){
    //
    //        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    //        doneToolbar.barStyle = UIBarStyle.default
    //
    //        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    //        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MyopiaProgressVC.doneButtonAction))
    //
    //        var items = [UIBarButtonItem]()
    //        items.insert(flexSpace, at: 0)
    //        items.insert(done, at: 1)
    //
    //        doneToolbar.items = items
    //        doneToolbar.sizeToFit()
    //
    //        txtLeftEye.inputAccessoryView = doneToolbar
    //        txtRightEye.inputAccessoryView = doneToolbar
    //    }
    //
    //    // check valid on keyboard dismissal
    //    func checkKeyboardDismissValidation(){
    //        if let leftEye = txtLeftEye.text{
    //            updateViewModel(txtLeftEye, leftEye)
    //        }else if let rightEye = txtRightEye.text{
    //            updateViewModel(txtRightEye, rightEye)
    //        }
    //        view.endEditing(true)
    //    }
    //
    //    // MARK: - Dismiss NumberPad
    //
    //    func doneButtonAction(){
    //        checkKeyboardDismissValidation()
    //    }
    //
    //    func dismissNumberPad(){
    //        checkKeyboardDismissValidation()
    //    }
    
    // MARK: - Utility
    
    func updatedProgressSuccessfully(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Updated".localized()
        let message = "Your eye test record has been added.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.isSuccessfullyUpdated = true
            self.getMyopiaProgress()
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
        self.present(popup, animated: animated, completion: nil)
    }
    
}

// MARK: - UITextFieldDelegate
extension MyopiaProgressVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // For limiting degree to 4 digits only
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= eyeDegreeLimitLength
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateViewModel(textField, textField.text)
    }
    
    func updateViewModel(_ textField:UITextField, _ text:String?) {
        if let date = txtDate.text{
            if date == ""{
                viewModel.pickedDate = nil
            }else{
                viewModel.pickedDate = datePicker.date
            }
        }
    }
    
    func goToPremium(){
        if let vc = UIStoryboard.Premium() as? PremiumVC{
            vc.parentVC = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - ACTabScrollView

extension MyopiaProgressVC: ACTabScrollViewDataSource, ACTabScrollViewDelegate{
    
    // MARK: ACTabScrollViewDataSource
    func numberOfPagesInTabScrollView(_ tabScrollView: ACTabScrollView) -> Int {
        return yearPagerTitle.count
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        
        let label = UILabel()
        label.text = String(describing: yearPagerTitle[index])
        label.font = FontBook.Medium.of(size: 18)
        
        label.textColor = UIColor.white
        label.textAlignment = .center
        
        // if the size of your tab is not fixed, you can adjust the size by the following way.
        // resize the label to the size of content
        label.sizeToFit()
        // add some paddings
        label.frame.size = CGSize(width: label.frame.size.width + 48, height: label.frame.size.height + 53)
        
        return label
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        return chartViewControllers[index]
    }
    
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didScrollPageTo index: Int) {
        
    }
    
    func tabScrollView(_ tabScrollView: ACTabScrollView, didChangePageTo index: Int) {
        
    }
    
}

extension MyopiaProgressVC : EyeDegreeListDelegate {
    
    func didRecieveEyeDegreeData(data: ListEyeDegrees) {
        if activePicker == leftEyeViewHolder {
            viewModel.selectedLeftEye = data
        }else if activePicker == rightEyeViewHolder {
            viewModel.selectedRightEye = data
        }
    }
}
