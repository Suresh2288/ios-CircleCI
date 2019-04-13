
//
//  Pop_AddSchedulePeriodViewController.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/4/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PKHUD
import SwiftDate
import RealmSwift

protocol userperiodDelegate: class {
    // SchedulePeriod FormTime ToTime name
    func didPeriodData(_ SchedulePeriod:String,_ FromTime:String, _ ToTime:String,_ ScheduleTitle:String)
    func didDataUpdated(_ ScheduleID:Int ,_ SchedulePeriod:String,_ FromTime:String, _ ToTime:String,_ ScheduleTitle:String)
}

class PopAddSchedulePeriodVC: _BaseViewController {
    
    //Please use this ID for getting data from realm, which will come from my controller
    var scheduleID : Int = 0
    
    var selectedArray:[Int] = [0,0,0,0,0,0,0,0]
    var show_daylist:[String] = ["Every Day", "Mon","Tue", "Wed","Thus", "Fri","Sat", "Sun"]
    var isFromOpened  : Bool = false
    var isToOpened : Bool = false
    var testhight : Bool = false
    var fromTimeData : String = ""
    var toTimeData : String = ""
    var schedulePeriodData : String = "0"
    var periodelegate: userperiodDelegate? = nil

    var tempdateFormatter = DateFormatter()
    
    @IBOutlet weak var btnForm: UIButton!
    @IBOutlet weak var btnTo: UIButton!
    @IBOutlet weak var btnSchedulePeriod: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var txtSchedule: SkyFloatingLabelTextField!
    
    @IBOutlet weak var popView: UIView?
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    
    @IBOutlet weak var schedulePickerView : UIView!
    
    @IBOutlet weak var timePickerHeight: NSLayoutConstraint!
    
    var daylist:[String] = ["Every Day","Mon","Tue","Wed","Thus","Fri","Sat","Sun"]
    
