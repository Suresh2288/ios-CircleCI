//
//  FAQVC.swift
//  Plano
//
//  Created by Thiha Aung on 9/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import SwiftyUserDefaults

class FAQVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "faq"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "faq"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    var viewModel = FAQViewModel()
    var faqList : Results<FAQs>!
    var isPresented : Bool = false
    
    @IBOutlet weak var tblFAQ : UITableView!
    @IBOutlet weak var txtFAQSearch : UITextField!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent FAQ Page",pageName:"FAQ Page",actionTitle:"Entered in FAQ page")

        setupMenuNavBarWithAttributes(navtitle: "FAQ", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        
        setUpFAQView()
        
        viewModelCallBack()
        
    }
    
    func setUpFAQView(){
        
        tblFAQ.register(UINib(nibName : "FAQCell", bundle : nil), forCellReuseIdentifier: "FAQCell")
        
        tblFAQ.estimatedRowHeight = 100
        tblFAQ.rowHeight = UITableView.automaticDimension
        tblFAQ.showsVerticalScrollIndicator = false
        tblFAQ.separatorInset.left = 0
        tblFAQ.separatorInset.right = 0
        tblFAQ.tableFooterView = UIView(frame: .zero)
        
        let faqTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tblFAQ.addGestureRecognizer(faqTapGesture)
        tblFAQ.keyboardDismissMode = .onDrag
        
        tblFAQ.delegate = self
        tblFAQ.dataSource = self
        
        txtFAQSearch.tintColor = Color.Cyan.instance()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isPresented{
            viewModel.getFAQs(success: { 
                
                self.faqList = FAQs.getFAQs()
                
                UIView.transition(with: self.tblFAQ, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.tblFAQ.reloadData()
                    
                }, completion: nil)
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
            }
            isPresented = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewModelCallBack(){
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
    
    @objc func dismissKeyboard(){
        txtFAQSearch.resignFirstResponder()
    }
    
}

extension FAQVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if faqList == nil{
            return 0
        }
        return faqList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as! FAQCell
        
        cell.lblQuestion.text = faqList[indexPath.row].question
        cell.lblAnswer.text = faqList[indexPath.row].answer
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension FAQVC : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let searchText = textField.text!.trimmingCharacters(in: .whitespaces)
        if searchText == ""{
            faqList = FAQs.getFAQs()
        }else{
            faqList = FAQs.getFAQBySearchText(searchText: searchText)
        }
        
        UIView.transition(with: self.tblFAQ, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
            
            self.tblFAQ.reloadData()
            self.tblFAQ.setContentOffset(CGPoint.zero, animated: true)
            
        }, completion: nil)
        
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// 'calculateHeight' inspired by https://stackoverflow.com/a/42111135/3378606
// TODO: - Still need to find better solution
// The reason of using calculateHeight was we can't use UITableViewAutomaticDimension at 'heightForHeaderInSection' when rendering the dynamic height of UITableView header.

//func calculateHeight(inString : String) -> CGFloat{
//    
//    let messageString = inString
//    let attributes : [String : Any] = [NSFontAttributeName : FontBook.Bold.of(size: 17.0)]
//    
//    let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
//    
//    // 40 = total of left and right spacing (FAQ Table View)
//    // 20 - 13 - 12 = total of spacing between lblQuestion and imgArrow
//    
//    let rect : CGRect = attributedString.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 40 - 20 - 13 - 12, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
//    
//    return rect.height
//    
//}
