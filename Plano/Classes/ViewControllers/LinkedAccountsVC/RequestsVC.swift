//
//  RequestsVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PopupDialog

class RequestsVC: _BaseViewController {
    
    @IBOutlet weak var tblRequests : UITableView!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!
    @IBOutlet weak var noRequestsView : UIView!
    
    var requests : Results<PendingRequests>!
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
        getOtherParentsRequests()
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
        
        tblRequests.isHidden = true
        noRequestsView.isHidden = true
        
        tblRequests.register(UINib(nibName : "RequestsCell", bundle : nil), forCellReuseIdentifier: "RequestsCell")
        tblRequests.register(UINib(nibName : "RequestsHeaderView", bundle : nil), forCellReuseIdentifier: "RequestsHeaderView")
        
        tblRequests.estimatedRowHeight = 100
        tblRequests.rowHeight = UITableView.automaticDimension
        tblRequests.separatorInset.left = 0
        tblRequests.separatorInset.right = 0
        tblRequests.showsVerticalScrollIndicator = false
        tblRequests.tableFooterView = UIView(frame: .zero)
        
    }
    
    func getOtherParentsRequests(){
        viewModel.getPendingLinkedAccounts(success: { 
            
            self.requests = PendingRequests.getRequests()
            
            if self.requests.count == 0 || self.requests == nil{
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
    
    @objc func acceptAccount(sender : UIButton){
        viewModel.guardianEmail = requests[sender.tag].email
        viewModel.accept = 1
        viewModel.updateRequestLink(success: { 
            
            self.showUpdatedSuccessfully()
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
    
    @objc func denyAccount(sender : UIButton){
        viewModel.guardianEmail = requests[sender.tag].email
        viewModel.accept = 0
        viewModel.updateRequestLink(success: { 
            
            self.showUpdatedSuccessfully()
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
    
    func showUpdatedSuccessfully(animated: Bool = true) {
        
        // Prepare the popup
        let title = ""
        let message = "Your accounts have been linked.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.getOtherParentsRequests()
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

extension RequestsVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requests != nil{
            return requests.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        let accounts = requests[indexPath.row]
        
        cell.lblName.text = accounts.firstName + " " + accounts.lastName
        cell.imgProfile.kf.setImage(with: URL(string: accounts.profileImage), placeholder: placeholderImage,options: [.transition(.fade(0.5))])
        cell.btnAccept.tag = indexPath.row
        cell.btnDeny.tag = indexPath.row
        cell.btnAccept.addTarget(self, action: #selector(RequestsVC.acceptAccount(sender:)), for: .touchUpInside)
        cell.btnDeny.addTarget(self, action: #selector(RequestsVC.denyAccount(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCell(withIdentifier: "RequestsHeaderView") as! RequestsHeaderView
        view.backgroundColor = UIColor.white
        
        if section == 0{
            if requests == nil{
                view.lblCount.text = ""
                view.lblCountTitle.text = ""
            }else{
                view.lblCount.text = String(requests.count)
                view.lblCountTitle.text = "Requests".localized()
            }
        }else{
            view.lblCount.text = ""
            view.lblCountTitle.text = ""
        }
        
        return view
    }
}
