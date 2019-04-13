//
//  EyeGameVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import PKHUD
import PopupDialog

class EyeGameVC : _BaseViewController {
    
    // MARK: - View Cycle
    
    @IBOutlet weak var v2Image: UIImageView!
    
    @IBOutlet weak var v1b1: RoundedButton!
    @IBOutlet weak var v1b2: RoundedButton!
    @IBOutlet weak var v1b3: RoundedButton!
    @IBOutlet weak var v1b4: RoundedButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var viewModel = ChildDashboardViewModel()
    
    var gameObjArray = [EyeGameObj]()
    var currentGameObj:EyeGameObj?
    var currentIndex = 0
    
    var correctAnswerArray:[Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBarWithAttributes(navtitle: "Eyexercise".localized(), setStatusBarStyle: .default, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16))
        
        if let nav = navigationController {
            nav.setNavigationBarHidden(false, animated: true)
        }
        
        initView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        WoopraTrackingPage().trackEvent(mainMode:"Child Game Play Page",pageName:"Game Play Page",actionTitle:"Playing Memory Game")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Device.size() <= .screen4Inch {
            bottomConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
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
        gameObjArray = getRandomAssets()
        currentGameObj = gameObjArray[0]
        currentIndex = 0
        if let cg = currentGameObj {
            renderGameObj(cg, 0)
        }

    }
    
