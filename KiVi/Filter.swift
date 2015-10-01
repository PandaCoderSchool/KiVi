//
//  Filter.swift
//  KiVi
//
//  Created by hoaqt on 10/1/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class Filter: NSObject {
    var name: String
    var options: [Option]
    var numberOfVisibleRows: Int?
    var type: FilterType
    var isExpanded: Bool
    
    init(name: String, options: [Option], numberOfVisibleRows: Int? = nil, type: FilterType? = .SingleSwitch){
        self.name = name
        self.options = options
        self.numberOfVisibleRows = numberOfVisibleRows
        self.type = type!
        self.isExpanded = false
    }
    
    func resetToFalse(){
        for option in options {
            option.isEnabled = false
        }
    }
    
    var selectedOption: Option {
        get {
            for option in options {
                if option.isEnabled {
                    return option
                }
            }
            return options[0]
        }
    }
}

enum FilterType {
    case SingleSwitch, DropDown, MultipleSwitches
}
