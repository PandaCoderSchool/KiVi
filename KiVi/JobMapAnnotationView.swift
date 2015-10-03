//
//  JobMapAnnotationView.swift
//  KiVi
//
//  Created by admin on 01/10/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

@IBDesignable class JobMapAnnotationView: UIView {
    @IBOutlet weak var jobName: UILabel!
    @IBOutlet weak var jobType: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var income: UILabel!
    
    @IBAction func viewDetail(sender: UIButton) {
        
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    // Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "JobMapAnnotationView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
}
