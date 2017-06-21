//
//  ParseInterface.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/20/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit

import Parse


class ParseInterface: NSObject {
  
  // Refer to App setting on Parse: https://www.parse.com/apps/job4students/edit#keys
  
  let appId = "GVaD3r4Vyi7uQHSydphnOWW2KC4EHHAKm31GXDm7"
  let clientKey = "ICQxhc9IndnBEq5X0e4XBAvYIeULHhxzuyi0yzzS"
  let databaseClassName = "JobDatabase"
  
  let defaultUserName = "kivi"
  let defaultPassword = "kivi"
  
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
//    Parse.setApplicationId(appId, clientKey: clientKey)
    
    let config = ParseClientConfiguration(block: {
        (ParseMutableClientConfiguration) -> Void in
        
        ParseMutableClientConfiguration.applicationId = "kivi1234567vndfgdfgs";
        ParseMutableClientConfiguration.clientKey = "kivijdfadkshfkjsdhkjfhasdjkhfkjas";
        ParseMutableClientConfiguration.server = "http://kivi.us-east-1.elasticbeanstalk.com//parse";
    });
    
    Parse.initialize(with: config);

    
    
  }
  
  // Get Jobs Information from Database, return the PFObject array
  
  func getJobsInformation() -> [PFObject]? {
    if loginIsSuccess {
    let query = PFQuery(className: databaseClassName)
    query.order(byAscending: "updatedAt")
//    query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
    
    query.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) -> Void in
      
      if let error = error {
        let errorStr = error.userInfo["error"] as? String
        print("Error when finding object: \(errorStr) ")
        self.jobsInfo = nil
      } else {
        self.jobsInfo = objects!
        
      }
    } as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void as! ([PFObject]?, Error?) -> Void // end of block 
      return jobsInfo
    }
    else {
      return nil

    }
  }
  
  
  
  func parseSignUp(_ userName: NSString?, userPass: NSString?) -> Bool{
    let user = PFUser()
    user.username = userName as? String
    user.password = userPass as? String
    user.signUpInBackground {
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
    } as! PFBooleanResultBlock as! PFBooleanResultBlock as! PFBooleanResultBlock as! PFBooleanResultBlock as! PFBooleanResultBlock as! PFBooleanResultBlock as! PFBooleanResultBlock
    return signUpIsSuccess
  }
  
  func parseSignIn(_ userName: String?, userPass: String?) -> Bool {
    
    PFUser.logInWithUsername(inBackground: userName!, password: userPass!) { (user: PFUser?, err: NSError?) -> Void in
      
      if user != nil {
        self.loginIsSuccess = true
        print("Login succeeded with username: \(userName!)")
        
      } else {
        self.loginIsSuccess = false
        
        if let error = err {
          let errStr = error.userInfo["user"] as? NSString
          print("Error when login: \(errStr)")
            self.parseSignUp("kivi", userPass: "kivi")
        }
      }
    } as! PFUserResultBlock as! PFUserResultBlock as! PFUserResultBlock as! PFUserResultBlock as! PFUserResultBlock as! PFUserResultBlock as! PFUserResultBlock
    return loginIsSuccess
  }
  
  // This function will check is the current user is already login, go to next step, if not, show login or sign up
  func isLogInPrevious() -> Bool {
    let currentUser = PFUser.current()
    if currentUser != nil {
      print("Log in already, go to next")
      return true
    } else {
      // Show the signup or login screen
      self.parseSignUp(defaultUserName as NSString, userPass: defaultPassword as NSString)
      
      return false
    }

  }
}  // End of Class
