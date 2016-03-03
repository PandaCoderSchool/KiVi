//
//  JobDetailsViewController.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/21/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit
import MapKit

import MBProgressHUD
import Parse


class JobDetailsViewController: UIViewController, MKMapViewDelegate, MBProgressHUDDelegate {
  
  @IBOutlet weak var map: MKMapView!
  
  @IBOutlet weak var jobTitle: UILabel!
  @IBOutlet weak var jobDescription: UITextView!
  @IBOutlet weak var profileImage: UIImageView!
  
  @IBOutlet weak var salaryLabel: UILabel!
  @IBOutlet weak var jobTypeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  
  var hud : MBProgressHUD = MBProgressHUD()
  
  var selectedJob: PFObject?
  
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var pointAnnotation:MKPointAnnotation!
  var pinAnnotationView:MKPinAnnotationView!
  
  var selectedLocation = CLLocationCoordinate2D()
  var selectedAnnotation = MKAnnotationView()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    if selectedJob == nil {
      updateWithSelectedPinJob() // trigger from MAP
    } else {
      updateWithSelectedJob() // trigger from Table
    }
  }
  
  func updateWithSelectedPinJob() {
    // getting info base on location
//    let geopoint = PFGeoPoint()
//    geopoint.latitude = location.latitude
//    geopoint.longitude = location.longitude
//    print("Location received: \(location)")
//    print("Geopoint: \(geopoint)")
    
    let queryWith: String = selectedAnnotation.annotation!.title!!
    
    let query = PFQuery(className: ParseInterface.sharedInstance.databaseClassName)
    query.whereKey("jobTitle", equalTo: queryWith )  // get object with the same job title
    query.orderByAscending("updatedAt")
    
    query.findObjectsInBackgroundWithBlock { (jobObject: [PFObject]?, error: NSError?) -> Void in
      
      self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hud.mode = MBProgressHUDMode.Indeterminate
      self.hud.labelText = "Loading data..."
      
      if let error = error {
        let errorStr = error.userInfo["error"] as? String
        print("Error: \(errorStr) ")
      } else {
          for obj in jobObject!
        {
          self.selectedJob = obj
          self.updateWithSelectedJob()
        }
      }
    } // Block - end    
    // Update location on Map
    let latDelta: CLLocationDegrees = 0.01
    let lonDelta: CLLocationDegrees = 0.01
    let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
    let region: MKCoordinateRegion = MKCoordinateRegionMake((selectedAnnotation.annotation?.coordinate)!, span)
    self.map.setRegion(region, animated: true)
  }
  func updateWithSelectedJob() {
    // Update Map
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = selectedJob!["employerAddress"] as? String
    
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alert = UIAlertController(title: "Place not found", message: "Please check again", preferredStyle: UIAlertControllerStyle.Alert)
        alert.presentedViewController
        return
      }
      
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title  = self.selectedJob!["jobTitle"] as? String
      self.pointAnnotation.subtitle = self.selectedJob!["employerAddress"] as? String
      
      self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      
      
      self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
      self.map.centerCoordinate = self.pointAnnotation.coordinate
      self.map.addAnnotation(self.pinAnnotationView.annotation!)

      
      let latitude: CLLocationDegrees = localSearchResponse!.boundingRegion.center.latitude
      let longitue: CLLocationDegrees = localSearchResponse!.boundingRegion.center.longitude
      
      let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitue)
      let latDelta: CLLocationDegrees = 0.01
      let lonDelta: CLLocationDegrees = 0.01
      let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
      let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
      self.map.setRegion(region, animated: true)
    }
    // Update Job info
    self.title = "Job Details"
    
    
    
    if let thumbNail = selectedJob!["profilePhoto"] as? PFFile {
      thumbNail.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
        if (error == nil) {
          let image = UIImage(data:imageData!)
          //image object implementation
          self.profileImage.image = image
        }
      }) // getDataInBackgroundWithBlock - end
    }
    jobTitle.text       = selectedJob!["jobTitle"] as? String
    jobDescription.text = selectedJob!["jobDescription"] as! String
    salaryLabel.text    = selectedJob!["salary"] as? String
    jobTypeLabel.text   = selectedJob!["jobType"] as? String
    addressLabel.text   = selectedJob!["employerAddress"] as? String


    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)

  }
  
  @IBAction func onShareJob(sender: UIBarButtonItem) {
    let textToShare = (selectedJob!["jobTitle"] as! String) + "\n" + (selectedJob!["jobDescription"] as! String)
    let contactAddress = self.selectedJob!["employerAddress"] as! String
      let objectsToShare = [textToShare, contactAddress]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
      self.presentViewController(activityVC, animated: true, completion: nil)
  }
  
  @IBAction func onApplyJob(sender: UIBarButtonItem) {
    
    let alertController = UIAlertController(title: "Apply for the job", message: nil, preferredStyle: .ActionSheet)
    let emailAddress = selectedJob!["employerEmail"] as! String
    let emailStr = "Email: " + emailAddress
    
    let email = UIAlertAction(title: emailStr, style: .Default, handler: { (action) -> Void in
      print("Apply by email")
      UIApplication.sharedApplication().openURL(NSURL(string: "mailto:\(emailAddress)")!)
    })
    
    let phoneNumber = selectedJob!["employerPhone"] as! String
    let phoneStr = "Phone: " + phoneNumber
    let  phone = UIAlertAction(title: phoneStr, style: .Default) { (action) -> Void in
      print("Apply by phone")
      UIApplication.sharedApplication().openURL(NSURL(string: "telprompt://\(phoneNumber)")!)
    }
    
    let addrStr = "Direct to: " + (selectedJob!["employerAddress"] as! String)
    let address = UIAlertAction(title: addrStr, style: .Default) { (action) -> Void in
      print("Apply by going to address")
      self.getDirection()
    }

    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
      print("Cancel Button Pressed")
    })
    
    
    alertController.addAction(email)
    alertController.addAction(phone)
    alertController.addAction(address)
    
    alertController.addAction(cancel)
    
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func getDirection() {
    let selectedPlacemark = MKPlacemark(coordinate: selectedLocation, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: selectedPlacemark)
    
    mapItem.name = selectedJob!["employerAddress"] as?  String
    
    //You could also choose: MKLaunchOptionsDirectionsModeWalking
    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
    
    mapItem.openInMapsWithLaunchOptions(launchOptions)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
}
