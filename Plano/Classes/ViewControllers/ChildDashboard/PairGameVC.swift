//
//  PairGameVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import PKHUD
import PopupDialog

class PairGameVC : _BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    var viewModel = ChildDashboardViewModel()

    var gameDataOriginal = [PairGameObj]()
    var gameData:[PairGameObj] = [PairGameObj]()
    
    var isGameAnimating = false
    var firstRevealedItem:PairGameObj?
    var secondRevealedItem:PairGameObj?
    var timer:Timer?
    var bestTimeRecordInSeconds:Float = 0 // in Seconds
    
    var gameCounter:Int = 8 {
        didSet {
//            lblCounter.text = "\(gameCounter)"
        }
    }
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBarWithAttributes(navtitle: "plano pairs".localized(), setStatusBarStyle: .default, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16))
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(false, animated: true)
        }
        
        initView()
        setUpCollectionViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Child Game Play Page",pageName:"Game Play Page",actionTitle:"Playing Pair Game")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(){
        collectionView.dataSource = nil
        collectionView.delegate = nil
        
//        counterViewHolder.layer.cornerRadius = 4
        
        gameDataOriginal = getRandomAssets()
        
        gameData = gameDataOriginal.map{$0.copy()} // make copy from original array so when we reset, it will be from fresh again
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        startTimer()
    }
    
    override func btnBackClicked(){
        // Prepare the popup
        let title = "".localized()
        let message = "Are you sure you want to quit the game?".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            self.clearTimer()
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            }
        }
        let buttonTwo = DefaultButton(title: "CANCEL".localized()) {
            
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
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    // MARK: - Timer
    
    func startTimer(){
        clearTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    func clearTimer(){
        if let tm = timer {
            tm.invalidate()
        }
        timer = nil
    }
    
    @objc func updateTimer(timer:Timer){
        bestTimeRecordInSeconds = bestTimeRecordInSeconds + 1
    }
    
    // MARK: - View
    
    func setUpCollectionViews(){
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        if Device.size() < .screen4_7Inch {
            layout.itemSize = CGSize(width: 60, height: 60)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 11

            bannerTopConstraint.constant = bannerTopConstraint.constant + bannerTopConstraint.constant + bannerTopConstraint.constant/3
            
            collectionViewWidthConstraint.constant = 280
        } else if Device.size() >= .screen7_9Inch {
            layout.itemSize = CGSize(width: 100, height: 100)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 11
            collectionViewWidthConstraint.constant = 500
        } else {
            layout.itemSize = CGSize(width: 72, height: 72)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 11

        }
        
        collectionView.collectionViewLayout = layout
        collectionView.layoutIfNeeded()
        
    }

    
    // MARK: - Game Logic
    
    func getRandomAssets() -> [PairGameObj]{
        
        let fruits = [
            PairGameObj(type: .apple),
            PairGameObj(type: .banana),
            PairGameObj(type: .berry),
            PairGameObj(type: .fruit),
            PairGameObj(type: .grape),
            PairGameObj(type: .greenlime),
            PairGameObj(type: .lime),
            PairGameObj(type: .mango),
            PairGameObj(type: .orange),
            PairGameObj(type: .pear),
            PairGameObj(type: .pineapple),
            PairGameObj(type: .raspberry),
            PairGameObj(type: .strawberry),
            PairGameObj(type: .watermalon)]
        
        let outdoor = [
            PairGameObj(type: .clouds),
            PairGameObj(type: .dan),
            PairGameObj(type: .fire),
            PairGameObj(type: .fish),
            PairGameObj(type: .merryround),
            PairGameObj(type: .rainbow),
            PairGameObj(type: .rocker),
            PairGameObj(type: .rose),
            PairGameObj(type: .round),
            PairGameObj(type: .seesaw),
            PairGameObj(type: .shaw),
            PairGameObj(type: .sun),
            PairGameObj(type: .tank),
            PairGameObj(type: .trees)
        ]
        
        let sports = [
            PairGameObj(type: .americanfootball),
            PairGameObj(type: .ball),
            PairGameObj(type: .baseball),
            PairGameObj(type: .basketball),
            PairGameObj(type: .beachball),
            PairGameObj(type: .bedminton),
            PairGameObj(type: .redBike),
            PairGameObj(type: .bowling),
            PairGameObj(type: .pingpong),
            PairGameObj(type: .skate),
            PairGameObj(type: .snookling),
            PairGameObj(type: .tennis),
            PairGameObj(type: .volleyball),
            PairGameObj(type: .yatch)
        ]
        
        var randomArray:[PairGameObj] = [PairGameObj]()
        
        let randomCategory = Int(arc4random_uniform(3))
        switch randomCategory {
        case 0:
            randomArray = fruits
        case 1:
            randomArray = outdoor
        default:
            randomArray = sports
        }
        
        // shuffle array
        randomArray.shuffle()

        // slice into only 7 objects
        var finalArray:[PairGameObj] = [PairGameObj]()
        for obj in randomArray[0...6] {
            finalArray.append(obj)
        }
        
        // inject Plano image
        finalArray.append(PairGameObj(type: .plano))

        // shuffle finalArray
        finalArray.shuffle()
        
        // double the objects so
        finalArray.append(contentsOf: finalArray)
        
        // shuffle doubled array
        finalArray.shuffle()
        finalArray.shuffle()
        
        return finalArray
    }
    
    @objc func gameIsRevealed(gameObj:PairGameObj){
        
        /**
         * 1st time revealing
         * ------------------
         * just reveal the image
         *
         * 2nd time revealing
         * ------------------
         * compare with 1st obj
         ** both plano? => game complete
         ** same? => keep both open
         ** not same? => close both, decrease counter
         *
         **/
        if(firstRevealedItem == nil){ // 1st time revealing
            
            firstRevealedItem = gameObj
            
            isGameAnimating = false

            
        }else if(secondRevealedItem == nil){ // 2nd time revealing
            
            secondRevealedItem = gameObj
            
            if let one = firstRevealedItem, let two = secondRevealedItem {
                
                if one.objType == two.objType { // keep both image open
                    
                    perform(#selector(checkGameCounter), with: nil, afterDelay: 0.6)
                    
                }else{ // no same image, deduct point
                    
                    perform(#selector(closeGameImages), with: nil, afterDelay: 0.6)

                    perform(#selector(checkGameCounter), with: nil, afterDelay: 0.6)

                }
                
            }
            
        }
        
    }
    
    
    @objc func checkGameCounter(){
        
        // if all pairs are matched, win
        // else gameCounter hits 0 {
        //      and not all pairs are matched, gameover
        // }
        
        var totalRevealedObjects = 0
        for obj in gameData {
            if obj.revealed {
                totalRevealedObjects += 1
            }
        }
        
        // check if all pairs are matched or not
        if totalRevealedObjects == gameData.count {
            
            clearTimer()
            
            showBestTimePopup(bestTimeRecordInSeconds)
            
        }else{
            
            // ok to continue
            // clear the existing tags
            firstRevealedItem = nil
            secondRevealedItem = nil
            isGameAnimating = false
            
        }
    }

    func showBestTimePopup(_ seconds:Float){
        
        let minute = (seconds/60) / 0.60
        let gameTime = String(format: "%.2f", minute)
        var seperateGameTime = gameTime.components(separatedBy: ".")
        viewModel.getGameBestTime(gameTime: seperateGameTime[0] + ":" + seperateGameTime[1]) {[weak self] (success, message) in
            if var msg = message {
                if success {
                    self?.showAlert(msg) {
                        self?.showWinningPopup()
                    }
                }else{
                    self?.showAlert(msg)
                }
            }
        }
    }
    
    func showWinningPopup(animated: Bool = true) {
        
        // Create a custom view controller
        if let vc = UIStoryboard.PopupWonGame() as? PopupWonGameVC {
            vc.parentVC = self
            
            // Create the dialog
            let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .bounceUp, tapGestureDismissal: true)
            
            // Present dialog
            present(popup, animated: animated, completion: nil)
        }
    }
    
    func showLosingPopup(animated: Bool = true) {
        
        // Create a custom view controller
        if let vc = UIStoryboard.PopupLuckyNextTime() as? LuckyNextTimeVC {
            vc.parentVC = self
            
            // Create the dialog
            let popup = PopupDialog(viewController: vc, buttonAlignment: .horizontal, transitionStyle: .bounceUp, tapGestureDismissal: true)
            
            // Present dialog
            present(popup, animated: animated, completion: nil)
        }
    }
    
    // popup callback
    func popupWonGameDone(){
        self.leaveGame(won:true)
    }
    
    // popup callback
    func popupLuckyNextTime(){
        self.leaveGame(won:false)
    }
    
    func leaveGame(won:Bool){
        if won {
            HUD.show(.systemActivity)
            
            let SecondsInString: String = String(format: "%.0f", bestTimeRecordInSeconds)
            
            viewModel.addPointForWinningGame(gameName: "Pairs", durationSeconds:SecondsInString, completed: {[weak self] (success) in
                HUD.hide()
                if let nav = self?.navigationController {
                    nav.popViewController(animated: true)
                }
            })
        }else{
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            }
        }
    }
    
    func decreaseGameCounter(){
        gameCounter = gameCounter - 1
    }
    
    @objc func closeGameImages(){
        if let one = firstRevealedItem {
            let index = gameData.index(of: one)
            if let i = index {
                let indexPath = IndexPath(item: i, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as! PairGameCell
                cell.closeCell(data: one)
            }
        }
        if let one = secondRevealedItem {
            let index = gameData.index(of: one)
            if let i = index {
                let indexPath = IndexPath(item: i, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as! PairGameCell
                cell.closeCell(data: one)
            }
        }
        firstRevealedItem = nil
        secondRevealedItem = nil
        isGameAnimating = false
    }
    
    func animateGameImages(){
        if let one = firstRevealedItem {
            let index = gameData.index(of: one)
            if let i = index {
                let indexPath = IndexPath(item: i, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as! PairGameCell
                cell.animateCell()
            }
        }
        if let one = secondRevealedItem {
            let index = gameData.index(of: one)
            if let i = index {
                let indexPath = IndexPath(item: i, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as! PairGameCell
                cell.animateCell()
            }
        }
    }
    
    func resetGame(){
        
        firstRevealedItem = nil
        secondRevealedItem = nil
        
        // reset data
        gameDataOriginal = getRandomAssets()
        gameData = gameDataOriginal.map{$0.copy()} // make copy from original array so when we reset,
        collectionView.reloadData()
        
        gameCounter = 8
        isGameAnimating = false

    }
    
    
}

extension PairGameVC : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PairGameCell.className, for: indexPath) as! PairGameCell
        
        let data = gameData[indexPath.row]
        cell.configCellWithData(data: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isGameAnimating {
            return // ignore
        }

        let cell = collectionView.cellForItem(at: indexPath) as! PairGameCell
        let data = gameData[indexPath.row]
        if data.revealed {
            // ignore
        }else{
            isGameAnimating = true
            cell.revealCell(data: data)
            perform(#selector(gameIsRevealed(gameObj:)), with: data, afterDelay: 0)
        }
    }
}

// MARK:
// MARK: -- PairGameType Class

enum PairGameType : String {
    
    case apple = "apple"
    case banana = "banana"
    case berry = "berry"
    case fruit = "fruit"
    case grape = "grape"
    case greenlime = "greenlime"
    case lime = "lime"
    case mango = "mango"
    case orange = "orange"
    case pear = "pear"
    case pineapple = "pineapple"
    case raspberry = "raspberry"
    case strawberry = "strawberry"
    case watermalon = "watermalon"
    
    case clouds = "clouds"
    case dan = "dan"
    case fire = "fire"
    case fish = "fish"
    case merryround = "merryround"
    case rainbow = "rainbow"
    case rocker = "rocker"
    case rose = "rose"
    case round = "round"
    case seesaw = "seesaw"
    case shaw = "shaw"
    case sun = "sun"
    case tank = "tank"
    case trees = "trees"
    
    case americanfootball = "americanfootball"
    case ball = "ball"
    case baseball = "baseball"
    case basketball = "basketball"
    case beachball = "beachball"
    case bedminton = "bedminton"
    case redBike = "redBike"
    case bowling = "bowling"
    case pingpong = "pingpong"
    case skate = "skate"
    case snookling = "snookling"
    case tennis = "tennis"
    case volleyball = "volleyball"
    case yatch = "yatch"
    
    case empty = "questionmark"
    case plano = "plano"
    
    func image() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}

// MARK:
// MARK: -- PairGameObj class

class PairGameObj : NSObject {
    var revealed = false
    var objType:PairGameType = .empty
    
    init(type:PairGameType){
        self.objType = type
    }
    
    func isPlano() -> Bool {
        return self.objType == .plano
    }
    
    func copy(with zone: NSZone? = nil) -> PairGameObj {
        let copy = PairGameObj(type: objType)
        return copy
    }
}
