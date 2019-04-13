//
//  PendingRequestsVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PopupDialog

class PendingRequestsVC: _BaseViewController {

    @IBOutlet weak var tblRequests : UITableView!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    @IBOutlet weak var noRequestsView : UIView!
    
    var pendingRequests : Results<PendingRequests>!
    var viewModel = LinkedAccountsViewModel()
    
    let placeholderImage = UIImage(named: "iconAvatar")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPendingRequestsView()
        viewModelCallBacks()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPendingRequests()
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
    
    func setUpPendingRequestsView(){
        
        tblRequests.isHidden = true
        noRequestsView.isHidden = true
        
        tblRequests.register(UINib(nibName : "PendingRequestsCell", bundle : nil), forCellReuseIdentifier: "PendingRequestsCell")
        tblRequests.register(UINib(nibName : "RequestsHeaderView", bundle : nil), forCellReuseIdentifier: "RequestsHeaderView")
        
        tblRequests.estimatedRowHeight = 100
        tblRequests.rowHeight = UITableView.automaticDimension
        tblRequests.separatorInset.left = 0
        tblRequests.separatorInset.right = 0
        tblRequests.showsVerticalScrollIndicator = false
        tblRequests.tableFooterView = UIView(frame: .zero)
        
    }
    
    func getPendingRequests(){
        viewModel.getPendingLinkedAccounts(success: { _ in
            
            self.pendingRequests = PendingRequests.getPendingRequest()
            
            if self.pendingRequests.count == 0 || self.pendingRequests == nil{
                self.tblRequests.isHidden = true
                self.noRequestsView.isHidden = false
            }else{
                UIView.transition(with: self.tblRequests, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.noRequestsView.isHidden = true
                    self.tblRequests.isHidden = false
                    self.tblRequests.reloadData()
                    
                }, completion: nil)
            }
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
    
    @objc func cancelAccount(sender : UIButton){
        
        viewModel.guardianEmail = pendingRequests[sender.tag].email
        viewModel.rejectPendingLinkedAccount(success: { _ in
            
            self.rejectSuccessfully()
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
    
    func rejectSuccessfully(animated: Bool = true) {
        
        // Prepare the popup
        let title = ""
        let message = "Updated pending account.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.getPendingRequests()
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

extension PendingRequestsVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingRequests != nil{
            return pendingRequests.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestsCell") as! PendingRequestsCell
        
        let accounts = pendingRequests[indexPath.row]
        
        cell.lblName.text = accounts.firstName + " " + accounts.lastName
        cell.imgProfile.kf.setImage(with: URL(string: accounts.profileImage), placeholder: placeholderImage,options: [.transition(.fade(0.5))])
        cell.btnCancel.tag = indexPath.row
        cell.btnCancel.addTarget(self, action: #selector(PendingRequestsVC.cancelAccount(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "RequestsHeaderView") as! RequestsHeaderView
        view.backgroundColor = UIColor.white
        
        if section == 0{
            if pendingRequests == nil{
                view.lblCount.text = ""
                view.lblCountTitle.text = ""
            }else{
                view.lblCount.text = String(pendingRequests.count)
                view.lblCountTitle.text = "Requests".localized()
            }
        }else{
            view.lblCount.text = ""
            view.lblCountTitle.text = ""
        }
        
        return view
    }
}
