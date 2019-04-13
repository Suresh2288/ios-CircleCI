//
//  AddChildVCiPad.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import RSKImageCropper
import PKHUD
import PopupDialog
import RealmSwift
import Kingfisher
import SwiftyUserDefaults
import SRMonthPicker

/**
 *
 * There are 3 steps to assign to _BaseScrollViewController
 * 1) Inheritance from _BaseScrollViewController
 * 2) Set ScrollView class to TPKeyboardAvoidingScrollView
 * 3) Set ScrollView delegate to VC
 *
 **/

class AddChildVCiPad: _BaseScrollViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgProfile: ProfileImageView!
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var dobView: UIView!
    
    @IBOutlet weak var txtFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLastName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var dobPicker: SRMonthPicker!
    @IBOutlet weak var dobHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var dobBefore: UIView!
    @IBOutlet weak var dobAfter: UIView!
    
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var btnMale: IconAlignedButton!
    @IBOutlet weak var btnFemale: IconAlignedButton!
    
    @IBOutlet weak var btnEyeTestedYes: UIButton!
    @IBOutlet weak var btnEyeTestedNo: UIButton!
    @IBOutlet weak var eyeTestedImage: UIImageView!
    @IBOutlet weak var lblEyeTested: UILabel!
    
    @IBOutlet weak var wearGlassesView: UIView!
    @IBOutlet weak var btnContactLensesYes: UIButton!
    @IBOutlet weak var btnContactLensesNo: UIButton!
    @IBOutlet weak var contactLensesImage: UIImageView!
    @IBOutlet weak var overlayWearGlasses: UIView!
    
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var overlayGlassesView: UIView!
    @IBOutlet weak var txtGlassesYear: SkyFloatingLabelTextField!
    @IBOutlet weak var txtGlassesMonths: SkyFloatingLabelTextField!
    
    @IBOutlet weak var visionTestConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnViewMyopia: UIButton!
    @IBOutlet weak var viewMyopiaHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var degreeEyeView: UIView!
    @IBOutlet weak var overlayDegreeEyeView: UIView!
    @IBOutlet weak var txtLeftEye: SkyFloatingLabelTextField!
    @IBOutlet weak var txtRightEye: SkyFloatingLabelTextField!
    @IBOutlet weak var imgLeftEye: UIImageView!
    @IBOutlet weak var imgRightEye: UIImageView!
    @IBOutlet weak var leftEyeViewHolder: UIView!
    @IBOutlet weak var rightEyeViewHolder: UIView!
    
    @IBOutlet weak var degreeEyeViewBefore: UIView!
    @IBOutlet weak var overlayEyeDegreeFirst: UIView!
    @IBOutlet weak var imgLeftEyeBefore: UIImageView!
    @IBOutlet weak var imgRightEyeBefore: UIImageView!
    @IBOutlet weak var leftEyeBeforeViewHolder: UIView!
    @IBOutlet weak var rightEyeBeforeViewHolder: UIView!
    @IBOutlet weak var txtLeftEyeBefore: SkyFloatingLabelTextField!
    @IBOutlet weak var txtRightEyeBefore: SkyFloatingLabelTextField!
    
    @IBOutlet weak var ScrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationBasedOnView: UIView!
    @IBOutlet weak var overlayInformationBasedOnView: UIView!
    @IBOutlet weak var btnPrescription: IconAlignedButton!
    @IBOutlet weak var btnMemory: IconAlignedButton!
    
    @IBOutlet weak var btnAddChildSubmit: UIButton!
    
    @IBOutlet weak var lblDoesYourChildWear: UILabel!
    @IBOutlet weak var lblHasYourChild: UILabel!
    
    
    @IBOutlet weak var DividerView: UIView!
    @IBOutlet weak var LeftView: UIView!
    @IBOutlet weak var RightView: UIView!
    @IBOutlet weak var TitleInfoView: UIView!
    @IBOutlet weak var SavebuttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var SavebuttonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var VisionTestView: UIView!
    @IBOutlet weak var overlayVisionTest: UIView!
    @IBOutlet weak var overlayEyecheckView: UIView!
    @IBOutlet weak var btnUpdateCheckup: AdaptiveButton!
    @IBOutlet weak var EyeCheckView: UIView!
    @IBOutlet weak var txtEyeCheckYear: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEyeCheckMonth: SkyFloatingLabelTextField!
    override var analyticsScreenName:String? {
        get {
            return "addchild"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "addchild"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    let placeholderImage = UIImage(named: "iconAvatar")
    
    var dobOpen:Bool = true
    var isInEditMode:Bool = false
    var isEyeTest:Bool = false
    
    var isScrolled:Bool = false
    var isEyePickerClicked:Bool = false
    
    var viewModel = AddChildViewModel()
    var childProfile:ChildProfile?
    
    var activePicker:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeLeftMenuGesture()
        
        initView()
        
        initFloatingLabels()
        
        viewModelCallBack()
        
        if isInEditMode {
            viewModel.isInEditMode = isInEditMode
            setUpNavBarWithAttributes(navtitle: "Edit profile".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16.0))
            scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
            scrollView.isScrollEnabled = false
            prepareForEdit()
            
            if let cp = childProfile {
                if(cp.profileImage.length != 0) {
                    if let data = try? Data(contentsOf: URL(string: cp.profileImage)!)
                    {
                        let image: UIImage = UIImage(data: data)!
                        self.imgProfile.image = image
                    }
                } else {
                    let image = Image(named: "iconAvatar")
                    
                    imgProfile.kf.setImage(with: URL(string: cp.profileImage), placeholder: image, options: nil, progressBlock: nil, completionHandler: { imageResult, error, type, cache in
                        self.imgProfile.image = image
                    })
                }
            }
        }else{
            setUpNavBarWithAttributes(navtitle: "Add your child".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16.0))
            viewModel.eyeVisionTested = true
            viewModel.wearGlasses = true
            SavebuttonTopConstraint.constant = 1775
            
            if let cp = childProfile {
                let image = Image(named: "iconAvatar")
                
                imgProfile.kf.setImage(with: URL(string: cp.profileImage), placeholder: image, options: nil, progressBlock: nil, completionHandler: { imageResult, error, type, cache in
                    self.imgProfile.image = image
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isScrolled,isEyePickerClicked{
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            UIApplication.shared.isStatusBarHidden = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        addLeftMenuGesture()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.isStatusBarHidden = false
        
        if isScrolled,isEyePickerClicked{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            UIApplication.shared.isStatusBarHidden = false
        }
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func initView(){
        // close DOB Picker
        closeDOBPickerWithoutAnimation()
        
        // set max date to current date so they cannot choose future dates
        //        dobPicker.maximumDate = Date()
        
        self.dobPicker.monthPickerDelegate = self;
        self.dobPicker.maximumYear = Date().year
        self.dobPicker.minimumYear = 1900
        self.dobPicker.yearFirst = false
        
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2;
        imgProfile.clipsToBounds = true;
        imgProfile.contentMode = .scaleAspectFill;
        
        btnAddChildSubmit.isEnabled = false
        btnUpdateCheckup.isEnabled = false
        
        dobAfter.isHidden = true
        dobBefore.isHidden = false
        
        //viewMyopiaHeightConstraint.constant = 0
        //btnViewMyopia.isHidden = true
        degreeEyeView.layoutIfNeeded()
        
        // hide Additional Information View
        
        lblDoesYourChildWear.text = lblDoesYourChildWear.text!.localized()
        lblHasYourChild.text = lblHasYourChild.text!.localized()
    }
    
    func initFloatingLabels() {
        
        txtFirstName.autocorrectionType = .no
        txtFirstName.autocapitalizationType = .words
        txtLastName.autocorrectionType = .no
        txtLastName.autocapitalizationType = .words
        txtGlassesYear.keyboardType = .numberPad
        txtGlassesMonths.keyboardType = .numberPad
        txtEyeCheckYear.keyboardType = .numberPad
        txtEyeCheckMonth.keyboardType = .numberPad
        txtLeftEye.keyboardType = .numberPad
        txtRightEye.keyboardType = .numberPad
        
        configFloatingLabel(txtFirstName)
        configFloatingLabel(txtLastName)
        configFloatingLabel(txtGlassesYear)
        configFloatingLabel(txtGlassesMonths)
        configFloatingLabel(txtEyeCheckMonth)
        configFloatingLabel(txtEyeCheckYear)
        configFloatingLabel(txtLeftEyeBefore)
        configFloatingLabel(txtRightEyeBefore)
        configFloatingLabel(txtLeftEye)
        configFloatingLabel(txtRightEye)
        
        
        txtFirstName.delegate = self
        txtLastName.delegate = self
        txtGlassesYear.delegate = self
        txtGlassesMonths.delegate = self
        txtEyeCheckMonth.delegate = self
        txtEyeCheckYear.delegate = self
        txtLeftEyeBefore.delegate = self
        txtRightEyeBefore.delegate = self
        txtLeftEye.delegate = self
        txtRightEye.delegate = self
        
        let tapLeftBefore = UITapGestureRecognizer(target: self, action: #selector(showLeftEyeBeforePicker(_:)))
        leftEyeBeforeViewHolder.addGestureRecognizer(tapLeftBefore)
        txtLeftEyeBefore.isEnabled = false
        
        let tapRightBefore = UITapGestureRecognizer(target: self, action: #selector(showRightEyeBeforePicker(_:)))
        rightEyeBeforeViewHolder.addGestureRecognizer(tapRightBefore)
        txtRightEyeBefore.isEnabled = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showLeftEyePicker(_:)))
        leftEyeViewHolder.addGestureRecognizer(tap)
        txtLeftEye.isEnabled = false
        
        let tapRight = UITapGestureRecognizer(target: self, action: #selector(showRightEyePicker(_:)))
        rightEyeViewHolder.addGestureRecognizer(tapRight)
        txtRightEye.isEnabled = false
        
        viewModel.evaluateValidity()
    }
    
    
    
    func prepareForEdit() {
        
        // pass childProfile to ViewModel
        viewModel.childProfile = childProfile
        
        // UI
        btnAddChildSubmit.setTitle("Save", for: .normal)
        btnUpdateCheckup.isHidden = false
        
        VisionTestView.isHidden = true
        EyeCheckView.isHidden = true
        wearGlassesView.isHidden = true
        glassesView.isHidden = true
        degreeEyeView.isHidden = true
        degreeEyeViewBefore.isHidden = true
        informationBasedOnView.isHidden = true
        TitleInfoView.isHidden = true
        RightView.isHidden = true
        LeftView.isHidden = true
        DividerView.isHidden = true
        SavebuttonTopConstraint.constant = 495
    }
    
    // MARK: - Eye Pickers
    
    @objc func showLeftEyeBeforePicker(_ tap:UITapGestureRecognizer){
        self.view.endEditing(true)
        activePicker = leftEyeBeforeViewHolder
        showEyePicker(viewModel.selectedLeftEyeBefore)
        
    }
    
    @objc func showRightEyeBeforePicker(_ tap:UITapGestureRecognizer){
        self.view.endEditing(true)
        activePicker = rightEyeBeforeViewHolder
        showEyePicker(viewModel.selectedRightEyeBefore)
    }
    
    @objc func showLeftEyePicker(_ tap:UITapGestureRecognizer){
        self.view.endEditing(true)
        activePicker = leftEyeViewHolder
        showEyePicker(viewModel.selectedLeftEye)
        
    }
    
    @objc func showRightEyePicker(_ tap:UITapGestureRecognizer){
        self.view.endEditing(true)
        activePicker = rightEyeViewHolder
        showEyePicker(viewModel.selectedRightEye)
    }
    
    func showEyePicker(_ selectedObj:ListEyeDegrees?){
        isEyePickerClicked = true
        let vc = UIStoryboard.EyeDegreeList() as! EyeDegreeListVC
        vc.delegate = self
        vc.selectedObj = selectedObj
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - View Model
    
    func viewModelCallBack() {
        
        viewModel.isFirstNameValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtFirstName.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        
        viewModel.isLastNameValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtLastName.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        
        viewModel.isDOBValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if(validationObj.isValid){
                    me.btnDOB.setTitleColor(Color.DarkGrey.instance(), for: .normal)
                }else{
                    me.btnDOB.setTitleColor(Color.Red.instance(), for: .normal)
                }
            }
        }
        
        viewModel.isEyeTestedValidCallback = {[weak self](_ validationObj: ValidationObj) in
        }
        
        viewModel.isGenderValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if(validationObj.isValid){
                    me.lblGender.textColor = Color.DarkGrey.instance()
                }else{
                    me.lblGender.textColor = Color.Red.instance()
                }
                
            }
        }
        
        viewModel.isLeftEyeBeforeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if (validationObj.isValid){
                    me.imgLeftEyeBefore.image = UIImage(named: "iconLeftEyeSelected")
                }else{
                    me.imgLeftEyeBefore.image = UIImage(named: "iconLeftEye")
                }
            }
        }
        
        viewModel.isRightEyeBeforeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if (validationObj.isValid){
                    me.imgRightEyeBefore.image = UIImage(named: "iconRightEyeSelected")
                }else{
                    me.imgRightEyeBefore.image = UIImage(named: "iconRightEye")
                }
            }
        }
        
        viewModel.isLeftEyeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if (validationObj.isValid){
                    me.imgLeftEye.image = UIImage(named: "iconLeftEyeSelected")
                }else{
                    me.imgLeftEye.image = UIImage(named: "iconLeftEye")
                }
            }
        }
        
        viewModel.isRightEyeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                if (validationObj.isValid){
                    me.imgRightEye.image = UIImage(named: "iconRightEyeSelected")
                }else{
                    me.imgRightEye.image = UIImage(named: "iconRightEye")
                }
            }
        }
        
        viewModel.wearGlassesYearValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtGlassesYear.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.wearGlassesMonthValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtGlassesMonths.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.eyeCheckYearValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtEyeCheckYear.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.eyeCheckMonthValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtEyeCheckMonth.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.leftEyeBeforeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtLeftEyeBefore.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.rightEyeBeforeMonthValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtRightEyeBefore.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.leftEyeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtLeftEye.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        viewModel.rightEyeValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.txtRightEye.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        
        viewModel.leftEyeBeforeUpdatedCallback = {[weak self]() in
            self?.txtLeftEyeBefore.text = self?.viewModel.selectedLeftEyeBefore?.EyeDegreeDescription
        }
        viewModel.rightEyeBeforeUpdatedCallback = {[weak self]() in
            self?.txtRightEyeBefore.text = self?.viewModel.selectedRightEyeBefore?.EyeDegreeDescription
        }
        viewModel.leftEyeUpdatedCallback = {[weak self]() in
            self?.txtLeftEye.text = self?.viewModel.selectedLeftEye?.EyeDegreeDescription
        }
        viewModel.rightEyeUpdatedCallback = {[weak self]() in
            self?.txtRightEye.text = self?.viewModel.selectedRightEye?.EyeDegreeDescription
        }
        
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.isFormValid = {[weak self](valid:Bool) in
            print("Savebutton Enable:\(valid)")
          
            self?.btnAddChildSubmit.isEnabled = valid
            self?.btnUpdateCheckup.isEnabled = valid
        }
        
        viewModel.childProfileUpdatedCallback = {
            
            // retrieve data from ViewModel
            
            if let dob = self.viewModel.dob {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM yyyy"
                
                let strDate = dateFormatter.string(from: dob)
                self.btnDOB.setTitle(strDate, for: .normal)
                self.dobAfter.isHidden = false
                self.dobBefore.isHidden = true
                
                self.dobPicker.date = dob
            }
            
            /*
             * Must put True/False switches on top of here
             * Beacuse we are clicking the buttons and if we put the values of text field first,
             * those values will be wiped out after buttons are clicked
             */
            if let et = self.viewModel.eyeVisionTested {
                if et == true {
                    self.btnEyeTestedYesClicked(nil)
                    
                }else{
                    self.btnEyeTestedNoClicked(nil)
                }
            }
            if let ifb = self.viewModel.infoBased {
                if ifb == InfoBased.prescription {
                    self.btnPrescriptionClicked(nil)
                }else if ifb == InfoBased.memory {
                    self.btnMemoryClicked(nil)
                }
            }
            
            if let g = self.viewModel.gender {
                if g {
                    self.btnMaleClicked(nil)
                }else{
                    self.btnFemaleClicked(nil)
                }
            }
            
            if let wearG = self.viewModel.wearGlasses {
                if wearG {
                    self.contactLensesYesClicked()
                }else{
                    self.contactLensesNoClicked()
                    self.hideEyeGroupViews()
                }
            }
            
            // textfiels are put below here because Buttons have events and will replace values of textField which we don't want
            self.txtFirstName.text = self.viewModel.firstName
            self.txtLastName.text = self.viewModel.lastName
            self.txtGlassesYear.text = self.viewModel.wearGlassesYear
            self.txtGlassesMonths.text = self.viewModel.wearGlassesMonth
            self.txtEyeCheckYear.text = self.viewModel.eyeCheckYear
            self.txtEyeCheckMonth.text = self.viewModel.eyeCheckMonth
            
            self.txtLeftEyeBefore.text = self.viewModel.leftEyeDegreeBefore
            self.txtRightEyeBefore.text = self.viewModel.rightEyeDegreeBefore
            self.txtLeftEye.text = self.viewModel.leftEyeDegree
            self.txtRightEye.text = self.viewModel.rightEyeDegree
            
        }
    }
    
    // MARK: - Views
    
    func gotoNextScreen() {
        
    }
    
    func closeDOBPickerWithoutAnimation(){
        self.dobHeightConstraint.constant = 52
        self.scrollView.layoutIfNeeded()
        dobPicker.alpha = 0
        dobOpen = false
    }
    
    // MARK: - Buttons
    
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        btnCameraClicked()
    }
    
    @IBAction func btnDOBClicked(_ sender: UIButton) {
        self.hideKeyboard()
        
        if dobOpen {
            // close
            self.dobHeightConstraint.constant = 52
            
            if self.isInEditMode {
                self.SavebuttonTopConstraint.constant = 495
            } else {
                self.SavebuttonTopConstraint.constant = 1775
            }
            
        }else{
            // open
            self.dobHeightConstraint.constant = 220
            
            if self.isInEditMode {
                self.SavebuttonTopConstraint.constant = 670
            } else {
                self.SavebuttonTopConstraint.constant = 1950
            }
            
        }
        
        dobOpen = !dobOpen
        
        self.dobPicker.alpha = self.dobPicker.alpha == 0 ? 1 : 0
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    func datePickerValueChanged(_ date:Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let strDate = dateFormatter.string(from: date)
        
        let order = Calendar.current.compare(Date(), to: date, toGranularity: .day)
        
        switch order {
        case .orderedAscending:
            print("\(date) is after \(Date())")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"
            
            let strDate = dateFormatter.string(from: Date())
            self.btnDOB.setTitle(strDate, for: .normal)
            self.dobAfter.isHidden = false
            self.dobBefore.isHidden = true
            
            self.dobPicker.date = Date()
            
        case .orderedDescending:
            print("\(date) is before \(Date())")
            
            self.btnDOB.setTitle(strDate, for: .normal)
            viewModel.dob = date
            if isEyeTest{
                let lblString = viewModel.getEyeTestDescription()
                lblEyeTested.text = lblString
            }
            self.dobBefore.isHidden = true
            self.dobAfter.isHidden = false
        default:
            print("\(date) is the same as \(Date())")
            
            self.btnDOB.setTitle(strDate, for: .normal)
            viewModel.dob = date
            if isEyeTest{
                let lblString = viewModel.getEyeTestDescription()
                lblEyeTested.text = lblString
            }
            self.dobBefore.isHidden = true
            self.dobAfter.isHidden = false
        }
    }
    
    @IBAction func btnMaleClicked(_ sender: UIButton?) {
        viewModel.gender = true
        btnMale.isSelected = true
        btnFemale.isSelected = false
    }
    
    @IBAction func btnFemaleClicked(_ sender: UIButton?) {
        viewModel.gender = false
        btnFemale.isSelected = true
        btnMale.isSelected = false
    }
    
    @IBAction func btnEyeTestedYesClicked(_ sender: UIButton?) {
        isEyeTest = true
        viewModel.eyeVisionTested = true
        eyeTestedImage.image = UIImage(named: "iconWearGlassesLeft")
        btnEyeTestedYes.isSelected = true
        btnEyeTestedNo.isSelected = false
        //        self.visionTestConstraint.constant = 228
        //        if(viewModel.dob != nil)
        let lblString = viewModel.getEyeTestDescription()
        lblEyeTested.text = lblString
        
        updateTextValueManually(textField: txtEyeCheckYear, value: "")
        updateTextValueManually(textField: txtEyeCheckMonth, value: "")
        showEyeGroupViews()
    }
    
    @IBAction func btnEyeTestedNoClicked(_ sender: UIButton?) {
        isEyeTest = false
        viewModel.eyeVisionTested = false
        eyeTestedImage.image = UIImage(named: "iconWearGlassesRight")
        btnEyeTestedYes.isSelected = false
        btnEyeTestedNo.isSelected = true
        //        self.visionTestConstraint.constant = 228
        lblEyeTested.text = "Don't forget to bring your child for an eye test in 2 months and enter the results in the plano app.".localized()
        
        updateTextValueManually(textField: txtEyeCheckYear, value: "0")
        updateTextValueManually(textField: txtEyeCheckMonth, value: "0")
        
        txtEyeCheckYear.errorMessage = ""
        txtEyeCheckMonth.errorMessage = ""
        hideEyeGroupViews()
    }
    
    @IBAction func btnContactLensesYesClicked(_ sender: UIButton?) {
        contactLensesYesClicked()
        
        viewModel.wearGlasses = true
        updateTextValueManually(textField: txtGlassesYear, value: "")
        updateTextValueManually(textField: txtGlassesMonths, value: "")
        //        updateTextValueManually(textField: txtLeftEye, value: "")
        //        updateTextValueManually(textField: txtRightEye, value: "")
        //        updateTextValueManually(textField: txtLeftEyeBefore, value: "")
        //        updateTextValueManually(textField: txtRightEyeBefore, value: "")
        showEyeGroupViews()
    }
    func contactLensesYesClicked() {
        contactLensesImage.image = UIImage(named: "iconWearGlassesLeft")
        btnContactLensesYes.isSelected = true
        btnContactLensesNo.isSelected = false
        
    }
    
    @IBAction func btnContactLensesNoClicked(_ sender: UIButton?) {
        contactLensesNoClicked()
        
        viewModel.wearGlasses = false
        updateTextValueManually(textField: txtGlassesYear, value: "0")
        updateTextValueManually(textField: txtGlassesMonths, value: "0")
        updateTextValueManually(textField: txtLeftEye, value: "")
        updateTextValueManually(textField: txtRightEye, value: "")
        updateTextValueManually(textField: txtLeftEyeBefore, value: "")
        updateTextValueManually(textField: txtRightEyeBefore, value: "")
        viewModel.selectedLeftEye = nil
        viewModel.selectedRightEye = nil
        viewModel.selectedLeftEyeBefore = nil
        viewModel.selectedRightEyeBefore = nil
        
        txtGlassesYear.errorMessage = ""
        txtGlassesMonths.errorMessage = ""
        
        hideEyeGroupViews()
    }
    func contactLensesNoClicked() {
        contactLensesImage.image = UIImage(named: "iconWearGlassesRight")
        btnContactLensesYes.isSelected = false
        btnContactLensesNo.isSelected = true
    }
    
    @IBAction func btnPrescriptionClicked(_ sender: UIButton?) {
        viewModel.infoBased = InfoBased.prescription
        btnPrescription.isSelected = true
        btnMemory.isSelected = false
    }
    
    @IBAction func btnMemoryClicked(_ sender: UIButton?) {
        viewModel.infoBased = InfoBased.memory
        btnPrescription.isSelected = false
        btnMemory.isSelected = true
    }
    
    @IBAction func btnAddChildClicked(_ sender: UIButton) {
        
        perform(#selector(hideKeyboard), with: nil, afterDelay: 0.3)
        
        if !isInEditMode {
            
            viewModel.submitForm(success: { (childID:String) in
                
                self.goBackToRootPage()
                
                if let parent = self.parentVC as? MyFamilyVC {
                    Defaults[.recentlyAddedChildID] = Int(childID)
                    parent.userCreatedSuccessfully()
                    WoopraTrackingPage().trackEvent(mainMode:"Parent Add Child Page",pageName:"Add Child Page",actionTitle:"New Child Added")
                }
                
                AnalyticsHelper().analyticLogScreen(screen: "addchild_complete")
                
                AppFlyerHelper().trackScreen(screenName: "addchild_complete")
                
            }) { (validationObj:ValidationObj) in
                
                if let msg = validationObj.message() {
                    self.showAlert(msg)
                }
            }
            
        }else{
            
            if let img = imgProfile.image  {
                var finalImg = img
                if let resizedImg = img.resizeWith(width: 512) {
                    finalImg = resizedImg
                }
                
                self.imgProfile.image = finalImg
                self.imgProfile.contentMode = .scaleAspectFill
                self.imgProfile.tag = 1
                viewModel.profileImage = finalImg
                //            cropImageViewController(img)
                
            }
            
            viewModel.updateChildProfile(success: { (validationObj:ValidationObj) in
                
                // do nothing
                self.userUpdatedSuccessfully()
                
            }) { (validationObj:ValidationObj) in
                
                if let msg = validationObj.message() {
                    self.showAlert(msg)
                }
            }
        }
        
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func btnViewMyopiaClicked(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard.MyopiaProgress(), animated: true)
    }
    
    func showEyeGroupViews(){
        
        UIView.animate(withDuration: 0.2) {
            let alpha:CGFloat = 1
            
            if self.viewModel.eyeVisionTested! {
                self.EyeCheckView.alpha = alpha
                self.overlayEyecheckView.isHidden = true
            }
            
            if self.viewModel.wearGlasses! {
                self.glassesView.alpha = alpha
                self.degreeEyeView.alpha = alpha
                self.degreeEyeViewBefore.alpha = alpha
                self.informationBasedOnView.alpha = alpha
                self.VisionTestView.alpha = alpha
                self.wearGlassesView.alpha = alpha
                
                self.overlayWearGlasses.isHidden = true
                self.overlayVisionTest.isHidden = true
                self.overlayGlassesView.isHidden = true
                self.overlayEyeDegreeFirst.isHidden = true
                self.overlayDegreeEyeView.isHidden = true
                self.overlayInformationBasedOnView.isHidden = true
            }
        }
        
    }
    
    func hideEyeGroupViews(){
        
        UIView.animate(withDuration: 0.2) {
            let alpha:CGFloat = 0.4
            
            if self.isInEditMode {
                self.VisionTestView.alpha = alpha
                self.wearGlassesView.alpha = alpha
                self.glassesView.alpha = alpha
                self.degreeEyeView.alpha = alpha
                self.degreeEyeViewBefore.alpha = alpha
                self.informationBasedOnView.alpha = alpha
                self.EyeCheckView.alpha = alpha
                
                self.overlayWearGlasses.isHidden = false
                self.overlayVisionTest.isHidden = false
                self.overlayGlassesView.isHidden = false
                self.overlayEyeDegreeFirst.isHidden = false
                self.overlayDegreeEyeView.isHidden = false
                self.overlayInformationBasedOnView.isHidden = false
                self.overlayEyecheckView.isHidden = false
            } else {
                self.overlayWearGlasses.isHidden = true
                self.overlayVisionTest.isHidden = true
                
                if !self.viewModel.eyeVisionTested! {
                    self.EyeCheckView.alpha = alpha
                    self.overlayEyecheckView.isHidden = false
                }
                
                if !self.viewModel.wearGlasses! {
                    self.glassesView.alpha = alpha
                    self.degreeEyeView.alpha = alpha
                    self.degreeEyeViewBefore.alpha = alpha
                    self.informationBasedOnView.alpha = alpha
                    self.overlayGlassesView.isHidden = false
                    self.overlayEyeDegreeFirst.isHidden = false
                    self.overlayDegreeEyeView.isHidden = false
                    self.overlayInformationBasedOnView.isHidden = false
                }
            }
        }
        
    }
    
    func updateTextValueManually(textField:UITextField, value:String){
        
        textField.text = value
        updateViewModel(textField, value)
        
    }
    
    @IBAction func btnUpdateCheckupClicked() {
        
        if let vc = UIStoryboard.MyopiaProgress() as? MyopiaProgressVC {
            
            if let cp = childProfile {
                
                print(cp.childID)
                vc.parentVC = self
                vc.childID = Int(cp.childID)!
                vc.comeFromProgress = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    // MARK: - Profile Image
    
    func btnCameraClicked(){
        let alert = UIAlertController(title: "Profile Picture", message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera()
        }
        alert.addAction(camera)
        
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.openGallery()
        }
        alert.addAction(gallery)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(cancel)
        
        if let popOver = alert.popoverPresentationController {
            let anchorRect = CGRect(x: 0, y: 0, width: imgProfile.frame.size.width, height: imgProfile.frame.size.height)
            popOver.sourceRect = anchorRect
            popOver.sourceView = imgProfile // works for both iPhone & iPad
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func openGallery(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    func cropImageViewController(_ image:UIImage){
        let imageCropVC = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self
        present(imageCropVC, animated: true, completion: nil)
    }
    
    func updateProfileImage(_ image:UIImage?) {
        
        if var finalImage = image {
            finalImage = resizeImage(image: finalImage, newWidth: 512)
            imgProfile.image = finalImage
            imgProfile.tag = 1
            imgProfile.contentMode = .scaleAspectFill
            saveProfileImage()
        }
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func saveProfileImage(){
        
    }
    
    // MARK: - Utility
    
    func userUpdatedSuccessfully(animated: Bool = true) {
        
        // Prepare the popup
        let title = ""
        let message = "Successfully updated".localized()
        WoopraTrackingPage().trackEvent(mainMode:"Parent Edit Child Page",pageName:"Edit Child Page",actionTitle:"Child details has been saved")
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonThree = CancelButton(title: "OK".localized()) {
            self.navigationController?.popViewController(animated: true)
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonThree])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    func goBackToRootPage(){
        if let vc:MyFamilyVC = self.parentVC as? MyFamilyVC {
            vc.newChildIsAdded = true
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK:- Scrollview
    internal override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if shouldFollowScrollView {
            let y = scrollView.contentOffset.y
            // 100% - (100% / (maxY / currentY))
            headerBg.alpha = 1-(1/(100/y))
            self.navigationController?.navigationItem.titleView?.alpha = headerBg.alpha
            if(headerBg.alpha >= 1){
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                UIApplication.shared.isStatusBarHidden = false
                isScrolled = false
            }else{
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                UIApplication.shared.isStatusBarHidden = true
                isScrolled = true
            }
        }
    }
}


extension AddChildVCiPad : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            var finalImg = img
            if let resizedImg = img.resizeWith(width: 512) {
                finalImg = resizedImg
            }
            
            self.imgProfile.image = finalImg
            self.imgProfile.contentMode = .scaleAspectFill
            self.imgProfile.tag = 1
            viewModel.profileImage = finalImg
            //            cropImageViewController(img)
            
        }
    }
}

extension AddChildVCiPad : RSKImageCropViewControllerDelegate {
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
        updateProfileImage(nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        updateProfileImage(croppedImage)
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        updateProfileImage(croppedImage)
        controller.dismiss(animated: true, completion: nil)
    }
}


extension AddChildVCiPad: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let txt = textField.text, let newRange = txt.range(from: range) {
            let replacedString = txt.replacingCharacters(in: newRange, with: string)
            
            
            if textField == txtGlassesYear {
                if let converted = Int(replacedString), converted > 19 {
                    return false
                }
            }else if textField == txtGlassesMonths {
                if let converted = Int(replacedString), converted > 11 {
                    return false
                }
            }else if textField == txtEyeCheckYear {
                if let converted = Int(replacedString), converted > 19 {
                    return false
                }
            }else if textField == txtEyeCheckMonth {
                if let converted = Int(replacedString), converted > 11 {
                    return false
                }
            }
            
            updateViewModel(textField, replacedString)
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateViewModel(textField, textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide keyboard
        return true
    }
    
    func updateViewModel(_ textField:UITextField, _ text:String?) {
        if textField == txtFirstName {
            viewModel.firstName = text
        }else if textField == txtLastName {
            viewModel.lastName = text
        }else if textField == txtGlassesYear {
            viewModel.wearGlassesYear = text
        }else if textField == txtGlassesMonths {
            viewModel.wearGlassesMonth = text
        }else if textField == txtEyeCheckYear {
            viewModel.eyeCheckYear = text
        }else if textField == txtEyeCheckMonth {
            viewModel.eyeCheckMonth = text
        }
    }
    
}


extension AddChildVCiPad : EyeDegreeListDelegate {
    
    func didRecieveEyeDegreeData(data: ListEyeDegrees) {
        if activePicker == leftEyeBeforeViewHolder {
            viewModel.selectedLeftEyeBefore = data
        }else if activePicker == rightEyeBeforeViewHolder {
            viewModel.selectedRightEyeBefore = data
        }else if activePicker == leftEyeViewHolder {
            viewModel.selectedLeftEye = data
        }else if activePicker == rightEyeViewHolder {
            viewModel.selectedRightEye = data
        }
    }
}


extension AddChildVCiPad : SRMonthPickerDelegate {
    
    func monthPickerDidChangeDate(_ monthPicker: SRMonthPicker!) {
        datePickerValueChanged(monthPicker.date)
    }
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
