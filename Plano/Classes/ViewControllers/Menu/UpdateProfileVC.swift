//
//  UpdateProfileVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import SkyFloatingLabelTextField
import RSKImageCropper
import PopupDialog
import PKHUD
import Kingfisher

class UpdateProfileVC: _BaseScrollViewController, UINavigationControllerDelegate {

    // Mark: IBOutlet
    
    override var analyticsScreenName:String? {
        get {
            return "myprofile"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "myprofile"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var imgProfile: ProfileImageView!
    @IBOutlet weak var countryBefore: UIView!
    @IBOutlet weak var countryAfter: UIView!
    @IBOutlet weak var cityBefore: UIView!
    @IBOutlet weak var cityAfter: UIView!
    
    @IBOutlet weak var lblErrorMsg: UILabel!
    
    
    @IBOutlet weak var lblEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var lblEmailTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var lblPasswordTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var lblFirstNameTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblLastName: SkyFloatingLabelTextField!
    @IBOutlet weak var lblLastNameTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblCountryCode: SkyFloatingLabelTextField!
    @IBOutlet weak var lblCountryCodeTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblMobile: SkyFloatingLabelTextField!
    @IBOutlet weak var lblMobileNumberTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var btnCountryAfter: UIButton!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var btnCityAfter: UIButton!
    
    @IBOutlet weak var btnCreateProfile: UIButton!
    
    // Mark: Vars
    
    var viewModel = UpdateProfileViewModel()
    var willClearPasswordField = false
    var isNavigationBarHidden = false
    var isScrolled = false
    var isbtnClicked = false
    override func viewDidLoad() {
        super.viewDidLoad()
       

        setupMenuNavBarWithAttributes(navtitle: "Profile".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        if let nav = navigationController {
            nav.setNavigationBarHidden(false, animated: true)
        }
        
        initView()
        
        initFloatingLabels()

        viewModelCallBack()
        
        populateData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        if isScrolled,isbtnClicked,isNavigationBarHidden{
            if let nav = navigationController{
                nav.setNavigationBarHidden(false, animated: true)
                UIApplication.shared.isStatusBarHidden = false
            }
        }
    }
        
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imgProfile.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Profile Page",pageName:"Profile Page",actionTitle:"Entered in Profile page")

        if isNavigationBarHidden,isbtnClicked,isScrolled{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            UIApplication.shared.isStatusBarHidden = true
        }
    }

    func initView() {
        
        countryBefore.isHidden = false
        cityBefore.isHidden = false
        cityAfter.isHidden = true
        countryAfter.isHidden = true

        lblFirstName.autocapitalizationType = .words
        lblFirstName.autocorrectionType = .no
        lblLastName.autocapitalizationType = .words
        lblLastName.autocorrectionType = .no
        lblCountryCode.keyboardType = .numberPad
        lblMobile.keyboardType = .phonePad
        
        lblPassword.text = "12345678" // sample data
        
        lblFirstName.returnKeyType = .next
        lblLastName.returnKeyType = .next
        lblCountryCode.returnKeyType = .next
        lblMobile.returnKeyType = .done
        
    }
    
    func populateData(){
        
        // update Profile first
        
        self.viewModel.getProfileFromApi(completed: {[weak self] (prf) in
            
            if let me = self, let profile = prf {

                me.viewModel.email = profile.email
                me.viewModel.firstName = profile.firstName
                me.viewModel.lastName = profile.lastName
//                me.viewModel.countryCode = profile.countryCode
//                me.viewModel.mobileNumber = profile.mobile
                
                me.lblEmail.text = profile.email
                me.lblFirstName.text = profile.firstName
                me.lblLastName.text = profile.lastName
//                me.lblCountryCode.text = profile.countryCode
//                me.lblMobile.text = profile.mobile

                if let c = profile.countryResidence {
                    
                    me.viewModel.getCountriesList(completed: {[weak self] (countries, s) in
                        if let me = self {
                            
                            // Country
                            if let selected = CountryData.getCountryByID(cid: c) {
                                me.viewModel.selectedCountry = selected
                                
                                // City
                                if let cc = profile.city {
                                    me.viewModel.getCitiesList(countryID: c, completed: { (cities, s) in
                                        if let me = self {
                                            if let selected = CityData.getCityByID(cid: cc) {
                                                me.viewModel.selectedCity = selected
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    })
                    
                    
                }
                
                if let data = profile.profileImage {
                    
                    me.imgProfile.kf.setImage(with: URL(string: data), placeholder: #imageLiteral(resourceName: "iconAvatar"), options: nil, progressBlock: nil, completionHandler: { imageResult, error, type, cache in
                        me.imgProfile.image = #imageLiteral(resourceName: "iconAvatar")
                    })
                }
                
                me.viewModel.evaluateValidity()
            }
        })
    }
    
    func initFloatingLabels() {
    
        configFloatingLabel(lblEmail)
        configFloatingLabel(lblPassword)
        
        configFloatingLabel(lblFirstName)
        configFloatingLabel(lblLastName)
//        configFloatingLabel(lblMobile)
//        configFloatingLabel(lblCountryCode)

        lblEmail.delegate = self
        lblPassword.delegate = self
        lblFirstName.delegate = self
        lblLastName.delegate = self
        lblMobile.delegate = self
        lblCountryCode.delegate = self

    }

    func viewModelCallBack() {

        viewModel.countryDataUpdatedCallback = {[weak self](country:CountryData?) in
            if let me = self, let data = country {
                me.btnCountryAfter.setTitle(data.name, for:.normal)
                me.countryBefore.isHidden = true
                me.countryAfter.isHidden = false
                
                self?.callCityListSelect()
            }
        }
            
        viewModel.cityDataUpdatedCallback = {[weak self](city:CityData?) in
            if let me = self {
                if let data = city {
                    me.btnCityAfter.setTitle(data.name, for:.normal)
                    me.cityBefore.isHidden = true
                    me.cityAfter.isHidden = false
                }else{
                    me.btnCityAfter.setTitle("", for:.normal)
                    me.cityBefore.isHidden = false
                    me.cityAfter.isHidden = true
                }
            }
        }
        
        viewModel.isEmailValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.lblEmail.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.lblEmail)
                }
            }
        }
    
        viewModel.isPasswordValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.lblPassword.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.lblPassword)
                }
            }
        }
        
        viewModel.isFirstNameValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.lblFirstName.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.lblFirstName)
                }
            }
        }
    
        viewModel.isLastNameValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.lblLastName.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
                if !validationObj.isValid {
                    me.pushDownFloatingLabel(me.lblLastName)
                }
            }
        }
        
