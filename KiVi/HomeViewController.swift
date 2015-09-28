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
  var isMapViewSelected: Bool = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
    self.setupSearchBar()
    
//    if ParseInterface.sharedInstance.isLogInPrevious() {
//      print("Already login. Show main screen")
//    }else {
//      print("User must sign up first then login again")
//      
//      ParseInterface.sharedInstance.parseSignIn(ParseInterface.sharedInstance.defaultUserName , userPass: ParseInterface.sharedInstance.defaultPassword)
//    }
    
    mapContainerView.hidden   = !isMapViewSelected
    listContainerView.hidden  = isMapViewSelected
    
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func setupSearchBar() {
    
    searchBar.placeholder = "Search a job"
    self.navigationItem.titleView = self.searchBar
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

  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
