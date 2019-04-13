//
//  ChildrenLocationVC.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/7/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import SkyFloatingLabelTextField
import RealmSwift
import PKHUD
import GooglePlacePicker
import Device

protocol userLocationMapDelegate: class {
    func didRecieveMapData(_ boundaryName:String,_ placeID:String, _ userMapPosition : CLLocationCoordinate2D,  _ Address:String,_ AddressTitle:String,_ description:String,_ boundarySize:String )
    func didUpdateMapData(_ locationID: Int,_ boundaryName:String,_ placeID:String, _ userMapPosition : CLLocationCoordinate2D,  _ Address:String,_ AddressTitle:String,_ description:String,_ boundarySize:String )
}

class ChildrenLocationVC: _BaseViewController{
   // MARK: Variable init
    
    //Please use this ID for getting data from realm, which will come from my controller
    var locationID : Int = 0
    var tempstrzoomsize : String = ""
    
    var placesClient: GMSPlacesClient!
    var userPlace:GMSPlace!
    
    var userAddressTitle:String = ""
    var isMapViewEnabled : Bool = false
    var isButtonClicked : Bool = false
    
    var mapPostion : GMSCameraPosition!
    var isPlaceTitle : Bool = false
    var tempLbl : String!
    var currentlocation : CLLocation!
    var markerLocation : GMSMarker?
    var currentZoom : Float = 0.0
    var locationManager = CLLocationManager()
    var userLatitude = CLLocationDegrees()
    var userLongitude = CLLocationDegrees()
    var Address : String?
    var PlaceID : String = ""
    let planoColor = UIColor(red: 104.0/255.0, green: 206.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    let safeArea = UIImage(named: "safeArea")! as UIImage;
 
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var txtBoundaryName: SkyFloatingLabelTextField!
    @IBOutlet weak var btn350m: UIButton!
    @IBOutlet weak var btn550m: UIButton!
    @IBOutlet weak var btnOneK: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewMapView: UIView!
    
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var viewTextView: UIView!
    @IBOutlet weak var viewSearchView: UIView!
    @IBOutlet weak var lblLocationTitle: UILabel!
    @IBOutlet weak var lblLocationAddress: UILabel!
    @IBOutlet weak var imgPinCenter: UIImageView!
    
    
    //3_5 Inch Support
    @IBOutlet weak var btn350HeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var btn350WidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var btn550HeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var btn550WidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var btn1KHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var btn1KWidthConstraint : NSLayoutConstraint!
    
    var userBoundarySize : String = ""
    var mapdelegate: userLocationMapDelegate? = nil
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBarWithAttributes(navtitle: "Location", setStatusBarStyle: .lightContent , isTransparent: false , tintColor: Color.Cyan.instance(), titleColor: UIColor.white , titleFont: FontBook.Bold.of(size: 16))
        
        if Device.size() == .screen3_5Inch{
            // 50,60,70
            // 25,30,35
            
            btn350HeightConstraint.constant = 40
            btn350WidthConstraint.constant = 40
            btn350m.layer.cornerRadius = 20
            btn550HeightConstraint.constant = 50
            btn550WidthConstraint.constant = 50
            btn550m.layer.cornerRadius = 25
            btn1KHeightConstraint.constant = 60
            btn1KWidthConstraint.constant = 60
            btnOneK.layer.cornerRadius = 30
        }
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(false, animated: true)
        }
        self.lblLocationTitle.text = ""
        self.lblLocationAddress.text = "Please wait while fetching address"
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        placesClient = GMSPlacesClient.shared()
        
        viewSearchView.superview?.bringSubviewToFront(viewSearchView)
        viewTextView.superview?.bringSubviewToFront(viewTextView)
        
        txtBoundaryName.delegate = self
        txtBoundaryName.returnKeyType = .done
        configFloatingLabel(txtBoundaryName)
        txtBoundaryName.text = ""
        
