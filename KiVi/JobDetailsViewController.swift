//
//  JobDetailsViewController.swift
//  Jobs4Students
//
//  Created by Dan Tong on 9/21/15.
//  Copyright © 2015 iOS Swift Course. All rights reserved.
//

import UIKit
import MapKit

class JobDetailsViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var map: MKMapView!
  
  @IBOutlet weak var jobDescription: UITextView!
  var selectedJob: PFObject?
  
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var pointAnnotation:MKPointAnnotation!
  var pinAnnotationView:MKPinAnnotationView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Update Map
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = selectedJob!["contactAddress"] as? String
    
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
        alert.show()
        return
      }
      
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title  = self.selectedJob!["jobTitle"] as? String
      self.pointAnnotation.subtitle = self.selectedJob!["contactAddress"] as? String
      
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
    self.title = selectedJob!["jobTitle"] as? String
    jobDescription.text = selectedJob!["jobDetails"] as! String
    
    
    
    
  }
  
  @IBAction func onShareJob(sender: UIBarButtonItem) {
    let textToShare = selectedJob!["jobDescription"] as! String // "Swift is awesome!  Check out this website about it!"
    let contactAddress = self.selectedJob!["contactAddress"] as! String

//    if let myWebsite = NSURL(string: "http://www.codingexplorer.com/")
//    {
      let objectsToShare = [textToShare, contactAddress]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
      self.presentViewController(activityVC, animated: true, completion: nil)
//    }
  }
  
  @IBAction func onApplyJob(sender: UIBarButtonItem) {
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
