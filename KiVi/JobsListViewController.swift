//
//  JobsListViewController.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/21/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit

class JobsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var jobsTableView: UITableView!
  
  var timer: NSTimer = NSTimer()
  var jobsList: [PFObject]? = [PFObject]()
  
  var hud : MBProgressHUD = MBProgressHUD()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    jobsTableView.rowHeight = UITableViewAutomaticDimension
    
    jobsTableView.estimatedRowHeight = 160
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateTable:"), name: "searchResultUpdated", object: nil)
    
  }
  
  deinit{
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "fetchJobsInformation", userInfo: nil, repeats: true)
  }
  override func viewDidDisappear(animated: Bool) {
    timer.invalidate()
  }
  
  func updateTable(notification: NSNotification) {
    let userInfo:Dictionary<String,[PFObject]!> = notification.userInfo as! Dictionary<String,[PFObject]!>
    jobsList = userInfo["result"]
    if jobsList != nil {
      jobsTableView.reloadData()
      
    }
  }
  
  func fetchJobsInformation() {
    
    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    self.hud.mode = MBProgressHUDMode.Indeterminate
    self.hud.labelText = "Updating jobs"
    
    jobsList = ParseInterface.sharedInstance.getJobsInformation()
    
    if jobsList?.count >  0 {
      jobsTableView.reloadData()
      timer.invalidate()
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
  }
  
  // MARK: - TableView Delegate
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if jobsList != nil {
      return jobsList!.count
    } else {
      return 0
    }
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("JobCell", forIndexPath: indexPath) as! JobCell
    
    cell.jobTitle.text = jobsList![indexPath.row]["jobTitle"] as? String
    cell.companyLabel.text  = jobsList![indexPath.row]["employerName"] as? String
    cell.jobType.text  = jobsList![indexPath.row]["jobType"] as? String
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd'/'MM'/'yyyy"
    if let getDate = jobsList![indexPath.row]["dueDate"] as? NSDate {
      let date = dateFormatter.stringFromDate(getDate)
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
    
      thumbNail.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
        if (error == nil) {
          let image = UIImage(data:imageData!)
          //image object implementation
          cell.jobImage.image = image
        }
      }) // getDataInBackgroundWithBlock - end
    }
//
  
    return cell
  }
  
  
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "FilterSegue" {
//      print("Filter was pressed")
//    }  else if segue.identifier == "MapView" {
//      print("Map View was seletec")
//    }
    
    if sender is UIBarButtonItem {
      
      if sender?.tag == 0 {
        let navigationVC = segue.destinationViewController as! UINavigationController
        _ = navigationVC.topViewController as! FilterJobViewController
        
      } else if sender?.tag == 1 {
        _ = segue.destinationViewController as! MapViewController
        
      }
    } else {
      let detailsVC = segue.destinationViewController as! JobDetailsViewController
      let indexPath = jobsTableView.indexPathForCell(sender as! UITableViewCell)
      detailsVC.selectedJob = jobsList![indexPath!.row]
    }
    
  }
  
  
}
