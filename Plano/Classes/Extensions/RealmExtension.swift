//
//  RealmExtension.swift
//  Plano
//
//  Created by Thiha Aung on 6/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}
