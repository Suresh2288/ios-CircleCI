//
//  ForgetPW.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper

class ForgetPW: NSObject, Mappable {
    
    var email = ""

    required init?(map: Map){
        
    }
    
    init(email: String) {
        
        self.email = email
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
    }
}
