//
//  HomeViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/27/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse

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
    
    
    mapContainerView.isHidden   = !isMapViewSelected
    listContainerView.isHidden  = isMapViewSelected
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func setupSearchBar() {
    
    searchBar.placeholder = "Search location"
    self.navigationItem.titleView = self.searchBar
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    fetchNewJob(searchBar.text!)
    searchBar.resignFirstResponder()
    
  }
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }

  
  func fetchNewJob(_ searchText: String) {
    print("Searching...")
    let searchQuery = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQuery.whereKey("employerAddress", matchesRegex: "(?i)\(searchText)")  // incasensitivity
//    searchQuery.whereKey("employerAddress", containsString: searchText)
    let searchQuerySecond = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    searchQuerySecond.whereKey("workAt", matchesRegex: "(?i)\(searchText)")
    
    let query = PFQuery.orQuery(withSubqueries: [searchQuery, searchQuerySecond])
    query.findObjectsInBackground { (results: [PFObject]?, error: NSError?) -> Void in
      if error != nil {
        let errorAlert = UIAlertController(title: "Search Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        errorAlert.addAction(okAction)
        self.present(errorAlert, animated: true, completion: nil)
        return
      }
      if let objects = results {
        self.searchResult?.removeAll(keepingCapacity: false)
        self.searchResult = objects
        
        DispatchQueue.main.async(execute: { () -> Void in
          
          
          if self.searchResult?.count == 0 {
            let errorAlert = UIAlertController(title: "Search Alert", message: "No jobs found", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            errorAlert.addAction(okAction)
            self.present(errorAlert, animated: true, completion: nil)
          } else {
            print("Post Notification with result = \(self.searchResult!.count)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "searchResultUpdated"), object: nil, userInfo: ["result" : self.searchResult!])
            
          }
          
        }) // dispatch_async - End
      }
      
    } as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void
    
  }
  
  

  
  @IBAction func onChangeViewType(_ sender: UIBarButtonItem) {
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
  
  func changeViewAnimate(_ fromView: UIView, toView: UIView) {
    toView.isHidden = false
    
    let hidePosition = isMapViewSelected ? fromView.frame.size.width : -fromView.frame.size.width
    
    UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
      fromView.transform = CGAffineTransform(translationX: hidePosition, y: 0)
      toView.transform = CGAffineTransform(translationX: 0, y: 0)
      fromView.alpha = 0
      toView.alpha = 1
      
      }) { (finished) -> Void in
        fromView.isHidden = true
    }
    
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    searchBar.resignFirstResponder()
  }
  
  
  
  
}
