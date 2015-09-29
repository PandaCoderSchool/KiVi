//
//  MapViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/27/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var activeJob = -1

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate {
  
  
  @IBOutlet var jobMap: MKMapView!
  var hud : MBProgressHUD = MBProgressHUD()
  
  var selectedJob: PFObject?
  var jobsList: [PFObject]? = [PFObject]()
  
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var pointAnnotation:MKPointAnnotation!
  var pinAnnotationView:MKPinAnnotationView!
  
  var locationManager = CLLocationManager()
  var userAnnotation = MKPointAnnotation()
  
  var timer: NSTimer = NSTimer()
  
  let regionRadius: CLLocationDistance = 1000
  
  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    if activeJob == -1 {
      self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.hud.mode = MBProgressHUDMode.Indeterminate
      self.hud.labelText = "Updating map with job location"
      
      locationManager.startUpdatingLocation()
      timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "fetchJobsInformation", userInfo: nil, repeats: true)
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    locationManager.stopUpdatingLocation()
  }
  
  // MARK: Map View Delegate protocol
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if !(annotation is  MKPointAnnotation) {
      return nil
    }
    
    // Resize the image selected
    let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
    resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
    resizeRenderImageView.layer.borderWidth = 3.0
    resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
    resizeRenderImageView.image = UIImage(named: "defaultImage")
    
    UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
    resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let reuseID = "myAnnotationView"
    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
    if (annotationView == nil) {
      // Must use MKAnnotationView instead of MKPointAnnotationView if we want to use image for pin annotation
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      annotationView!.canShowCallout = true
      annotationView!.image = thumbnail
      // Left Image annotation
      annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:80))
      let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
      imageView.image = UIImage(named: "defaultImage")
      // Right button annotation
      annotationView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIButton
    }
    else {
      annotationView!.annotation = annotation
    }
    
    return annotationView
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if control == view.rightCalloutAccessoryView {
      let vc = self.storyboard?.instantiateViewControllerWithIdentifier("JobDetails") as! JobDetailsViewController
      let location = view.annotation?.coordinate
      vc.selectedLocation = location!
      self.navigationController?.pushViewController(vc, animated: true)
      activeJob = 1
      
    }
  }
  // MARK: Location Manager Delegate
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let userLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(userLocation)
    if userLocation.timestamp.timeIntervalSinceNow < 300 {
      self.locationManager.stopUpdatingLocation()
    }
    
  }
  
  func fetchJobsInformation() {
    jobsList = ParseInterface.sharedInstance.getJobsInformation()
    if jobsList?.count > 0 {
      self.updateJobsMap()
    }
    
  }
  
  func updateJobsMap() {
    
//    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//    self.hud.mode = MBProgressHUDMode.Indeterminate
//    self.hud.labelText = "Loading"
    
    if jobsList?.count > 0 {
      for var i = 0; i < jobsList?.count; i++ {
        selectedJob = jobsList![i]
        pinJobOnMap(selectedJob)
      }
      timer.invalidate()
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      
    }
    
  }
  
  // View job on Map
  
  func pinJobOnMap(jobToPin: PFObject?) {
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = jobToPin!["contactAddress"] as? String
    
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alert = UIAlertController(title: "Place not found", message: "Please check the internet connection", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)

        return
      }

      
      let geoPoint = PFGeoPoint()
      geoPoint.latitude = localSearchResponse!.boundingRegion.center.latitude
      geoPoint.longitude  = localSearchResponse!.boundingRegion.center.longitude
      
      // Update to current Job
      
      let query = PFQuery(className:"JobsInformation")
      query.getObjectInBackgroundWithId((jobToPin?.objectId)!) {
        (joblist : PFObject?, error: NSError?) -> Void in
        if error != nil {
          print(error)
        } else if let joblist = joblist {
          joblist["jobId"] = "T0001"
          joblist["location"] = geoPoint
          joblist.saveInBackground()

        }
      }
      
      
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title    = jobToPin!["jobTitle"] as? String
      self.pointAnnotation.subtitle = jobToPin!["contactAddress"] as? String
      
      self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      
      
      self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
      self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
      self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
      
//      let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, self.regionRadius, self.regionRadius)
//      self.jobMap.setRegion(coordinateRegion, animated: true)
      
      
    }
    
  }

  
  func updateUserCurrentLocation(userLocation: CLLocation) {
    self.centerMapOnLocation(userLocation)
//    let latitude = userLocation.coordinate.latitude
//    let longitude = userLocation.coordinate.longitude
//    
//    let lonDelta:  CLLocationDegrees  = 0.01
//    let latDelta: CLLocationDegrees   = lonDelta
//    let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//    let location: CLLocationCoordinate2D  = CLLocationCoordinate2DMake(latitude, longitude)
//    let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//    
//    self.jobMap.setRegion(region, animated: false)
    
    
//    self.getAddressFromLocation(userLocation)

  }
  
  func getAddressFromLocation(location: CLLocation) {
    CLGeocoder().reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
      if error == nil {
        
        if let pm = placemarks?.first {
          
          var subThoroughfare: String = ""
          var thoroughfare: String = ""
          var subLocality: String = ""
          var subAdministrativeArea: String = ""
          var administrativeArea: String = ""
          var country: String = ""
          
          if pm.subThoroughfare != nil {
            subThoroughfare = pm.subThoroughfare!
          }
          if pm.thoroughfare != nil {
            thoroughfare = pm.thoroughfare!
          }
          if pm.subLocality != nil {
            subLocality = pm.subLocality!
          }
          if pm.subAdministrativeArea != nil {
            subAdministrativeArea = pm.subAdministrativeArea!
          }
          if pm.administrativeArea != nil {
            administrativeArea = pm.administrativeArea!
          }
          if pm.country != nil {
            country = pm.country!
          }
          
          let addr = "\(subThoroughfare), \(thoroughfare), \(subLocality), \(subAdministrativeArea), \(administrativeArea), \(country)"
          
          
          print(addr)

          
          
          self.pointAnnotation = MKPointAnnotation()
          self.pointAnnotation.title    = "Job Address"
          self.pointAnnotation.subtitle = addr
          
          self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
          
          self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
          self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
          self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
 
          
      }
    }
  }
  
  
    
  
  
}
  
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 20.0, regionRadius * 20.0)
    jobMap.setRegion(coordinateRegion, animated: true)
  }

  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "addJobSegue" {
      activeJob = -1
    }
    
  }

}

