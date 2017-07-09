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
    
    // Refer to App setting on Parse on Back4App: https://dashboard.back4app.com/classic#/wizard/app-details/64a99a57-96f0-4c2f-95fc-f605ad982274
    
    let appId = "5bvI3MyuZIxfgVL3ayAxMmWuG4N4ofsJRGLqMxbg"
    let clientKey = "yhk5lnOLudTygtq709WNG7ZuOt8kOIRy2MHOlfLg"
    let seerverURL = "https://parseapi.back4app.com/"
    
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
      

        let config = ParseClientConfiguration {
            $0.applicationId = self.appId
            $0.clientKey   = self.clientKey
            $0.server = self.seerverURL
        }
        
        Parse.initialize(with: config);
        
        
        
    }
    
    // Get Jobs Information from Database, return the PFObject array
    
    func getJobsInformation() -> [PFObject]? {
        if loginIsSuccess {
            let query = PFQuery(className: databaseClassName)
            query.order(byAscending: "updatedAt")
            //    query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
            
            
            query.findObjectsInBackground(block: { (objects:[PFObject]?, error: Error?) in
                
                if let error = error {
                    let errorStr = error.localizedDescription
                    print("Error when finding object: \(errorStr) ")
                    self.jobsInfo = nil
                } else {
                    self.jobsInfo = objects!
                }
                
            })
            
        }
        return jobsInfo
    }
    
    
    
    func parseSignUp(_ userName: String?, userPass: String?) -> Bool{
        let user = PFUser()
        user.username = userName
        user.password = userPass
        user.email    = "tongvtdan@gmail.com"
        
        
        user.signUpInBackground { (succeeded, error) in
            if let err = error {
                print("Sign up failed \(err.localizedDescription)")
                self.signUpIsSuccess = false
            }else {
                print("Sign up successfully")
                self.signUpIsSuccess = true
            }
        }
        return signUpIsSuccess
        
    }
    
    func parseSignIn(_ userName: String?, userPass: String?) -> Bool {
        
        PFUser.logInWithUsername(inBackground: userName!, password: userPass!) { (user: PFUser?,  error) in
            if user != nil {
                self.loginIsSuccess  = true
                print("Login succeeded with username: \(String(describing: userName))")
                
            }else {
                self.loginIsSuccess = false
                print("Login failed: \(String(describing: error?.localizedDescription))")
            }
        }
        return loginIsSuccess
        
    }
    
    // This function will check is the current user is already login, go to next step, if not, show login or sign up
    func isLogInPrevious() -> Bool {
        let currentUser = PFUser.current()
        if currentUser != nil {
            print("Log in already, go to next")
            return true
        } else {
            return parseSignUp(defaultUserName , userPass: defaultPassword )
            // Show the signup or login screen
            
        }
        
    }
    
    // End of Class
}
