//
//  UIStoryboard.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import Device

public extension UIStoryboard {
    
    enum StoryBoard: String {
        case OnBoard = "OnBoard"
        case Auth = "Auth"
        case Menu = "Menu"
        case Quiz = "Quiz"
        case LinkedAccounts = "LinkedAccounts"
        case LinkedAccountsiPad = "LinkedAccountsiPad"
       // case AddChild = "AddChild"
       // case AddChildiPad = "AddChildiPad"
        case ChildMode = "ChildMode"
        case ChildDashboard = "ChildDashboard"
        case Wallet = "Wallet"
        case WalletiPad = "WalletiPad"
        case ParentDashboard = "ParentDashboard"
       // case ParentDashboardiPad = "ParentDashboardiPad"
        case MyopiaProgress = "MyopiaProgress"
        case Popup = "Popup"
        case PopupiPad = "PopupiPad"
        
        func instance(_ vc:String) -> UIViewController {
            return UIStoryboard(name: self.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: vc)
        }
    }

    class func AuthNav() -> UINavigationController {
        return StoryBoard.Auth.instance("AuthNav") as! UINavigationController
    }
    
    class func TermNav() -> UINavigationController {
        return StoryBoard.Auth.instance("TermsNav") as! UINavigationController
    }

    class func AddChildNav() -> UINavigationController {
        return StoryBoard.ChildDashboard.instance("AddChild") as! UINavigationController
    }

    class func ParentDashboardNav() -> UINavigationController {
        return StoryBoard.ParentDashboard.instance("ParentDashboardNav") as! UINavigationController
    }
    
    class func WalletNav() -> UINavigationController {
        return StoryBoard.Wallet.instance("WalletNav") as! UINavigationController
    }
    
    class func Wallet() -> UIViewController {
        return StoryBoard.Wallet.instance("ParentWalletVC") as! ParentWalletVC
    }
    
    class func ChildShopNav() -> UINavigationController {
        return StoryBoard.Wallet.instance("ChildShopNav") as! UINavigationController
    }
    
    // Please edit here for MyopiaProgress
    class func MyopiaProgressNav() -> UINavigationController {
        //return StoryBoard.AddChild.instance("MyopiaProgress") as! UINavigationController
        return StoryBoard.ParentDashboard.instance("MyopiaProgress") as! UINavigationController
    }

    class func MenuNavi() -> UINavigationController {
        return StoryBoard.Menu.instance("MenuNav") as! UINavigationController
    }
    
    class func FAQNav() -> UINavigationController{
        return StoryBoard.Menu.instance("FAQNav") as! UINavigationController
    }
    
    class func AboutNav() -> UINavigationController{
        return StoryBoard.Menu.instance("AboutNav") as! UINavigationController
    }
    
    class func FeedbackNav() -> UINavigationController{
        return StoryBoard.Menu.instance("FeedBackNav") as! UINavigationController
    }
    
    class func PremiumNav() -> UINavigationController{
        return StoryBoard.Menu.instance("PremiumNav") as! UINavigationController
    }
    
    class func Premium() -> UIViewController {
        return StoryBoard.Menu.instance(PremiumVC.className)
    }
    
    class func PaymentVC() -> UIViewController {
        return StoryBoard.Wallet.instance(PaymentPageVC.className)
    }
    
    class func AlertSettingsNav() -> UINavigationController{
        return StoryBoard.Menu.instance("AlertSettingsNav") as! UINavigationController
    }
    
    class func MyOderListVCNav() -> UINavigationController{
        return StoryBoard.Menu.instance("MyOderListVCNav") as! UINavigationController
    }
    
    class func ParentAccountNav() -> UINavigationController{
        return StoryBoard.Menu.instance("ParentAccountNav") as! UINavigationController
    }
    class func QuizNav() -> UINavigationController{
        return StoryBoard.Quiz.instance("QuizNav") as! UINavigationController
    }
    
    class func LinkedAccountsNav() -> UINavigationController{
        if Device.size() >= .screen7_9Inch {
            return StoryBoard.LinkedAccountsiPad.instance("LinkedAccountsNav") as! UINavigationController
        }else{
            return StoryBoard.LinkedAccounts.instance("LinkedAccountsNav") as! UINavigationController
        }
    }
    