    func answerQuestion(_ btnTitle:String, _ index:Int){
        
        if let cg = currentGameObj {
            
            if cg.objType.rawValue == btnTitle { // answer is correct
                showHideSuccess()
                
                // save into array
                correctAnswerArray.append(index)

            }else{
                showHideFailure()
            }
            
            perform(#selector(gotoNextQuestion), with: nil, afterDelay: 1)
        }
    }
    
    @objc func gotoNextQuestion(){
        currentIndex = currentIndex + 1
        
        // max reached
        if(currentIndex >= gameObjArray.count){
            
            if correctAnswerArray.count >= 4 { // if 4 out of 6 answer is correct, it's win
                showWinningPopup()
            }else{
                showLosingPopup()
            }
        
        }else{
            currentGameObj = gameObjArray[currentIndex]
            if let cg = currentGameObj {
                renderGameObj(cg, currentIndex)
            }
        }
    }
    
    func leaveGame(won:Bool){
        if won {
            HUD.show(.systemActivity)
            viewModel.addPointForWinningGame(gameName: "Eyexcerise", durationSeconds: ""
                , completed: {[weak self] (success) in
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
    
    func showHideSuccess(){
        HUD.show(.success)
        HUD.hide(afterDelay: 0.5)
    }
    
    func showHideFailure(){
        HUD.show(.error)
        HUD.hide(afterDelay: 0.5)
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
    
    // MARK: - Render Game
    func renderGameObj(_ obj:EyeGameObj, _ index:Int) {

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.v2Image.image = UIImage(named: obj.objType.rawValue)
            self.v2Image.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (c) in

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                self.v2Image.transform = CGAffineTransform.identity

            }, completion: { (c) in
                
            })
        }
        
        let randTitles = obj.getRandomTitles()
        
        v1b1.setTitle(randTitles[0].localized(), for: .normal)
        v1b2.setTitle(randTitles[1].localized(), for: .normal)
        v1b3.setTitle(randTitles[2].localized(), for: .normal)
        v1b4.setTitle(randTitles[3].localized(), for: .normal)
        
        v1b1.tag = index
        v1b2.tag = index
        v1b3.tag = index
        v1b4.tag = index
    }
    
    func getRandomAssets() -> [EyeGameObj]{
        
        var questions = [
            EyeGameObj(type: .Bicycle,          EyeGameType.Bicycle.rawValue,   "Glasses",      "Car",      "Zebra"),
            EyeGameObj(type: .Bird,             EyeGameType.Bird.rawValue,      "Ship",         "Bee",      "House"),
            EyeGameObj(type: .Dog,              EyeGameType.Dog.rawValue,       "Teddy Bear",   "Lion",     "Rug"),
            EyeGameObj(type: .Car,              EyeGameType.Car.rawValue,       "Space Ship",   "Shark",    "Robot"),
            EyeGameObj(type: .Dinosaur,         EyeGameType.Dinosaur.rawValue,  "Beach",        "Orange",   "Tree"),
            EyeGameObj(type: .Skateboard,       EyeGameType.Skateboard.rawValue,"Ski",          "SurKoard", "Banana"),
            EyeGameObj(type: .Sunglasses,       EyeGameType.Sunglasses.rawValue,"Frisbee",      "Potato",   "Sun"),
            EyeGameObj(type: .Elephant,         EyeGameType.Elephant.rawValue,  "Mountain",     "Truck",    "Fountain"),
            EyeGameObj(type: .Astronaut,        EyeGameType.Astronaut.rawValue, "Robot",        "Diver",    "Boat"),
            EyeGameObj(type: .Football,         EyeGameType.Football.rawValue,  "Flag",         "Wheel",    "Snail"),
            EyeGameObj(type: .Butterfly,        EyeGameType.Butterfly.rawValue, "Coral",        "Ice cream","Umbrella"),
            EyeGameObj(type: .Goldfish,         EyeGameType.Goldfish.rawValue,  "Crab",         "Lobster",  "Orange"),
            EyeGameObj(type: .Basketball,       EyeGameType.Basketball.rawValue,"Sun",          "Planet",   "Trophy"),
            EyeGameObj(type: .Guitar,           EyeGameType.Guitar.rawValue,    "Seahorse",     "Dragon",   "Fire"),
            EyeGameObj(type: .Leopard,          EyeGameType.Leopard.rawValue,   "Panther",      "Pumpkin",  "Coral"),
            EyeGameObj(type: .Horse,            EyeGameType.Horse.rawValue,     "Viking",       "Bear",     "Fence"),
            EyeGameObj(type: .Kite,             EyeGameType.Kite.rawValue,      "Rainbow",      "Plane",    "Balloon"),
            EyeGameObj(type: .Shark,            EyeGameType.Shark.rawValue,     "Dolphin",      "Plane",    "Submarine"),
            
            EyeGameObj(type: .Beach,            EyeGameType.Beach.rawValue,         "Mountain",     "Coral",        "Dolphin"),
            EyeGameObj(type: .Beachball,        EyeGameType.Beachball.rawValue,     "Rattle",       "Sailboat",     "Basketball"),
            EyeGameObj(type: .Bee,              EyeGameType.Bee.rawValue,           "Eye",          "Kiwi Fruit",   "Sponge"),
            EyeGameObj(type: .Bridge,           EyeGameType.Bridge.rawValue,        "Playground",   "Skipping rope","Water slide"),
            EyeGameObj(type: .Canoe,            EyeGameType.Canoe.rawValue,         "Shoes",        "Gloves",       "Fish"),
            EyeGameObj(type: .Carrots,          EyeGameType.Carrots.rawValue,       "Crab",         "Lobster",      "Gloves"),
            EyeGameObj(type: .Chilli,           EyeGameType.Chilli.rawValue,        "Goldfish",     "Leaves",       "Painting"),
            EyeGameObj(type: .Coconut,          EyeGameType.Coconut.rawValue,       "Glasses",      "Tyres",        "Cups"),
            EyeGameObj(type: .Flower,           EyeGameType.Flower.rawValue,        "Starfish",     "Astronaut",    "Monkey"),
            EyeGameObj(type: .Fountain,         EyeGameType.Fountain.rawValue,      "Sword",        "Waterfall",    "Statue"),
            EyeGameObj(type: .Giraffe,          EyeGameType.Giraffe.rawValue,       "Horse",        "Elephant",     "Spider"),
            EyeGameObj(type: .Park,             EyeGameType.Park.rawValue,          "Traffic light","Golf course",  "Lightning"),
            EyeGameObj(type: .Piano,            EyeGameType.Piano.rawValue,         "Road",         "Motorcycle",   "Kettle"),
            EyeGameObj(type: .Rollercoaster,    EyeGameType.Rollercoaster.rawValue, "Worm",         "Hot dog",      "Slide"),
            EyeGameObj(type: .Skis,             EyeGameType.Skis.rawValue,          "Skyscrapers",  "Penguins",     "Rocket"),
            EyeGameObj(type: .Tennisracquet,    EyeGameType.Tennisracquet.rawValue, "Egg",          "Fry pan",      "Hammer"),
            EyeGameObj(type: .Tomatoes,         EyeGameType.Tomatoes.rawValue,      "Grapes",       "Light globe",  "Basketballs"),
            EyeGameObj(type: .Umbrella,         EyeGameType.Umbrella.rawValue,      "House",        "Surfboard",    "Flag")
        ]
        
        // shuffle array multiple times
        questions.shuffle()
        questions.shuffle()
        questions.shuffle()

        var arr:[EyeGameObj] = [EyeGameObj]()
        arr.append(questions[0])
        arr.append(questions[1])
        arr.append(questions[2])
        arr.append(questions[3])
        arr.append(questions[4])
        arr.append(questions[5])

        return arr
    }

    // MARK: - Buttons
    
    @IBAction func v1b1Clicked(_ sender: UIButton) {
        answerQuestion(sender.titleLabel!.text!.localized(), sender.tag)
    }
    
    @IBAction func v1b2Clicked(_ sender: UIButton) {
        answerQuestion(sender.titleLabel!.text!.localized(), sender.tag)
    }
    
    @IBAction func v1b3Clicked(_ sender: UIButton) {
        answerQuestion(sender.titleLabel!.text!.localized(), sender.tag)
    }
    
    @IBAction func v1b4Clicked(_ sender: UIButton) {
        answerQuestion(sender.titleLabel!.text!.localized(), sender.tag)
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
    
}

enum EyeGameType : String {
    
    case Bicycle = "Bicycle"
    case Bird = "Bird"
    case Dog = "Dog"
    case Car = "Car"
    case Dinosaur = "Dinosaur"
    case Skateboard = "Skateboard"
    case Sunglasses = "Sunglasses"
    case Elephant = "Elephant"
    case Astronaut = "Astronaut"
    case Football = "Football"
    case Butterfly = "Butterfly"
    case Goldfish = "Goldfish"
    case Basketball = "Basketball"
    case Guitar = "Guitar"
    case Leopard = "Leopard"
    case Horse = "Horse"
    case Kite = "Kite"
    case Shark = "Shark"
    
    case Beach = "Beach"
    case Beachball = "Beachball"
    case Bee = "Bee"
    case Bridge = "Bridge"
    case Canoe = "Canoe"
    case Carrots = "Carrots"
    case Chilli = "Chilli"
    case Coconut = "Coconut"
    case Flower = "Flower"
    case Fountain = "Fountain"
    case Giraffe = "Giraffe"
    case Park = "Park"
    case Piano = "Piano"
    case Rollercoaster = "Rollercoaster"
    case Skis = "Skis"
    case Tennisracquet = "Tennisracquet"
    case Tomatoes = "Tomatoes"
    case Umbrella = "Umbrella"
    
    case empty = ""
    
    func image() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}

struct EyeGameObj {
    
    var objType:EyeGameType = .empty
    var correctAnswer = ""
    var answer1 = ""
    var answer2 = ""
    var answer3 = ""

    init(type:EyeGameType, _ correctAns:String, _ ans1:String, _ ans2:String, _ ans3:String){
        self.objType = type
        correctAnswer = correctAns
        answer1 = ans1
        answer2 = ans2
        answer3 = ans3
    }
    
    func getRandomTitles() -> [String]{
        var arr = [
            correctAnswer, answer1, answer2, answer3
        ]
        arr.shuffle()
        return arr
    }
}
