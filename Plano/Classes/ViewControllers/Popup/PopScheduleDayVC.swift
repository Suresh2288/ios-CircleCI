//
//  PopScheduleDayVC.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/4/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit



protocol SchedulePeriodDelegate {
    func userDidEnterData(data: String,senddata: String, selectedarray:Array<Any>)
}

class PopScheduleDayVC: _BaseViewController ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var dayView : UIView!
    
    @IBOutlet weak var dayTable: UITableView!
    var numberArray: [Int] = []
    var testArray: [Int] = []
    var temp_arr: [String]  = []
    var selectedArray:[Int] = [0,0,0,0,0,0,0,0]
    var temp_array:[Int] = [0,1,1,1,1,1,1,1]
    var daylist:[String] = ["Every Day", "Monday","Tuesday", "Wednesday","Thursday", "Friday","Saturday", "Sunday"]
    var show_daylist:[String] = ["Every Day", "Mon","Tue", "Wed","Thus", "Fri","Sat", "Sun"]
    var dateEditData :String = ""
    var period_delegate: SchedulePeriodDelegate? = nil // for delegate
    var data = PopAddSchedulePeriodVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 1...8 {
            numberArray.append(index)
        }
        
        let color = UIColor.black
        let blackTrans = UIColor.withAlphaComponent(color)(0.8)
        dayView.backgroundColor = blackTrans
        
//        editSelected()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIView.animate(withDuration: 0.5, animations: {
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return numberArray.count;
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat
    {
        return 42.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:PopDayTableCell = dayTable.dequeueReusableCell(withIdentifier: "DayPeriodCell") as! PopDayTableCell
        
        let date_lbl = daylist[indexPath.row]
        cell.lbl_day?.text = String("\(date_lbl) ")
        let cellValue = selectedArray[indexPath.row]
        let cellValueBool = cellValue == 1 ? true : false
        cell.checkbox.setOn(cellValueBool,animated : true)
        cell.isSelected = cellValueBool
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:PopDayTableCell = tableView.cellForRow(at: indexPath) as! PopDayTableCell
        
        if(indexPath.row == 0){
            if(selectedArray[0]==1){
                cell.checkbox.setOn(false , animated : true)
                selectedArray = [0,0,0,0,0,0,0,0]
                for i in 1...7 {
                    let ip = IndexPath(row: i, section: 0)
                    tableView.deselectRow(at: ip, animated: false)
                    let insideCell:PopDayTableCell = tableView.cellForRow(at: ip) as! PopDayTableCell
                    insideCell.checkbox.setOn(false,animated : true)
                }
            }else{
            cell.checkbox.setOn(true , animated : true)
            selectedArray = [1,1,1,1,1,1,1,1]
            
            for i in 1...7 {
                let ip = IndexPath(row: i, section: 0)
                tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
                let insideCell:PopDayTableCell = tableView.cellForRow(at: ip) as! PopDayTableCell
                insideCell.checkbox.setOn(true,animated : true)
                }
            }
        }else{
            let ipp = IndexPath(row: 0, section: 0)

            if(selectedArray[indexPath.row] == 1){
                cell.checkbox.setOn(false , animated : true)
                self.selectedArray[indexPath.row] = 0
    
                selectedArray[0] = 0;
                let insideCell:PopDayTableCell = tableView.cellForRow(at: ipp) as! PopDayTableCell
                insideCell.checkbox.setOn(false,animated : true)


            }else{
                self.selectedArray[indexPath.row] = 1
                cell.checkbox.setOn(true , animated : true)
                
                if(selectedArray == temp_array){
                    selectedArray[0] = 1;
                    let insideCell:PopDayTableCell = tableView.cellForRow(at: ipp) as! PopDayTableCell
                    insideCell.checkbox.setOn(true,animated : true)
                    
                }

            }
           
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell:PopDayTableCell = tableView.cellForRow(at: indexPath) as! PopDayTableCell
        // tableView.reloadData()
       
        if(indexPath.row == 0){
            if(selectedArray[indexPath.row] == 0){

                cell.checkbox.setOn(true , animated : true)
                selectedArray = [1,1,1,1,1,1,1,1]
                
                for i in 1...7 {
                    let ip = IndexPath(row: i, section: 0)
                    tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
                    let insideCell:PopDayTableCell = tableView.cellForRow(at: ip) as! PopDayTableCell
                    insideCell.checkbox.setOn(true,animated : true)
                }
            }else{
                cell.checkbox.setOn(false , animated : true)
                selectedArray = [0,0,0,0,0,0,0,0]
                for i in 1...7 {
                    let ip = IndexPath(row: i, section: 0)
                    tableView.deselectRow(at: ip, animated: false)
                    let insideCell:PopDayTableCell = tableView.cellForRow(at: ip) as! PopDayTableCell
                    insideCell.checkbox.setOn(false,animated : true)
                }
            }
        }else{
            let ipp = IndexPath(row: 0, section: 0)
            if(selectedArray[indexPath.row] == 0){
                self.selectedArray[indexPath.row] = 1
                cell.checkbox.setOn(true , animated : true)
                
                if(selectedArray == temp_array){
                    selectedArray[0] = 1;
                    let insideCell:PopDayTableCell = tableView.cellForRow(at: ipp) as! PopDayTableCell
                    insideCell.checkbox.setOn(true,animated : true)
                }

            }else{
                cell.checkbox.setOn(false , animated : true)
                self.selectedArray[indexPath.row] = 0
                selectedArray[0] = 0;
                let insideCell:PopDayTableCell = tableView.cellForRow(at: ipp) as! PopDayTableCell
                insideCell.checkbox.setOn(false,animated : true)
                    
        
            }
            
         
        }
        
    }
    
    func report(info: String) {
        print("delegate: \(info)")
    }
    
    
    @IBAction func btnBackClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any){
        if (period_delegate != nil)
        {
            let send_daylist:[String] = ["0","1","2", "3","4", "5","6","7"]
            var tmpSendarr : [String] = []
            var stringRepresentation = ""
            if(selectedArray[0]==1){
                temp_arr.append(show_daylist[0])
                stringRepresentation = "0"
                
            }else{
                for i in 1...7{
                    
                    if(selectedArray[i]==1){
                        let str_daylist: String = show_daylist[i]
                        temp_arr.append(str_daylist)
                        let str_sendlist: String = send_daylist[i]
                        tmpSendarr.append(str_sendlist)
                        
                    }
                    
                }
                stringRepresentation = tmpSendarr.joined(separator: ",")
            }
            
            let periodString = temp_arr.joined(separator: " ")
            print("\(periodString)")
            
            if (selectedArray.count != 0) {
                period_delegate?.userDidEnterData(data: periodString, senddata:stringRepresentation,selectedarray: selectedArray)

                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)            }
        }
    }
    
}
