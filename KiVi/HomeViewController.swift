//
//  HomeViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/27/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate {
  
  @IBOutlet weak var mapContainerView: UIView!
  @IBOutlet weak var listContainerView: UIView!
  
  var searchBar = UISearchBar()
  
  let mapView = "MapView"
  let listView = "ListView"
  var isMapViewSelected: Bool = false
  
  var searchResult : [PFObject]? = [PFObject]()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
    
    self.setupSearchBar()
    
    
    mapContainerView.hidden   = !isMapViewSelected
    listContainerView.hidden  = isMapViewSelected
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func setupSearchBar() {
    
    searchBar.placeholder = "Search location"
    self.navigationItem.titleView = self.searchBar
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    fetchNewJob(searchBar.text!)
    searchBar.resignFirstResponder()
    
  }
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

  
  func fetchNewJob(searchText: String) {
    print("Searching...")
    let searchQuery = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQuery.whereKey("employerAddress", matchesRegex: "(?i)\(searchText)")  // incasensitivity
//    searchQuery.whereKey("employerAddress", containsString: searchText)
    let searchQuerySecond = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQuerySecond.whereKey("workAt", matchesRegex: "(?i)\(searchText)")
    
    let query = PFQuery.orQueryWithSubqueries([searchQuery, searchQuerySecond])
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
            
          }
          
        }) // dispatch_async - End
      }
      
    }
    
  }
  
  

  
  @IBAction func onChangeViewType(sender: UIBarButtonItem) {
    isMapViewSelected = !isMapViewSelected
    
    if isMapViewSelected {
      sender.image = UIImage(named: listView)
      self.changeViewAnimate(listContainerView, toView: mapContainerView)
      
    } else {
      sender.image = UIImage(named: mapView)
      self.changeViewAnimate(mapContainerView, toView: listContainerView)
    }

  }
  
  
  /*
  
  -------------------------------------------
  map view hide here          |    view display screen  |       list view hide
  |                         |
  hidePosition:
  
  -fromView.frame.size.width  |           0             |      fromView.frame.size.width
  
  */
  
  func changeViewAnimate(fromView: UIView, toView: UIView) {
    toView.hidden = false
    
    let hidePosition = isMapViewSelected ? fromView.frame.size.width : -fromView.frame.size.width
    
    UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
      fromView.transform = CGAffineTransformMakeTranslation(hidePosition, 0)
      toView.transform = CGAffineTransformMakeTranslation(0, 0)
      fromView.alpha = 0
      toView.alpha = 1
      
      }) { (finished) -> Void in
        fromView.hidden = true
    }
    
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
  
    searchBar.resignFirstResponder()
  }
  
  
  
  
}
