//
//  ParentsVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import PopupDialog

class ParentsVC: _BaseViewController {
    
    @IBOutlet weak var tblParents : UITableView!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    @IBOutlet weak var noLinkedAccountsView : UIView!
    
    var linkedAccounts : Results<LinkedAccounts>!
    var viewModel = LinkedAccountsViewModel()
    
    let placeholderImage = UIImage(named: "iconAvatar")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGuardiansView()
        viewModelCallBacks()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getParentsIAmLinkedTo()
    }
    
    func viewModelCallBacks(){
        
        viewModel.beforeApiCall = {
            self.loadingIndicator.startAnimating()
        }
        
        viewModel.afterApiCall = {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpGuardiansView(){
        
        tblParents.isHidden = true
        noLinkedAccountsView.isHidden = true
        
        tblParents.register(UINib(nibName : "LinkedAccountsCell", bundle : nil), forCellReuseIdentifier: "LinkedAccountsCell")
        tblParents.register(UINib(nibName : "LinkedAccountsHeaderView", bundle : nil), forCellReuseIdentifier: "LinkedAccountsHeaderView")
        
        tblParents.estimatedRowHeight = 100
        tblParents.rowHeight = UITableView.automaticDimension
        tblParents.separatorInset.left = 0
        tblParents.separatorInset.right = 0
        tblParents.showsVerticalScrollIndicator = false
        tblParents.tableFooterView = UIView(frame: .zero)
        
    }
    
    func getParentsIAmLinkedTo(){
        viewModel.getLinkedAccounts(success: { 
            
            self.linkedAccounts = LinkedAccounts.getAccountsIAmLinkTo()
            
            if self.linkedAccounts.count == 0 || self.linkedAccounts == nil{
                self.tblParents.isHidden = true
                self.noLinkedAccountsView.isHidden = false
            }else{
                UIView.transition(with: self.tblParents, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.noLinkedAccountsView.isHidden = true
                    self.tblParents.isHidden = false
                    self.tblParents.reloadData()
                    
                }, completion: nil)
            }
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
    
    @objc func unLinkAccount(sender : UIButton){
        viewModel.statusCode = linkedAccounts[sender.tag].statusCode
        viewModel.guardianEmail = linkedAccounts[sender.tag].email
        let name = linkedAccounts[sender.tag].firstName + " " + linkedAccounts[sender.tag].lastName
        showUnlinkedAccountDialog(accountName: name)
    }
    
    func showUnlinkedAccountDialog(accountName : String) {
        
        // Prepare the popup
        let title = "Unlink account".localized()
        let message = "Are you sure you want to unlink account with \(accountName)".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "NO".localized()) {
        }
        
        let buttonTwo = DefaultButton(title: "YES".localized()) {
            
            self.viewModel.updateLinkedAccount(success: { 
                
                self.getParentsIAmLinkedTo()
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
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
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne,buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
}

extension ParentsVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if linkedAccounts != nil{
            return linkedAccounts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedAccountsCell") as! LinkedAccountsCell
        
        let accounts = linkedAccounts[indexPath.row]
        
        cell.lblName.text = accounts.firstName + " " + accounts.lastName
        cell.imgProfile.kf.setImage(with: URL(string: accounts.profileImage), placeholder: placeholderImage,options: [.transition(.fade(0.5))])
        cell.btnUnLink.tag = indexPath.row
        cell.btnUnLink.addTarget(self, action: #selector(ParentsVC.unLinkAccount(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "LinkedAccountsHeaderView") as! LinkedAccountsHeaderView
        view.backgroundColor = UIColor.white
        
        if section == 0{
            if linkedAccounts == nil{
                view.lblCount.text = ""
                view.lblCountTitle.text = ""
            }else{
                view.lblCount.text = String(linkedAccounts.count)
                view.lblCountTitle.text = "Linked accounts".localized()
            }
        }else{
            view.lblCount.text = ""
            view.lblCountTitle.text = ""
        }
        
        return view
    }
}
