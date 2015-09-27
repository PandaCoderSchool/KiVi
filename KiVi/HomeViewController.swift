//
//  HomeViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/27/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate {
  
  
  var searchBar = UISearchBar()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
    self.setupSearchBar()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func setupSearchBar() {
    
    searchBar.placeholder = "Search a job"
    self.navigationItem.titleView = self.searchBar
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