    override func viewDidLoad() {

        super.viewDidLoad()
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
        
        let color = UIColor.black
        let blackTrans = UIColor.withAlphaComponent(color)(0.8)
        schedulePickerView.backgroundColor = blackTrans
        
        tempdateFormatter.dateFormat = "HH:mm"
        initTxtFields()
        iniFloatingLabel()

        if(scheduleID != 0){
            self.editTimeDataSet()
        }else{
            self.timepickerSetup()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChildrenLocationVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChildrenLocationVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= 70
            }
            toTimeCloseClicked()
            FromTime_CloseClicked()
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopAddSchedulePeriodVC.dismissKeyboard))
            tap.delegate = self
            tap.numberOfTapsRequired = 1
            popView?.addGestureRecognizer(tap)
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            //            viewMapView.superview?.sendSubview(toBack: viewMapView)
                if self.view.frame.origin.y != 0{
                            self.view.frame.origin.y += 70
                }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            let defaults = UserDefaults.standard
            defaults.set(nil, forKey: "DateEditString")
        })
    }
   // MARK:- ButtonAction
    @IBAction func btnFromClicked(_ sender: Any) {
        view.endEditing(true) // to keyboard hidden
        if (!isFromOpened) {
            toTimeCloseClicked()
            self.FromTime_OpenClicked()
        }else{
            self.FromTime_CloseClicked()
        }
    }
    
    func FromTime_OpenClicked() {
        isFromOpened = true
        self.fromTimePicker.alpha = 1
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.fromTimePicker.isHidden = false
            self.timePickerHeight.constant = 126.0
            self.view.layoutIfNeeded()
        }
    }
    
    func FromTime_CloseClicked() {
        
        isFromOpened = false
        self.fromTimePicker.alpha = 0
        self.fromTimePicker.isHidden = true
        self.btnTo.isEnabled = true
        
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.timePickerHeight.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
   
    @IBAction func btnToClicked(_ sender: Any) {
        view.endEditing(true) // to keyboardaction
        
        if (!isToOpened) {
            FromTime_CloseClicked()
            self.toTimeOpenClicked()
        }else{
            self.toTimeCloseClicked()
        }
    }
    
    func toTimeOpenClicked() {
        
        isToOpened = true
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.toTimePicker.alpha = 1
            self.toTimePicker.isHidden = false
            self.timePickerHeight.constant = 126.0
            self.view.layoutIfNeeded()
        }
    }
    
    func toTimeCloseClicked() {
        
        isToOpened = false
        self.btnForm.isEnabled = true
        self.toTimePicker.alpha = 0
        self.toTimePicker.isHidden = true
        
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.timePickerHeight.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        view.endEditing(true) // to keyboard action
        if(periodelegate != nil){
            toTimeCloseClicked()
            FromTime_CloseClicked()
            
            if(txtSchedule.text?.isEmpty == true ){
                // everytime dismiss view, delegates needs to call after completion
                txtSchedule.errorMessage = "Required"
            }else{
                if(scheduleID == 0){
                    ScheduleCreated()
                }else{
                     UpdateSchedule() 
                }
            }
        }
    }
    func ScheduleCreated(){
        dismiss(animated: true, completion: {
            self.periodelegate?.didPeriodData(self.schedulePeriodData,
                                              self.fromTimeData,
                                              self.toTimeData,
                                              self.txtSchedule.text!)
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    func UpdateSchedule(){
//        let realm = try! Realm()
//        try! realm.write {
//            if let editData = ScheduleSettingsData.getScheduleByID(scheduleID: scheduleID){
//            editData.titleText = txtSchedule.text!
//            editData.fromTime = fromTimeData
//            editData.toTime = toTimeData
//            editData.schedulePeriod = schedulePeriodData
//            }
//        }
        dismiss(animated: true, completion: {
            self.periodelegate?.didDataUpdated(self.scheduleID, self.schedulePeriodData, self.fromTimeData, self.toTimeData, self.txtSchedule.text!)
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ScheduleClicked(_ sender: Any) {
        view.endEditing(true)
        toTimeCloseClicked()
        FromTime_CloseClicked()
    }
    @IBAction func btnScheduleClicked(_ sender: Any) {
        view.endEditing(true)
        toTimeCloseClicked()
        FromTime_CloseClicked()
    }
    //MARK:- pickerTimeClicked
    @IBAction func pickerToTimeClicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let strDate = dateFormatter.string(from: toTimePicker.date)
        print("\(strDate)")
        
        toTimeData = tempdateFormatter.string(from: toTimePicker.date)
        self.btnTo.setTitle(strDate, for: .normal)
    }
    
    @IBAction func pickerFromTimeClicked(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let strDate = dateFormatter.string(from: fromTimePicker.date)
        
        fromTimeData = tempdateFormatter.string(from: fromTimePicker.date)
        self.btnForm.setTitle(strDate,for: .normal)
        
        toTimePicker.date = fromTimePicker.date.addingTimeInterval(3600)
        self.btnTo.setTitle(dateFormatter.string(from: toTimePicker.date), for: .normal)
        
        toTimeData = tempdateFormatter.string(from: toTimePicker.date)
        
    }
   
    func editTimeDataSet(){
       
        if let obj = ScheduleSettingsData.getScheduleByID(scheduleID: scheduleID){
       
            self.txtSchedule.text = obj.titleText

            if let str = obj.toTime.convertFromUTCTimestamp() {
                toTimeData = str
            }
            if let str = obj.fromTime.convertFromUTCTimestamp() {
                fromTimeData = str
            }
            
            let dateFormatte = DateFormatter()
            dateFormatte.dateFormat = "HH:mm"
            timePickerHeight.constant = 0
            self.toTimePicker.isHidden = true
            self.toTimePicker.alpha = 0
            self.fromTimePicker.isHidden = true
            self.fromTimePicker.alpha = 0
            
            let tempFromDate = dateFormatte.date(from: fromTimeData)
            let temptoDate = dateFormatte.date(from:toTimeData )
            
            dateFormatte.dateFormat = "h:mm a"
            let strToDate = dateFormatte.string(from: temptoDate!)
            self.btnTo.setTitle(strToDate, for: .normal)
            toTimePicker.date = dateFormatte.date(from: strToDate)!
            
            let strFromDate = dateFormatte.string(from: tempFromDate!)
            self.btnForm.setTitle(strFromDate, for: .normal)
            fromTimePicker.date = dateFormatte.date(from: strFromDate)!
            
            schedulePeriodData = obj.schedulePeriod
            PeriodEditDate(schedulePeriodData)
            
            toTimePicker.date = fromTimePicker.date.addingTimeInterval(3600)

        }
    }
    func PeriodEditDate(_ Period: String){
        let values = Period.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
      
        if values.index(of: 0) != nil {
            selectedArray = [1,1,1,1,1,1,1,1]
            
        }else{
            for _ in 0...values.count{
                if values.index(of: 5) != nil {
                    selectedArray[5] = 1
                }
                if values.index(of: 6) != nil {
                    selectedArray[6] = 1
                }
                if values.index(of: 7) != nil {
                    selectedArray[7] = 1
                }
                if values.index(of: 1) != nil {
                    selectedArray[1] = 1
                }
                if values.index(of: 2) != nil {
                    selectedArray[2] = 1
                }
                if values.index(of: 3) != nil {
                    selectedArray[3] = 1
                }
                if values.index(of: 4) != nil {
                    selectedArray[4] = 1
                }
            }
        }
        var temp_arr : [String] = []
        if(selectedArray[0]==1){
            temp_arr.append(show_daylist[0])
            
        }else{
            for i in 1...7{
                
                if(selectedArray[i]==1){
                    let str_daylist: String = show_daylist[i]
                    temp_arr.append(str_daylist)
                }
            }
        }
        self.btnSchedulePeriod.setTitle(temp_arr.joined(separator: " "), for: .normal)
        
    }
    func timepickerSetup(){
        
        AnalyticsHelper().analyticLogScreen(screen: "newschedule")
        AppFlyerHelper().trackScreen(screenName: "newschedule")
        
        timePickerHeight.constant = 0
        self.toTimePicker.isHidden = true
        self.toTimePicker.alpha = 0
        self.fromTimePicker.isHidden = true
        self.fromTimePicker.alpha = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:00 a"
        
        let dateFormatterDem = DateFormatter()
        dateFormatterDem.dateFormat = "HH:00"
        
        let strFromDate = dateFormatter.string(from: fromTimePicker.date.addingTimeInterval(0))
        let strToDate = dateFormatter.string(from: toTimePicker.date.addingTimeInterval(3600))
        
        toTimeData = dateFormatterDem.string(from: toTimePicker.date.addingTimeInterval(3600))
        fromTimeData = dateFormatterDem.string(from: fromTimePicker.date)
        
        toTimePicker.date = fromTimePicker.date.addingTimeInterval(3600)
        
        self.btnForm.setTitle(strFromDate,for: .normal)
        self.btnTo.setTitle(strToDate,for: .normal)
    }
    
    func initTxtFields() {
        txtSchedule.returnKeyType = .done
    }
    
    func iniFloatingLabel() {
        
        // config Fonts, Format, etc
        configFloatingLabel(txtSchedule)
        txtSchedule.delegate = self
        
    }
    override func configFloatingLabel(_ textField:SkyFloatingLabelTextField){
        
        let alignment:NSTextAlignment = .center
        let font = FontBook.Light.of(size: 13)
        let closure = { (text:String) -> String in
            return text
        }
        
        txtSchedule.textAlignment = alignment
        txtSchedule.titleLabel.textAlignment = alignment
        txtSchedule.titleLabel.font = font
        txtSchedule.titleFormatter = closure
        txtSchedule.titleFadeOutDuration = 0.2
        txtSchedule.errorColor = UIColor.red
        txtSchedule.selectedTitleColor = Color.DarkGrey.instance()
        txtSchedule.lineHeight = 0
        txtSchedule.selectedLineHeight = 0
    
        txtSchedule.autocorrectionType = .no
        txtSchedule.spellCheckingType = .no
        
    }
    
    func userDidEnterData(data: String, senddata: String, selectedarray: Array<Any>) {
        
        if(data.isEmpty == true){
            self.selectedArray = [1,1,1,1,1,1,1,1]
            self.btnSchedulePeriod.setTitle("Every Day", for: .normal)
        }else{
            self.btnSchedulePeriod.setTitle(data, for: .normal)
            schedulePeriodData = senddata
            self.selectedArray = selectedarray as! [Int]
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPeriodVC" {
            let sendingVC: PopScheduleDayVC = segue.destination as! PopScheduleDayVC
            sendingVC.period_delegate = self
            sendingVC.selectedArray = selectedArray
            sendingVC.modalPresentationStyle = .overCurrentContext
        }
    }
    
}
//MARK:- delegate
extension PopAddSchedulePeriodVC : SchedulePeriodDelegate{
    
}
// MARK: - TextField delegate
extension PopAddSchedulePeriodVC : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /*
         abcd
         
         a
         textField.text => ""
         range => 0,1
         string => a
         
         "a"
         
         ab
         textField.text => "a"
         range => 1,1
         string => b
         
         "ab"
         
         */
        
        if let txt = textField.text, let newRange = txt.range(from: range) {
            
            let finalString = txt.replacingCharacters(in: newRange, with: string)
            
            if finalString.characters.count > 0 {
                txtSchedule.errorMessage = ""
                toTimeCloseClicked()
                FromTime_CloseClicked()
                
            }else{
                if(txtSchedule.text?.isEmpty == true){
                    txtSchedule.errorMessage = "Required"
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
