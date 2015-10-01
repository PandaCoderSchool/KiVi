//
//  Global.swift
//  KiVi
//
//  Created by hoaqt on 10/1/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

struct Global {
    static let filters = [
        Filter(name: "Time", options: [
                Option(name: "Full-Time", value: 0),
            Option(name: "Part-time", value: 1)
        ],
            type: .DropDown),
        Filter(name: "Location", options: [
            Option(name: "Saigon", value: 0),
            Option(name: "Hanoi", value: 1),
            Option(name: "Da Nang", value: 2),
            Option(name: "Can Tho", value: 3),
            Option(name: "Hue", value: 4)
            ],
            type: .DropDown),
        Filter(name: "Job Categories", options: [
            Option(name: "Restaurant", value: 0),
            Option(name: "Technology", value: 1),
            Option(name: "Education", value: 2),
            Option(name: "NGO", value: 3)
            ],
            numberOfVisibleRows: 3,
            type: .MultipleSwitches
        )
    ]
}
