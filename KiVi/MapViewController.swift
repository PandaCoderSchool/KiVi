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

class MapViewController: UIViewController, MBProgressHUDDelegate {
  
  
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
  
  let regionRadius: CLLocationDistance = 1000 // 1000m
  
  var profilePhoto: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateMap:"), name: "searchResultUpdated", object: nil)
  }
  
  deinit{
    NSNotificationCenter.defaultCenter().removeObserver(self)
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
  
  func updateMap(notification: NSNotification) {
    let userInfo:Dictionary<String,[PFObject]!> = notification.userInfo as! Dictionary<String,[PFObject]!>
    jobsList = userInfo["result"]
    print("Updated: \(jobsList!.count)" )
    updateJobsMap()
  }
  
  
  func fetchJobsInformation() {
    jobsList = ParseInterface.sharedInstance.getJobsInformation()
    if jobsList?.count > 0 {
      self.updateJobsMap()
    }
    
  }
  
  func updateJobsMap() {
    // 1: remove all current on map annotation
    jobMap.removeAnnotations(self.jobMap.annotations)
    
    // 2: update new
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
    localSearchRequest.naturalLanguageQuery = jobToPin!["employerAddress"] as? String
    
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alert = UIAlertController(title: "Places not found", message: "Please check the internet connection", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancel)
      
        self.presentViewController(alert, animated: true, completion: nil)

        return
      }
      let geoPoint = PFGeoPoint()
      geoPoint.latitude = localSearchResponse!.boundingRegion.center.latitude
      geoPoint.longitude  = localSearchResponse!.boundingRegion.center.longitude
      
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title    = jobToPin!["jobTitle"] as? String
      self.pointAnnotation.subtitle = jobToPin!["employerAddress"] as? String
      
      if let thumbNail = jobToPin!["profilePhoto"] as? PFFile {
        
        thumbNail.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
          if (error == nil) {
            let image = UIImage(data:imageData!)
            //image object implementation
            self.profilePhoto = image
          }
        }) // getDataInBackgroundWithBlock - end
      }
      self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      
      self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
      self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
      self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
    }
  }

  
  func updateUserCurrentLocation(userLocation: CLLocation) {
    self.centerMapOnLocation(userLocation)

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
}
// MARK: extension area

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
  // MARK: Location Manager Delegate
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let userLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(userLocation)
    if userLocation.timestamp.timeIntervalSinceNow < 300 {
      self.locationManager.stopUpdatingLocation()
    }
  }

  // MARK: Map View Delegate protocol
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if !(annotation is  MKPointAnnotation) {
      return nil
    }
    /*
    // Resize the image selected
    let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
    resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
    resizeRenderImageView.layer.borderWidth = 3.0
    resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
    resizeRenderImageView.image = profilePhoto //UIImage(named: "defaultImage")
    
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
      // Left Image annotation
      annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:80))
      let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
      
      annotationView!.image = thumbnail
      
      imageView.image = profilePhoto //UIImage(named: "defaultImage")
      // Right button annotation
      annotationView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIButton
    }
    else {
      annotationView!.annotation = annotation
    }
    
    return annotationView
    */
    let reuseID = "JobMapAnnotationView"
    let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
    if (annotationView == nil) {
        var annotationView:DXAnnotationView = DXAnnotationView()
        
        let image : UIImage = UIImage(named:"pin")!
        let imgView : UIImageView = UIImageView(image: image)
        var callOutView:JobMapAnnotationView = JobMapAnnotationView()
        
        annotationView = DXAnnotationView(annotation: annotation, reuseIdentifier: NSStringFromClass(DXAnnotationView), pinView: imgView, calloutView: callOutView, settings: DXAnnotationSettings.defaultSettings()!)
       
    } else {
        annotationView!.annotation = annotation
    }
    return annotationView
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if control == view.rightCalloutAccessoryView {
      let vc = self.storyboard?.instantiateViewControllerWithIdentifier("JobDetails") as! JobDetailsViewController
      vc.selectedAnnotation = view
      self.navigationController?.pushViewController(vc, animated: true)
      activeJob = 1
      
    }
  }

  
}