    class func LinkedAccounts() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(LinkedAccountsVC.className)
    }
    
    class func NotificationsNav() -> UINavigationController{
        return StoryBoard.Menu.instance("NotificationsNav") as! UINavigationController
    }
    
    class func ChildDashboardNav() -> UINavigationController{
        return StoryBoard.ChildDashboard.instance("ChildDashboardNav") as! UINavigationController
    }
    
    class func PopupMapViewNav() -> UINavigationController{
        return StoryBoard.Popup.instance("ChildrenLocationNav") as! UINavigationController
    }
    
    class func PopupMapViewNaviPad() -> UINavigationController{
        return StoryBoard.PopupiPad.instance("ChildrenLocationNav") as! UINavigationController
    }
    
    class func UpdateProfileNav() -> UINavigationController{
        return StoryBoard.Menu.instance("UpdateProiffleNav") as! UINavigationController
    }
    
    class func Guardians() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(GuardiansVC.className)
    }
    
    class func PendingRequests() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(PendingRequestsVC.className)
    }
    
    class func Parents() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(ParentsVC.className)
    }
    
    class func Requests() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(RequestsVC.className)
    }
    
    class func AddSchedulePeriodPopUp() -> UIViewController{
        return StoryBoard.Popup.instance(PopAddSchedulePeriodVC.className)
    }
    
    class func AddSchedulePeriodPopUpiPad() -> UIViewController{
        return StoryBoard.PopupiPad.instance(PopAddSchedulePeriodVC.className)
    }
    
    class func AgeRatingPopupView() -> UIViewController{
        return StoryBoard.Popup.instance(AgeRatingPopup.className)
    }
    
    class func AgeRatingPopupViewiPad() -> UIViewController{
        return StoryBoard.PopupiPad.instance(AgeRatingPopup.className)
    }
    
    class func AddLocationBoundariesPopUp() -> UIViewController{
        return StoryBoard.Popup.instance(ChildrenLocationVC.className)
    }

    class func AddLocationBoundariesPopUpiPad() -> UIViewController{
        return StoryBoard.PopupiPad.instance(ChildrenLocationVC.className)
    }
    
    class func OnBoard() -> UIViewController {
        return StoryBoard.OnBoard.instance(OnBoardVC.className)
    }
    class func TakeATour() -> UIViewController {
        return StoryBoard.OnBoard.instance(TourVC.className)
    }
    
    class func AuthLanding() -> UIViewController {
        return StoryBoard.Auth.instance(AuthLandingVC.className)
    }
    
    class func SignIn() -> UIViewController {
        return StoryBoard.Auth.instance(SignInVC.className)
    }
    
    class func SignUp() -> UIViewController {
        return StoryBoard.Auth.instance(SignUpVC.className)
    }
    
    class func LinkWithFacebook() -> UIViewController {
        return StoryBoard.Auth.instance(LinkWithFacebookVC.className)
    }
    
    class func CreateProfile() -> UIViewController {
        return StoryBoard.Auth.instance(CreateProfileVC.className)
    }
    
    class func ForgotPassword() -> UIViewController {
        return StoryBoard.Auth.instance(ForgotPasswordVC.className)
    }
    
    class func ResetPassword() -> UIViewController {
        return StoryBoard.Auth.instance(ResetPasswordVC.className)
    }
    
    class func UserTerms() -> UIViewController {
        return StoryBoard.Auth.instance(UserTermsVC.className)
    }
    
    class func CountryCityList() -> UIViewController {
        return StoryBoard.Auth.instance(CountryCityListVC.className)
    }
    
    class func AddChild() -> UIViewController {
        if Device.size() >= .screen7_9Inch {
            return StoryBoard.ChildDashboard.instance(AddChildVCiPad.className)
        }else{
            return StoryBoard.ChildDashboard.instance(AddChildVC.className)
        }
    }
 
    class func ChildProgress() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(ChildProgressVC.className)
    }
    
    class func ChildProgressiPad() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(ChildProgressVCiPad.className)
    }
    
    class func CustomiseSettings() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(CustomiseSettingsVC.className)
    }
    
    class func WalletDetail() ->UIViewController {
        return StoryBoard.Wallet.instance(ParentWalletDetailVC.className)
    }
    
    class func WalletDetailiPad() ->UIViewController {
        return StoryBoard.WalletiPad.instance(ParentWalletDetailVC.className)
    }
    
    class func ChildShop() -> UIViewController {
        return StoryBoard.Wallet.instance(ChildShopVC.className)
    }
    
    class func ChildShopDetail() -> UIViewController {
        return StoryBoard.Wallet.instance(ChildShopDetailVC.className)
    }
    
    class func ChildShopDetailiPad() ->UIViewController {
        return StoryBoard.WalletiPad.instance(ChildShopDetailVC.className)
    }
    
    class func ChildShopRequestPrompt() ->UIViewController {
        return StoryBoard.Wallet.instance(ChildShopRequestPromptVC.className)
    }
    
    class func ChildShopRequestPromptiPad() ->UIViewController {
        return StoryBoard.WalletiPad.instance(ChildShopRequestPromptVC.className)
    }
    
    class func UsageProgress() -> UIViewController{
        return StoryBoard.ParentDashboard.instance(UsageProgressVC.className)
    }

    class func MyopiaProgress() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(MyopiaProgressVC.className)
    }
    
    class func ChildSettings() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(ChildSettingsVC.className)
    }
    
    class func ChildSettingsiPad() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(ChildSettingsVCiPad.className)
    }
    
    class func MenuVC() -> UIViewController {
        return StoryBoard.Menu.instance(MenuViewController.className)
    }
    
    class func AlertSettings() -> UIViewController {
        return StoryBoard.Menu.instance(AlertSettingsVC.className)
    }
    
    class func LanguageSetting() -> UIViewController {
        return StoryBoard.Menu.instance(LanguageSettingVC.className)
    }

    class func MyFamily() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(MyFamilyVC.className)
    }
    
    class func PairGame() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(PairGameVC.className)
    }
    
    class func EyeGame() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(EyeGameVC.className)
    }

    class func EyeCalibrationPopupShow() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(EyeCalibrationPopup.className)
    }

    class func EyeCalibration() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(EyeCalibrationVC.className)
    }

    class func PopupHoldDevice() -> UIViewController {
        return StoryBoard.Popup.instance(PopupHoldDeviceVC.className)
    }
    
    class func PopupIsTextClear() -> UIViewController {
        return StoryBoard.Popup.instance(PopupIsTextClearVC.className)
    }

    class func PopupRedTooClose() -> UIViewController {
        return StoryBoard.Popup.instance(PopupRedTooCloseVC.className)
    }
    
    class func PopupRedRememberToWear() -> UIViewController {
        return StoryBoard.Popup.instance(PopupRedRememberToWearVC.className)
    }
    
    class func PopupRedTimeToCheck() -> UIViewController {
        return StoryBoard.Popup.instance(PopupRedTimeToCheckVC.className)
    }
    
    class func PopupGamePlayed() -> UIViewController {
        return StoryBoard.Popup.instance(PopupGamePlayedVC.className)
    }
    
    class func CustomiseAvatar() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(CustomiseAvatarVC.className)
    }
    
    class func ParentRewards() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(ParentRewardsVC.className)
    }
    
    class func RewardsView() -> UIViewController {
        return StoryBoard.ParentDashboard.instance(RewardsViewVC.className)
    }
    
    /////
    
    class func PopupVCByName(_ name:String) -> UIViewController {
        return StoryBoard.Popup.instance(name)
    }
    
    class func SwitchToParentPopup() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(SwitchToParentVC.className)
    }
    
    class func PopupWonGame() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(PopupWonGameVC.className)
    }
    
    class func PopupLuckyNextTime() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(LuckyNextTimeVC.className)
    }

    class func EyeDegreeList() -> UIViewController {
        return StoryBoard.ChildDashboard.instance(EyeDegreeListVC.className)
    }
    
    class func Feedback() -> UIViewController { 
        return StoryBoard.Menu.instance(FeedbackVC.className)
    }
    
    class func MyChildContainer() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(MyChildContainerVC.className)
    }
    
    class func OtherChildsContainer() -> UIViewController {
        return StoryBoard.LinkedAccounts.instance(OtherChildContainerVC.className)
    }
    
    class func PopupToChoosePremiumPlan() -> UIViewController {
        return StoryBoard.Popup.instance(PremiumPlanPopup.className)
    }
}


