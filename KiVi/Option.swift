//
//  Option.swift
//  KiVi
//
//  Created by hoaqt on 10/1/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class Option {
    
    var name: String
    var value: AnyObject
    var isEnabled: Bool
    init(name: String, value: AnyObject, isEnabled:Bool?=false){
        self.name = name
        self.value = value
        self.isEnabled = isEnabled!
    }
    

}
