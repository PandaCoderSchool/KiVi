//
//  JobsListViewController.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/21/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class JobsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var jobsTableView: UITableView!
  
  var timer: Timer = Timer()
  var jobsList: [PFObject]? = [PFObject]()
  
  var hud : MBProgressHUD = MBProgressHUD()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    jobsTableView.rowHeight = UITableViewAutomaticDimension
    
    jobsTableView.estimatedRowHeight = 160
    
    NotificationCenter.default.addObserver(self, selector: #selector(JobsListViewController.updateTable(_:)), name: NSNotification.Name(rawValue: "searchResultUpdated"), object: nil)
    
  }
  
  deinit{
    NotificationCenter.default.removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JobsListViewController.fetchJobsInformation), userInfo: nil, repeats: true)
  }
  override func viewDidDisappear(_ animated: Bool) {
    timer.invalidate()
  }
  
  func updateTable(_ notification: Notification) {
    let userInfo:Dictionary<String,[PFObject]?> = notification.userInfo as! Dictionary<String,[PFObject]?>
    jobsList = userInfo["result"]!
    if jobsList != nil {
      jobsTableView.reloadData()
      
    }
  }
  
  func fetchJobsInformation() {
    
    self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
    self.hud.mode = MBProgressHUDMode.indeterminate
    self.hud.labelText = "Updating jobs"
    
    jobsList = ParseInterface.sharedInstance.getJobsInformation()
    
    if jobsList?.count >  0 {
      jobsTableView.reloadData()
      timer.invalidate()
      MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
  }
  
  // MARK: - TableView Delegate
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if jobsList != nil {
      return jobsList!.count
    } else {
      return 0
    }
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
    
    cell.jobTitle.text = jobsList![indexPath.row]["jobTitle"] as? String
    cell.companyLabel.text  = jobsList![indexPath.row]["employerName"] as? String
    cell.jobType.text  = jobsList![indexPath.row]["jobType"] as? String
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd'/'MM'/'yyyy"
    if let getDate = jobsList![indexPath.row]["dueDate"] as? Date {
      let date = dateFormatter.string(from: getDate)
      if !date.isEmpty {
        cell.dueSubmitDateLabel.text = "Due: " + date
      } else {
        cell.dueSubmitDateLabel.text = "NA"
      }
    } else {
      cell.dueSubmitDateLabel.text = "NA"
    }    
    cell.salaryLabel.text = jobsList![indexPath.row]["salary"] as? String
    
    // MARK: Load image
    
    let object = jobsList![indexPath.row]
    
    if let thumbNail = object["profilePhoto"] as? PFFile {
    
      thumbNail.getDataInBackground(block: { (imageData: Data?, error: NSError?) -> Void in
        if (error == nil) {
          let image = UIImage(data:imageData!)
          //image object implementation
          cell.jobImage.image = image
        }
      } as! PFDataResultBlock) // getDataInBackgroundWithBlock - end
    }
//
  
    return cell
  }
  
  
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if segue.identifier == "FilterSegue" {
//      print("Filter was pressed")
//    }  else if segue.identifier == "MapView" {
//      print("Map View was seletec")
//    }
    
    if sender is UIBarButtonItem {
      
      if (sender as AnyObject).tag == 0 {
        let navigationVC = segue.destination as! UINavigationController
        _ = navigationVC.topViewController as! FilterJobViewController
        
      } else if (sender as AnyObject).tag == 1 {
        _ = segue.destination as! MapViewController
        
      }
    } else {
      let detailsVC = segue.destination as! JobDetailsViewController
      let indexPath = jobsTableView.indexPath(for: sender as! UITableViewCell)
      detailsVC.selectedJob = jobsList![indexPath!.row]
    }
    
  }
  
  
}
