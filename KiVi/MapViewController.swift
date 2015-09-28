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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
  
  @IBOutlet var jobMap: MKMapView!
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    
    locationManager.startUpdatingLocation()
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "fetchJobsInformation", userInfo: nil, repeats: true)
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
    self.updateJobsMap()
    print("Getting joblist")
    
  }
  
  func updateJobsMap() {
    if jobsList?.count > 0 {
      for var i = 0; i < jobsList?.count; i++ {
        selectedJob = jobsList![i]
        pinJobOnMap(selectedJob)
      }
      timer.invalidate()
    }
    
  }
  
  // View job on Map
  let regionRadius: CLLocationDistance = 20000 // 20 km
  
  func pinJobOnMap(jobToPin: PFObject?) {
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = jobToPin!["contactAddress"] as? String
    
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
        alert.show()
        return
      }
      //3
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title    = jobToPin!["jobTitle"] as? String
      self.pointAnnotation.subtitle = jobToPin!["contactAddress"] as? String
      
      self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      
      
      self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
      self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
      self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
      
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, self.regionRadius, self.regionRadius)
      self.jobMap.setRegion(coordinateRegion, animated: true)
      
      
    }
    
  }

  
  func updateUserCurrentLocation(userLocation: CLLocation) {
    let latitude = userLocation.coordinate.latitude
    let longitude = userLocation.coordinate.longitude
    
    let lonDelta:  CLLocationDegrees  = 0.01
    let latDelta: CLLocationDegrees   = lonDelta
    let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
    let location: CLLocationCoordinate2D  = CLLocationCoordinate2DMake(latitude, longitude)
    let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
    
    self.jobMap.setRegion(region, animated: false)
    
    self.getAddressFromLocation(userLocation)

  }
  
  func getAddressFromLocation(location: CLLocation) {
    CLGeocoder().reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
      if error == nil {
        
        if let pm = placemarks?.first {
          
          var subThoroughfare: String = ""
          var thoroughfare: String = ""
          var name: String = ""
          var areaOfInterest: String = ""
          
          
          if pm.subThoroughfare != nil {
            subThoroughfare = pm.subThoroughfare!
          }
          if pm.thoroughfare != nil {
            thoroughfare = pm.thoroughfare!
          }
          if pm.name != nil {
            name = pm.name!
          }
          if pm.areasOfInterest != nil {
            areaOfInterest = pm.areasOfInterest!.first!
          }
          let title = "\(subThoroughfare), \(thoroughfare)"
          let addr = "\(pm.subLocality!), \(pm.subAdministrativeArea!), \(pm.administrativeArea!) \(pm.country!)"
          
          
          self.pointAnnotation = MKPointAnnotation()
          self.pointAnnotation.title    = title
          self.pointAnnotation.subtitle = addr
          
          self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
          
          self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
          self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
          self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
 
          
      }
    }
  }
  
  let regionRadius: CLLocationDistance = 1000
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 2.0, regionRadius * 2.0)
    jobMap.setRegion(coordinateRegion, animated: true)
  }
  
  
  
}
}

