//
//  ParseInterface.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/20/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit



class ParseInterface: NSObject {
  
  // Refer to App setting on Parse: https://www.parse.com/apps/job4students/edit#keys
  
  let appId = "GVaD3r4Vyi7uQHSydphnOWW2KC4EHHAKm31GXDm7"
  let clientKey = "ICQxhc9IndnBEq5X0e4XBAvYIeULHhxzuyi0yzzS"
  let databaseClassName = "JobDatabase"
  
  let defaultUserName = "panda"
  let defaultPassword = "panda"
  
  var jobsInfo  : [PFObject]?
  var employers : [PFObject]?
  
  var signUpIsSuccess = false
  var loginIsSuccess = false
  // sharedInstance to be used in other classes
  
  class var sharedInstance: ParseInterface {
    struct Static {
      static var instance = ParseInterface()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    jobsInfo = [PFObject]()
    employers = [PFObject]()
    
  }
  
  // This will be call in AppDelegate to setup Parse Application
  
  func parseSetup() {
    Parse.setApplicationId(appId, clientKey: clientKey)
  }
  
  // Get Jobs Information from Database, return the PFObject array
  
  func getJobsInformation() -> [PFObject]? {
    if loginIsSuccess {
    let query = PFQuery(className: databaseClassName)
    query.orderByAscending("updatedAt")
//    query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
    
    query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
      
      if let error = error {
        let errorStr = error.userInfo["error"] as? String
        print("Error when finding object: \(errorStr) ")
        self.jobsInfo = nil
      } else {
        self.jobsInfo = objects!
        
      }
    } // end of block 
      return jobsInfo
    }
    else {
      return nil

    }
  }
  
  
  
  func parseSignUp(userName: NSString?, userPass: NSString?) -> Bool{
    let user = PFUser()
    user.username = userName as? String
    user.password = userPass as? String
    user.signUpInBackgroundWithBlock {
      (succeeded: Bool, error: NSError?) -> Void in
      if let error = error {
        let errorString = error.userInfo["error"] as? NSString
        print(errorString)
        self.signUpIsSuccess = false
      } else {
//        self.performSegueWithIdentifier("loginSegue", sender: self)
        print("Sign up successful")
        self.signUpIsSuccess = true
      }
    }
    return signUpIsSuccess
  }
  
  func parseSignIn(userName: String?, userPass: String?) -> Bool {
    
    PFUser.logInWithUsernameInBackground(userName!, password: userPass!) { (user: PFUser?, err: NSError?) -> Void in
      
      if user != nil {
        self.loginIsSuccess = true
        print("Login succeeded with username: \(userName!)")
        
      } else {
        self.loginIsSuccess = false
        
        if let error = err {
          let errStr = error.userInfo["user"] as? NSString
          print("Error when login: \(errStr)")
        }
      }
    }
    return loginIsSuccess
  }
  
  // This function will check is the current user is already login, go to next step, if not, show login or sign up
  func isLogInPrevious() -> Bool {
    let currentUser = PFUser.currentUser()
    if currentUser != nil {
      print("Log in already, go to next")
      return true
    } else {
      // Show the signup or login screen
      self.parseSignUp(defaultUserName, userPass: defaultPassword)
      
      return false
    }

  }
}  // End of Class
