//
//  LanguageManager.swift
//  Plano
//
//  Created by Paing on 2/3/18.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import AlamofireObjectMapper
import Localize_Swift

class LanguageManager {
    
    static let sharedInstance = LanguageManager()
    
    enum LanguageNames:String {
        case chinese = "zh-Hans"
        case japanese = "ja"
        case korean = "ko"
        case english = "en"
        
        static func getDefault() -> String {
            return self.english.rawValue
        }
        
        static func getByIndex(languageID:String) -> LanguageNames {
            switch languageID {
            case "1":
                return LanguageNames.chinese
            case "2":
                return LanguageNames.japanese
            case "3":
                return LanguageNames.korean
            default:
                return LanguageNames.english
            }
        }
    }
    
    enum LanguageIndex:String {
        case chinese = "1"
        case japanese = "2"
        case korean = "3"
        case english = "4" // default language
        
        static func getDefault() -> LanguageIndex {
            return self.english
        }
    }
    
    func resetLanguageToDefault(){
        
        // update in NSUserDefault
        Defaults[.languageID] = LanguageIndex.getDefault().rawValue // 1=Chinese,2=Japanese,3=Korean,4=English(Default)

        // UI: switch to default language
        Localize.setCurrentLanguage(LanguageNames.getDefault())

        // manually set this so that, Storyboard will be updated upon app restart
        UserDefaults.standard.set([LanguageNames.getDefault()], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func getDefaultLanguageName() -> String {
        return LanguageNames.getDefault()
    }
    
    
    func setCurrentLanguage(_ language:LanguageIndex) {
        
        // store in NSUserDefault
        // store it in NSDefault
        Defaults[.languageID] = language.rawValue
        
        // UI: update to new language
        let langName = LanguageNames.getByIndex(languageID: language.rawValue)
        Localize.setCurrentLanguage(langName.rawValue)
        
        // manually set this so that, Storyboard will be updated upon app restart
        UserDefaults.standard.set([LanguageManager.sharedInstance.getSelectedLanguageName()], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func selectedLanguageID() -> LanguageIndex {
        
        if let langID = LanguageIndex(rawValue: self.getSelectedLanguageID()) {
            return langID
        }
        
        return LanguageIndex.getDefault()
    }
    
    func getSelectedLanguageID() -> String {
        
        // if first time, it will be empty so put a default value
        if Defaults[.languageID].isEmpty {
            
            // get default value
            let languageID = LanguageIndex.getDefault().rawValue
            
            // store in NSDefault
            Defaults[.languageID] = languageID
            
            return languageID // "4"
            
        }else{
            
            return Defaults[.languageID] // "4"
        }
    }
    
    
    func getSelectedLanguageName() -> String {

        let languageID:String = self.getSelectedLanguageID()

        return LanguageNames.getByIndex(languageID: languageID).rawValue // "en"
    }
}