//        viewModel.isMobileNumberValidCallback = {[weak self](_ validationObj: ValidationObj) in
//            if let me = self {
//                me.lblMobile.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
//                if !validationObj.isValid {
//                    me.pushDownFloatingLabel(me.lblMobile)
//                }
//            }
//        }
        
//        viewModel.isCountryCodeValidCallback = {[weak self](_ validationObj: ValidationObj) in
//            if let me = self {
//                me.lblCountryCode.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
//                if !validationObj.isValid {
//                    me.pushDownFloatingLabel(me.lblCountryCode)
//                }
//            }
//        }
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
     
        viewModel.submitFormCallback = {[weak self]() in
            print("success")
            self?.getMasterDataInBackground()
        }
        
        viewModel.isFormValid = {[weak self](valid:Bool) in
            self?.btnCreateProfile.isEnabled = valid
        }

    }
    
    func callSelectedCountriesCityListWithDefaultValue(){
        
        viewModel.callSelectedCountriesCityListWithDefaultValue()
    }
    
    func pushDownFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = 8
        if(textField == lblEmail){
            lblEmailTopConstraint.constant = constant
        }else if(textField == lblPassword){
            lblPasswordTopConstraint.constant = constant
        }else if(textField == lblFirstName){
            lblFirstNameTopConstraint.constant = constant
        }else if(textField == lblLastName){
            lblLastNameTopConstraint.constant = constant
        }
