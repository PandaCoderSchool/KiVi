//
//  JobMapAnnotationView.swift
//  KiVi
//
//  Created by admin on 01/10/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class JobMapAnnotationView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var jobName: UILabel!
    @IBOutlet weak var jobType: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var income: UILabel!
    
    @IBAction func viewDetail(sender: UIButton) {
        
    }

}
