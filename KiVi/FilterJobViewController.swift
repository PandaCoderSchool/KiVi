//
//  FilterJobViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/28/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class FilterJobViewController: UIViewController {
  
  @IBOutlet weak var filterView: UIView!
  
  @IBOutlet weak var workAtPickerTextField: UITextField!
  @IBOutlet weak var jobTypePickerTextField: UITextField!
  @IBOutlet weak var sectorPickerTextField: UITextField!
  
  let workAtList = ["-- Chose a region --", "Ho Chi Minh", "Da Nang", "Ha Noi", "Binh Duong", "Vung Tau", "Can Tho", "Phan Thiet"]
  let workAtPickerView = UIPickerView()
  
  let jobTypeList = ["-- Chose a job type --", "Part Time Jobs", "Summer/Holiday Jobs", "Temporary Jobs", "Internships", "Full Time Jobs"]
  let jobTypePickerView = UIPickerView()
  
  let sectorList = ["-- Chose a job sector --","Admin", "Advertising/Marketing/PR", "Agriculture", "Art/Music","Catering/Leisure", "Childcare/Care Work","Customer Service/Call Center", "Defense/Security","Education", "Engineering", "IT",  "Manufacturing/Industrial", "Promotion/Events","Real Estate","Retail", "Sales", "Travel/Tourism" ]
  let sectorPickerView = UIPickerView()
  
  let jobObj = PFObject(className: ParseInterface.sharedInstance.databaseClassName)

  var filterCriteria: [String] = ["NA","NA","NA"]
  
  var hud = MBProgressHUD()

  var searchResult : [PFObject]? = [PFObject]()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initViewController()
    
    
  }
  
  func initViewController() {
    
    // Location Picker for Work At
    workAtPickerView.delegate = self
    workAtPickerView.dataSource = self
    workAtPickerView.showsSelectionIndicator = true
    workAtPickerView.backgroundColor = UIColor.whiteColor()
    workAtPickerTextField.inputView = workAtPickerView
    
    jobTypePickerView.delegate = self
    jobTypePickerView.dataSource = self
    jobTypePickerView.backgroundColor = UIColor.whiteColor()
//    jobTypePickerView.selectedRowInComponent(1)
    jobTypePickerTextField.inputView = jobTypePickerView
    
    sectorPickerView.delegate = self
    sectorPickerView.dataSource = self
  
    sectorPickerView.backgroundColor = UIColor.whiteColor()
//    sectorPickerView.selectedRowInComponent(1)
    sectorPickerTextField.inputView = sectorPickerView
    
    
  }

  override func viewDidAppear(animated: Bool) {
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func workAtPickerChanged(sender: UITextField) {
    if sender.text != nil {
      filterCriteria[0] = sender.text!
    } else {
      filterCriteria[0]  = "NA"
    }
  }
  
  @IBAction func jobTypePickerChanged(sender: UITextField) {
    if sender.text != nil {
      filterCriteria[1] = sender.text!
    } else {
      filterCriteria[1]  = "NA"
    }  }
  
  @IBAction func sectorPickerChanged(sender: UITextField) {
    if sender.text != nil {
      filterCriteria[2] = sender.text!
    } else {
      filterCriteria[2]  = "NA"
    }
  }
  
  @IBAction func onSearchButton(sender: UIButton) {
    print("Searching...")
    let searchQuery = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQuery.whereKey("workAt", matchesRegex: "(?i)\(filterCriteria[0])")
    
    let searchQuerySecond = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQuerySecond.whereKey("jobType", matchesRegex: "(?i)\(filterCriteria[1])")
    
    let searchQueryThird = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQueryThird.whereKey("jobSector", matchesRegex: "(?i)\(filterCriteria[2])")
    
    let query = PFQuery.orQueryWithSubqueries([searchQuery, searchQuerySecond, searchQueryThird])
    query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
      if error != nil {
        let errorAlert = UIAlertController(title: "Search Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        errorAlert.addAction(okAction)
        self.presentViewController(errorAlert, animated: true, completion: nil)
        return
      }
      if let objects = results {
        self.searchResult?.removeAll(keepCapacity: false)
        self.searchResult = objects
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          
          
          if self.searchResult?.count == 0 {
            let errorAlert = UIAlertController(title: "Search Alert", message: "No jobs found", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            errorAlert.addAction(okAction)
            self.presentViewController(errorAlert, animated: true, completion: nil)
          } else {
            print("Post Notification with result = \(self.searchResult!.count)")
            NSNotificationCenter.defaultCenter().postNotificationName("searchResultUpdated", object: nil, userInfo: ["result" : self.searchResult!])
            jobIsUpdated = -1
          }
          
        }) // dispatch_async - End
      }
      
    }
    

  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
    
  }
  
  func textFieldShouldReturn (textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
    
  }
  
} // FilterJobViewController - End

extension FilterJobViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == workAtPickerView {
      return workAtList.count
    } else if pickerView == jobTypePickerView {
      return jobTypeList.count
    } else if pickerView == sectorPickerView {
      return sectorList.count
    }else {
      return 0
    }
  }
  
  
  
  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var attributedString: NSAttributedString!
    
    
    if pickerView == workAtPickerView {
      attributedString = NSAttributedString(string: workAtList[row], attributes: [NSForegroundColorAttributeName : UIColor.blueColor()])
    } else if pickerView == jobTypePickerView {
      attributedString = NSAttributedString(string: jobTypeList[row], attributes: [NSForegroundColorAttributeName : UIColor.blueColor()])
    } else if pickerView == sectorPickerView {
      attributedString = NSAttributedString(string: sectorList[row], attributes: [NSForegroundColorAttributeName : UIColor.blueColor()])
    }else {
      attributedString = nil
    }
    return attributedString
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == workAtPickerView {
      workAtPickerTextField.text = workAtList[row]
      
    } else if pickerView == jobTypePickerView  {
      jobTypePickerTextField.text = jobTypeList[row]
      
    } else if pickerView == sectorPickerView  {
      sectorPickerTextField.text = sectorList[row]
      
    }
  }
} // Picker externsion - End