//        else if(textField == lblCountryCode){
//            lblCountryCodeTopConstraint.constant = constant
//        }else if(textField == lblMobile){
//            lblMobileNumberTopConstraint.constant = constant
//        }
        
        textField.layoutIfNeeded()
    }
    
    func pushUpFloatingLabel(_ textField:UITextField) {
        let constant:CGFloat = -5
        if(textField == lblEmail){
            lblEmailTopConstraint.constant = constant
        }else if(textField == lblPassword){
            lblPasswordTopConstraint.constant = constant
        }else if(textField == lblFirstName){
            lblFirstNameTopConstraint.constant = constant
        }else if(textField == lblLastName){
            lblLastNameTopConstraint.constant = constant
        }
        
//        else if(textField == lblCountryCode){
//            lblCountryCodeTopConstraint.constant = constant
//        }else if(textField == lblMobile){
//            lblMobileNumberTopConstraint.constant = constant
//        }

        textField.layoutIfNeeded()
    }
    
    func callCountriesList(){
        self.isbtnClicked = true
        isNavigationBarHidden = true
        self.Hiddenkeyboard()
        viewModel.getCountriesList {[weak self](list, selected) in
            let vc:CountryCityListVC = UIStoryboard.CountryCityList() as! CountryCityListVC
            if let l = list {
                vc.countryList = l
            }
            if let s = selected {
                vc.selectedCountryObj = s
            }
            vc.delegate = self
            self?.navigationController?.pushViewController(vc, animated: true)
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func callCityList(){
        self.isbtnClicked = true
        self.Hiddenkeyboard()
        viewModel.getCitiesList {[weak self] (list, selected) in
            let vc:CountryCityListVC = UIStoryboard.CountryCityList() as! CountryCityListVC
            if let l = list {
                vc.cityList = l
            }
            if let s = selected {
                vc.selectedCityObj = s
            }
            vc.delegate = self
            self?.navigationController?.pushViewController(vc, animated: true)
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    func callCityListSelect(){
        self.Hiddenkeyboard()
        viewModel.getCitiesList {[weak self] (list, selected) in
            if let l = list
            {
                self?.btnCityAfter.setTitle(l[0].name, for:.normal)
                self?.cityBefore.isHidden = true
                self?.cityAfter.isHidden = false
                
            }
            
        }
    }
    
    
    // MARK: Buttons
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        btnCameraClicked()
    }
    
    @IBAction func btnCountryClicked(_ sender: Any) {
       
        callCountriesList()
    }
    
    @IBAction func btnCountryBeforeClicked(_ sender: Any) {
        callCountriesList()
    }
    
    @IBAction func btnCityBeforeClicked(_ sender: Any) {
        callCityList()
    }

    @IBAction func btnCityAfterClicked(_ sender: Any) {
        callCityList()
    }
    
    @IBAction func btnRegisterClicked(_ sender: Any) {

        self.view.endEditing(true)
        
        viewModel.submitForm(success: { (validationObj:ValidationObj) in
            WoopraTrackingPage().trackEvent(mainMode:"Edit Parent Profile Page",pageName:"Profile Page",actionTitle:"Profile has been successfully updated")

            self.showAlert("Your profile has been successfully updated.")
            
        }) {[weak self] (validationObj:ValidationObj) in //
            if let msg = validationObj.message() {
                self?.showAlert(msg)
            }
        }

    }
    
    @IBAction func btnResetPasswordClicked(_ sender: Any) {
        if(isScrolled == true){
            self.isNavigationBarHidden = true
        }
        self.isbtnClicked = true
        let vc = UIStoryboard.ResetPassword()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func Hiddenkeyboard(){
        self.view.endEditing(true)
    }
    // MARK: Validation
    
    func isValid(name: String) -> Bool { // https://thatthinginswift.com/guard-statement-swift/
        
        // check the name is between 4 and 16 characters
        if !(4...16 ~= name.characters.count) {
            return false
        }
        
        // check that name doesn't contain whitespace or newline characters
        let range = name.rangeOfCharacter(from: .whitespacesAndNewlines)
        if let range = range, range.lowerBound != range.upperBound {
            return false
        }
        
        return true
    }

    func cropImageViewController(_ image:UIImage){
        let imageCropVC = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self
        present(imageCropVC, animated: true, completion: nil)
    }
    
    func updateProfileImage(_ image:UIImage?) {
     
        if var finalImage = image {
            finalImage = resizeImage(image: finalImage, newWidth: 512)
            viewModel.profileImage = finalImage

            imgProfile.image = finalImage
            imgProfile.tag = 1
            imgProfile.contentMode = .scaleAspectFill
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
    
    func btnCameraClicked(){
        let alert = UIAlertController(title: "Profile Picture".localized(), message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera".localized(), style: .default) { (action) in
            self.openCamera()
        }
        alert.addAction(camera)
        
        let gallery = UIAlertAction(title: "Gallery".localized(), style: .default) { (action) in
            self.openGallery()
        }
        alert.addAction(gallery)
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel) { (action) in
            
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

}


extension UpdateProfileVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            updateProfileImage(img)
        }
    }
}

extension UpdateProfileVC : RSKImageCropViewControllerDelegate {
 
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

extension UpdateProfileVC : CountryCityDataDelegate {
    func didRecieveCountryData(data: CountryData) {
        viewModel.selectedCountry = data
    }
    
    func didRecieveCityData(data: CityData) {
        viewModel.selectedCity = data
    }

}

extension UpdateProfileVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let finalString = txt.replacingCharacters(in: newRange, with: string)
            let isBackSpace = string == ""
            
            if finalString.characters.count > 0 {
                pushDownFloatingLabel(textField)
                
                // check from "" -> "a"
                let isNewlyType = finalString.characters.count > txt.characters.count
                if isNewlyType && textField == lblPassword {
                    willClearPasswordField = false // this happen when we start typing again in PW field
                }
                
            }else{
                
                pushUpFloatingLabel(textField)
                
                // clear error message if text is empty
                (textField as! SkyFloatingLabelTextField).errorMessage = ""
                
            }
            
            // Reason: to handle special case when password field is just focused and tapped "backspace" to clear the password
            //          As default feature, UITextfield clear whole password field when it's newly focused
            // Action: To move up the password field when all text are gone
            if(lblPassword == textField && isBackSpace){
                if willClearPasswordField {
                    pushUpFloatingLabel(textField)
                    log.debug("pushUpFloatingLabel")
                    willClearPasswordField = false
                }
            }
            
            
            updateViewModel(textField as! SkyFloatingLabelTextField, finalString)
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateViewModel(textField as! SkyFloatingLabelTextField, textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(lblFirstName == textField){
            lblLastName.becomeFirstResponder()
        }else if(lblLastName == textField){
            lblCountryCode.becomeFirstResponder()
        }
//        else if(lblCountryCode == textField){
//            lblMobile.becomeFirstResponder()
//        }else if(lblLastName == textField){
//            lblCountryCode.resignFirstResponder()
//        }
        return true
    }
    
    private func updateViewModel(_ textField:SkyFloatingLabelTextField, _ text:String?) {
        
        textField.errorMessage = "" // clear the error
        
        if textField == lblEmail {
            viewModel.email = text
        }else if textField == lblPassword {
            viewModel.password = text
        }else if textField == lblFirstName {
            viewModel.firstName = text
        }else if textField == lblLastName {
            viewModel.lastName = text
        }
//        else if textField == lblMobile {
//            viewModel.mobileNumber = text
//        }else if textField == lblCountryCode {
//            viewModel.countryCode = text
//        }
    }
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
