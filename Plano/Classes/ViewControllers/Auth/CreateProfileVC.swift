//
//  CreateProfileVC.swift
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
import SwiftyUserDefaults

class CreateProfileVC: _BaseScrollViewController, UINavigationControllerDelegate {

    // Mark: IBOutlet
    
    @IBOutlet weak var imgProfile: ProfileImageView!
    @IBOutlet weak var countryBefore: UIView!
    @IBOutlet weak var countryAfter: UIView!
    @IBOutlet weak var cityBefore: UIView!
    @IBOutlet weak var cityAfter: UIView!
    
    @IBOutlet weak var lblFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var lblLastName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var btnCountryAfter: UIButton!
    
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var btnCityAfter: UIButton!
    
    @IBOutlet weak var btnCreateProfile: UIButton!
    
    @IBOutlet weak var btnCreateProfileInsideScrollView: UIButton!
    
    // iPhone X Support
    @IBOutlet weak var headerViewHeightConstraint : NSLayoutConstraint!
    
    // Mark: Vars
    
    public var viewModel = CreateProfileViewModel()
    
    // MARK: Viewcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBarWithAttributes(navtitle: "Profile".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))

        initView()
        
        initFloatingLabels()

        viewModelCallBack()
        
        populateDataFromViewModel()
        
        callCountriesCityListWithDefaultValue()
        
        if Device.size() == .screen5_8Inch{
            headerViewHeightConstraint.constant = 182
        }else{
            headerViewHeightConstraint.constant = 182
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
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        
        lblFirstName.returnKeyType = .next
        lblLastName.returnKeyType = .done
        
        if Device.size() <= .screen4Inch{
            btnCreateProfileInsideScrollView.isHidden = false
            btnCreateProfile.isHidden = true
        }else{
            btnCreateProfileInsideScrollView.isHidden = true
            btnCreateProfile.isHidden = false
        }
    }
    
    func initFloatingLabels() {
    
        configFloatingLabel(lblFirstName)
        configFloatingLabel(lblLastName)

        lblFirstName.delegate = self
        lblLastName.delegate = self
    }

