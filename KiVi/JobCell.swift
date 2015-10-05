//
//  JobCell.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/21/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit

class JobCell: UITableViewCell {
  
  @IBOutlet weak var jobImage: UIImageView!
  @IBOutlet weak var jobTitle: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var dueSubmitDateLabel: UILabel!
  @IBOutlet weak var salaryLabel: UILabel!
  @IBOutlet weak var jobType: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