        lblLocationAddress.lineBreakMode = .byWordWrapping
        lblLocationAddress.numberOfLines = 0
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true   // for current location enable
//        mapView.settings.myLocationButton = true // current location btn
        mapView.settings.compassButton = true  // compass
        mapView.isIndoorEnabled = false
        mapView.backgroundColor = UIColor.clear
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChildrenLocationVC.dismissKeyboard))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
//        self.mapView.settings.
        self.viewSearchView.addGestureRecognizer(tap)
        if(mapView.settings.zoomGestures == false){
                dismissKeyboard()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChildrenLocationVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChildrenLocationVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        if (locationID != 0){
            self.editTimeLocationSet()
        }else{
            self.MapViewSetup()
            self.getAddressForMapCenter()
        }
        self.btnSave.addTarget(self, action: #selector(btnSaveClicked(_:)), for: .touchUpInside)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.tempView.superview?.bringSubviewToFront(tempView)
            self.tempView.backgroundColor = UIColor.clear
             let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChildrenLocationVC.dismissKeyboard))
            tap.numberOfTapsRequired = 1
            self.tempView.addGestureRecognizer(tap)
            
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                tempView.superview?.sendSubviewToBack(tempView)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismissKeyboard()
        UIView.animate(withDuration: 0.5, animations: {
//            self.locationID = 0
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(isButtonClicked == true){
            
            UIView.animate(withDuration: 0.3, animations: {
                self.imgPinCenter.center = CGPoint(x: self.mapView.center.x, y: self.mapView.center.y)
            })
            
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.imgPinCenter.center = CGPoint(x: self.mapView.center.x, y: self.mapView.center.y-(self.imgPinCenter.frame.size.height/2))
            })
        }
    }
    override func btnBackClicked() {
        self.dismiss(animated: true, completion: nil)
    }

    override func configFloatingLabel(_ textField:SkyFloatingLabelTextField){
        
        let alignment:NSTextAlignment = .center
        let font = FontBook.Light.of(size: 13)
        let closure = { (text:String) -> String in
            return text
        }
        
        txtBoundaryName.delegate = self
        txtBoundaryName.textAlignment = alignment
        txtBoundaryName.titleLabel.textAlignment = alignment
        txtBoundaryName.titleLabel.font = font
        txtBoundaryName.titleFormatter = closure
        txtBoundaryName.titleFadeOutDuration = 0.2
        txtBoundaryName.errorColor = UIColor.red
        txtBoundaryName.selectedTitleColor = Color.DarkGrey.instance()
        txtBoundaryName.lineHeight = 0
        txtBoundaryName.selectedLineHeight = 0
        txtBoundaryName.autocorrectionType = .no
        txtBoundaryName.spellCheckingType = .no
        
    }
    // MARK:- EditTimeLocationSet
    func editTimeLocationSet(){
        if let obj = LocationSettingsData.getLocationByID(locationID: locationID){
        
         self.txtBoundaryName.text = obj.descriptionText
        tempstrzoomsize = (obj.zoomsize)
        if(tempstrzoomsize == "350"){
            funcbtn350()
        }else if(tempstrzoomsize == "550"){
            funcbtn550()
        }else if(tempstrzoomsize == "1000"){
            funcbtn1k()
        }
        self.lblLocationTitle?.text = obj.addressTitle // locationSetting[i].addressTitle
        self.lblLocationAddress?.text = obj.address
        let editLatitude = ((obj.latitude) as NSString).doubleValue
        let editLongitude = ((obj.longitude) as NSString).doubleValue
        
        print("EditLocation\(editLatitude),and \(editLongitude)")
        
        addGMSCameraPosition(editLatitude, editLongitude , currentZoom)
        
        isMapViewEnabled = true
        PlaceID = obj.placeID
        }
        
    }
    func MapViewSetup(){
        
        AnalyticsHelper().analyticLogScreen(screen: "newlocation")
        AppFlyerHelper().trackScreen(screenName: "newlocation")
        
        currentZoom = 15
        self.btn350m.backgroundColor = planoColor
        self.btn350m.setTitleColor(UIColor.white, for: UIControl.State.normal)
       
    }
    func getAddressForMapCenter() {
        
        let point : CGPoint =  CGPoint(x: self.mapView.center.x, y: self.mapView.center.y)
        let coordinate : CLLocationCoordinate2D = mapView.projection.coordinate(for: point)
        let location =  CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.GetAnnotationUsingCoordinated(location)
        
        print("\(location)")
    }
    // MARK: - GetAnnotationUsingCoordinate
    // get current address from geocode from apple, from location lat long
    func GetAnnotationUsingCoordinated(_ location : CLLocation) {
        
        GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (response, error) in
            var strAddresMain : String = ""
            
            if let address : GMSAddress = response?.firstResult() {
                if let lines = address.lines  {
                    if (lines.count > 0) {
                        if lines.count > 0 {
                            if lines[0].length > 0 {
                                strAddresMain = strAddresMain + lines[0]
                            }
                        }
                    }
                    
                    if (lines.count > 1) {
                        if (lines[1].length > 0) {
                            if (strAddresMain.length > 0){
                                strAddresMain = strAddresMain + ", \(lines[1])"
                            } else {
                                strAddresMain = strAddresMain + "\(lines[1])"
                            }
                        }
                    }
                    
                    if (strAddresMain.length > 0) {
                        print("strAddresMain : \(strAddresMain)")
                        if(self.isPlaceTitle == true){
                            
                            self.lblLocationTitle.text = self.tempLbl
                            print("isPlaceTitleTrue")
        
                            self.isPlaceTitle = false
                            
                        }else{
                            self.lblLocationTitle.text = ""
                            self.userAddressTitle = ""
                        }
                        
                        self.lblLocationAddress.text = strAddresMain
                        
                        var strSubTitle = ""
                        if let locality = address.locality {
                            strSubTitle = locality
                        }
                        
                        if let administrativeArea = address.administrativeArea {
                            if strSubTitle.length > 0 {
                                strSubTitle = "\(strSubTitle), \(administrativeArea)"
                            }
                            else {
                                strSubTitle = administrativeArea
                            }
                        }
                        
                        if let country = address.country {
                            if strSubTitle.length > 0 {
                                strSubTitle = "\(strSubTitle), \(country)"
                            }
                            else {
                                strSubTitle = country
                            }
                        }
                        
                        
                        if strSubTitle.length > 0 {
                            self.addPin_with_Title(strAddresMain, subTitle: strSubTitle, location: location)
                        }
                        else {
                            self.addPin_with_Title(strAddresMain, subTitle: "Your address", location: location)
                        }
                    }
                    else {
                        print("Location address not found")
                        self.lblLocationAddress.text = "Location address not found"
                    }
                }
                else {
                    self.lblLocationAddress.text = "Please change location, address is not available"
                    
                    print("Please change location, address is not available")
                }
            }
            else {
                self.lblLocationAddress.text  = "Address is not available"
                
                print("Address is not available")
            }
        }
    }
    
    // MARK:- PlaceID
    func getplaceID(){
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                //self.alertLocationSettingOpen()
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    print(place.placeID)
//                    self.userPlace = place
                    self.PlaceID = place.placeID
                }
            }
        })
    }
   // MARK:- CameraPosition
    func addGMSCameraPosition(_ latitude: CLLocationDegrees,_ longitude: CLLocationDegrees,_ zoom: Float) {
        
        if(isButtonClicked == true){
            
            UIView.animate(withDuration: 0.3, animations: {
                self.imgPinCenter.center = CGPoint(x: self.mapView.center.x, y: self.mapView.center.y)
            })
            
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.imgPinCenter.center = CGPoint(x: self.mapView.center.x, y: self.mapView.center.y-(self.imgPinCenter.frame.size.height/2))
            })
        }
        
        let cameras : GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        
        mapView.camera = cameras
        
    }
    
    func addPin_with_Title(_ title: String, subTitle: String, location : CLLocation) {
        
        if markerLocation == nil {
            markerLocation = GMSMarker.init() //GMSMarker.init(position: location.coordinate)
        }
    }
   // MARK:- ButtonClicked
    
    @IBAction func btnAutoSearchClick(_ sender: Any) {
        isPlaceTitle = true
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func btn350Clicked(_ sender: Any) {
        funcbtn350()
        addGMSCameraPosition(mapPostion.target.latitude, mapPostion.target.longitude , currentZoom)
    }
   
    @IBAction func btn550mClicked(_ sender: Any) {
        self.funcbtn550()
        addGMSCameraPosition(mapPostion.target.latitude, mapPostion.target.longitude , currentZoom)
    }
   
    @IBAction func btn1kmClicked(_ sender: Any) {
        funcbtn1k()
        addGMSCameraPosition(mapPostion.target.latitude, mapPostion.target.longitude , currentZoom)
    }
    @IBAction func btnSaveClicked(_ sender:UIButton) {
        if(mapdelegate != nil){
            if(txtBoundaryName.text?.isEmpty == true){
                txtBoundaryName.errorMessage = "Required"
//                txtBoundaryName.selectedTitleColor = Color.Red.instance()
                return
                
            }else{
                if(locationID == 0){
                    userdataSend()
                }else{
                    userdataUpdate()
                }
            }
        }
    }
    // TODO: Button function
    func funcbtn350(){
        userBoundarySize = "350"
        currentZoom = 15;
        isButtonClicked = true
        imgPinCenter.image = #imageLiteral(resourceName: "safeArea")
        btn350m.backgroundColor = planoColor
        btn350m.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        btn550m.backgroundColor = UIColor.white
        btn550m.setTitleColor(planoColor, for: UIControl.State.normal)
        
        btnOneK.backgroundColor = UIColor.white
        btnOneK.setTitleColor(planoColor, for: UIControl.State.normal)
    }
    func funcbtn550(){
        userBoundarySize = "550"
        currentZoom = 14;
        imgPinCenter.image = #imageLiteral(resourceName: "safeArea")
        isButtonClicked = true
        btn550m.backgroundColor = planoColor
        btn550m.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        btn350m.backgroundColor = UIColor.white
        btn350m.setTitleColor(planoColor, for: UIControl.State.normal)
        
        btnOneK.backgroundColor = UIColor.white
        btnOneK.setTitleColor(planoColor, for: UIControl.State.normal)
    }
    func funcbtn1k(){
        userBoundarySize = "1000"
        isButtonClicked = true
        btnOneK.backgroundColor = planoColor
        btnOneK.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        btn550m.backgroundColor = UIColor.white
        btn550m.setTitleColor(planoColor, for: UIControl.State.normal)
        
        btn350m.backgroundColor = UIColor.white
        btn350m.setTitleColor(planoColor, for: UIControl.State.normal)
        
        imgPinCenter.image = #imageLiteral(resourceName: "safeArea")
        currentZoom = 13;
    }
    
  
    // MARK:- userdataupdate
    func userdataUpdate(){
        
        let realm = try! Realm()
        try! realm.write {
            if let editData = LocationSettingsData.getLocationByID(locationID: locationID) {
                editData.descriptionText = txtBoundaryName.text!
                editData.latitude = "\(mapPostion.target.latitude)"
                editData.longitude = "\(mapPostion.target.longitude)"
                
//                if let value = userPlace.formattedAddress {
//                    editData.address = value
//                }
                if let tmp_address = self.lblLocationAddress.text{
                    editData.address = tmp_address
                }
//                editData.address =self.lblLocationAddress.text!
                if let title = self.lblLocationTitle.text{
                   editData.addressTitle = title
                }
//                editData.addressTitle = (self.lblLocationTitle?.text!)!
                editData.zoomsize = userBoundarySize
            }
        }
       
        if self.PlaceID.isEmpty == true {
            self.alertLocationSettingOpen()
            return
        }

        self.dismiss(animated: true, completion: {
                       self.mapdelegate?.didUpdateMapData(self.locationID, self.txtBoundaryName.text!, self.PlaceID, self.mapPostion.target, (self.lblLocationAddress?.text)!, (self.lblLocationTitle?.text)!,"Test",self.userBoundarySize)
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    func userdataSend(){
        
        if(userBoundarySize.isEmpty == true){
            userBoundarySize = "350"
        }
        if(self.PlaceID.isEmpty == true) {
            self.alertLocationSettingOpen()
            return
        }
 
        self.dismiss(animated: true, completion: {
            var tem_address : String = ""
            var tem_BoundaryName : String = ""
            
            if let address = self.lblLocationAddress.text{
                tem_address = address
            }
            if let boundayrname = self.txtBoundaryName.text{
                tem_BoundaryName = boundayrname
            }
            
            self.mapdelegate?.didRecieveMapData(tem_BoundaryName,self.PlaceID,
                                                self.mapPostion.target,tem_address,
                                                self.userAddressTitle,"Test",self.userBoundarySize)
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func alertLocationSettingOpen(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "Please turn on Location Service to access this feature",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Enable", style: .default) { (action) in
            if let url = NSURL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
 //   To hide keyboard when user clicks outside of the keyboard (other parts of the page)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
// MARK: GMSMap ViewDelegate

extension ChildrenLocationVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        mapView.clear()
        markerLocation?.map = mapView
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        view.endEditing(true)
        if(isMapViewEnabled == true){
                self.isMapViewEnabled = false
        }else{
            self.getAddressForMapCenter()
        }
        mapView.settings.zoomGestures = false
        mapView.settings.rotateGestures = false
        
        mapPostion = GMSCameraPosition(target: position.target, zoom: currentZoom, bearing: 0, viewingAngle: 0)
        addGMSCameraPosition(mapPostion.target.latitude, mapPostion.target.longitude , currentZoom)
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        print("\(position.target.latitude) \(position.target.longitude)")
    }
    
    
}
// MARK: - CLLocation Delegate
extension ChildrenLocationVC: CLLocationManagerDelegate {
    
    func locationManager( _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locationID != 0){
            return
        }
        
        if let location = locations.first {
            mapPostion = GMSCameraPosition(target: location.coordinate, zoom: currentZoom, bearing: 0, viewingAngle: 0)
            addGMSCameraPosition(location.coordinate.latitude, location.coordinate.longitude , currentZoom)
            locationManager.stopUpdatingLocation()
        }
        
        getplaceID()
    }
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .restricted, .denied: // authorizedAlways authorizedWhenInUse
            let alertController = UIAlertController(
                title: "Background Location Access Disabled".localized(),
                message: "In order to be notified about child device usage, please open this app's settings and set location access to 'Always'.".localized(),
                preferredStyle: .alert)
           //In order to be notified about adorable kittens near you, please open
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Enable", style: .default) { (action) in
                if let url = NSURL(string:UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}
// MARK: - GMS Place Delegate

extension ChildrenLocationVC: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
        
        self.lblLocationTitle.text = place.name
        self.lblLocationAddress.text = place.formattedAddress
        userAddressTitle = place.name
        
        if(isPlaceTitle == true){
            tempLbl = place.name
        }
        print("\(self.lblLocationTitle.text)")
        mapPostion = GMSCameraPosition(target: place.coordinate , zoom: currentZoom, bearing: 0, viewingAngle: 0)
        addGMSCameraPosition(mapPostion.target.latitude, mapPostion.target.longitude , currentZoom)
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
// MARK: - TextField Delegate
extension ChildrenLocationVC : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let finalString = txt.replacingCharacters(in: newRange, with: string)
            
            if finalString.characters.count > 0 {
                txtBoundaryName.errorMessage = ""
            }else{
                if(txtBoundaryName.text?.isEmpty == true){
                    txtBoundaryName.errorMessage = "Required"
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