    func viewModelCallBack() {

        viewModel.countryDataUpdatedCallback = {[weak self](country:CountryData?) in
            if let me = self, let data = country{
                me.btnCountryAfter.setTitle(data.name, for:.normal)
                me.countryBefore.isHidden = true
                me.countryAfter.isHidden = false
                
                self?.callCityListSelect()
            }
        }
            
        viewModel.cityDataUpdatedCallback = {[weak self](city:CityData?) in
            if let me = self {
                if let data = city{
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
        
        viewModel.isFirstNameValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.lblFirstName.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
    
        viewModel.isLastNameValidCallback = {[weak self](_ validationObj: ValidationObj) in
            if let me = self {
                me.lblLastName.errorMessage = validationObj.isValid ? "" : validationObj.message()?.localized()
            }
        }
        
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
            self?.btnCreateProfileInsideScrollView.isEnabled = valid
        }
    }
    
    func callCountriesCityListWithDefaultValue(){
        
        // Allow user to select Country+City
        self.btnCountryAfter.isEnabled = true
        self.btnCountryAfter.setTitleColor(Color.DarkGrey.instance(), for: .normal)
        
        self.btnCityAfter.isEnabled = true
        self.btnCityAfter.setTitleColor(Color.DarkGrey.instance(), for: .normal)
        
        // Auto call api and auto populate SINGAPORE
        viewModel.callCountriesCityListWithDefaultValue()
    }
    
    func callSelectedCountriesCityListWithDefaultValue(){
        
        viewModel.callSelectedCountriesCityListWithDefaultValue()
    }

    public func assignRegisterDataModel(_ registerDataModel:RegisterData){
        viewModel.assignRegisterDataModel(registerDataModel)
    }
    
    func populateDataFromViewModel(){
        if let model = viewModel.registerDataModel {
            if let data = model.fbid {
                let profileImageUrl = viewModel.makeFacebookProfileImageUrl(fbid: data)
                let image = Image(named: "iconAvatar")
                
                imgProfile.kf.setImage(with: URL(string: profileImageUrl), placeholder: image, options: nil, progressBlock: nil, completionHandler: { imageResult, error, type, cache in
                    self.imgProfile.image = image
                })
            }
            lblFirstName.text = model.firstName
            lblLastName.text = model.lastName
        }
    }
    
    func callCountriesList(){
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
            if let l = list{
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
    func Hiddenkeyboard(){
        self.view.endEditing(true)
    }

    @IBAction func btnRegisterClicked(_ sender: Any) {
        
        self.view.endEditing(true)
        
        checkPushNotiBeforeSignup()

    }
    
    
    func checkPushNotiBeforeSignup(){
        showTermsVC()
    }
    
    func showTermsVC(){
        let nav = UIStoryboard.TermNav()
        if let vc = nav.viewControllers.first as? UserTermsVC {
            vc.parentVC = self
            vc.isPrivacyPolicy = true
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    public func registerShow(){
        
        if viewModel.shouldRegisterWithFacebook() {
            viewModel.registerWithFacebook(success: { (validationObj:ValidationObj) in
                
                self.showParentChildLandingScreen()
                
                self.getMasterDataInBackground()
                
            }){
                (validationObj:ValidationObj) in
            }
        }else{
            viewModel.submitForm(success: { (validationObj:ValidationObj) in
                
                // immediately show the landing screen after registraion.
                self.showParentChildLandingScreen()
                self.getMasterDataInBackground()
                
                // this is old method which is to prompt "Go to Email to verify email"
                // self.showStandardDialog()
                
            }) { (validationObj:ValidationObj) in
                if let msg = validationObj.message() {
                    self.showAlert(msg)
                }
            }
        }
        
        AnalyticsHelper().analyticLogScreen(screen: "register_complete")
        
        AppFlyerHelper().trackScreen(screenName: "register_complete")
        
    }
    
    
    func goToNextScreen(){
        if let window = UIApplication.shared.keyWindow {
            let nav = UIStoryboard.AddChildNav()

            if let vc = nav.children.first {
                window.rootViewController = nav
                UIView.transition(from: self.view, to: vc.view, duration: 0.6, options: [.transitionFlipFromLeft], completion: {
                    _ in

                })
            }
        }
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
    
    func saveProfileImage(){
        
    }
    
    func removeImage(){
        
    }
    
    func getTempProfileImage(){
        
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

    
    func showStandardDialog(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Registration successful".localized()
        let message = "Please check your email to\nactivate account.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
            print("Completed")
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "GO TO EMAIL".localized()) {
            
            let googleUrlString = "googlegmail://"
            if let googleUrl = NSURL(string: googleUrlString) {
                // show alert to choose app
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(googleUrl as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (complete) in
                        if let url = NSURL(string: "message:"){
                            UIApplication.shared.openURL(url as URL)
                        }
                    })
                } else {
                    if !UIApplication.shared.openURL(googleUrl as URL){
                        if let url = NSURL(string: "message:"){
                            UIApplication.shared.openURL(url as URL)
                        }
                    }
                }
            }
            
            if let nav = self.navigationController {
                nav.popToRootViewController(animated: true)
            }
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


extension CreateProfileVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            updateProfileImage(img)
        }
    }
}

extension CreateProfileVC : RSKImageCropViewControllerDelegate {
 
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

extension CreateProfileVC : CountryCityDataDelegate {
    func didRecieveCountryData(data: CountryData) {
        viewModel.selectedCountry = data
    }
    
    func didRecieveCityData(data: CityData) {
        viewModel.selectedCity = data
    }

}

extension CreateProfileVC: UITextFieldDelegate { // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let txt = textField.text, let newRange = txt.range(from: range) {
            let replacedString = txt.replacingCharacters(in: newRange, with: string)
            updateViewModel(textField, replacedString)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateViewModel(textField, textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(lblFirstName == textField){
            lblLastName.becomeFirstResponder() // show keyboard
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func updateViewModel(_ textField:UITextField, _ text:String?) {
        if textField == lblFirstName {
            viewModel.firstName = text
        }else if textField == lblLastName {
            viewModel.lastName = text
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
