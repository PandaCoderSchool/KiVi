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
import MBProgressHUD
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


var jobIsUpdated = -1

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
  
  var timer: Timer = Timer()
  
  let regionRadius: CLLocationDistance = 1000 // 1000m
  
  var profilePhoto: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
    NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.updateMap(_:)), name: NSNotification.Name(rawValue: "searchResultUpdated"), object: nil)
  }
  
  deinit{
    NotificationCenter.default.removeObserver(self)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if jobIsUpdated == -1 {
      self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
      self.hud.mode = MBProgressHUDMode.indeterminate
      self.hud.labelText = "Updating jobs on map"
      
      locationManager.startUpdatingLocation()
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.fetchJobsInformation), userInfo: nil, repeats: true)
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    locationManager.stopUpdatingLocation()
  }
  
  func updateMap(_ notification: Notification) {
    let userInfo:Dictionary<String,[PFObject]?> = notification.userInfo as! Dictionary<String,[PFObject]?>
    jobsList = userInfo["result"]!
    print("Updated: \(jobsList!.count)" )
    updateJobsMap()
  }
  
  
  func fetchJobsInformation() {
    jobsList = ParseInterface.sharedInstance.getJobsInformation()
    if jobsList?.count > 0 {
      self.updateJobsMap()
      jobIsUpdated = 1
    }
    
  }
  
  func updateJobsMap() {
    // 1: remove all current on map annotation
    jobMap.removeAnnotations(self.jobMap.annotations)
    
    // 2: update new
    if jobsList?.count > 0 {
      for job in jobsList! {
        pinJobOnMap(job)
      }
      timer.invalidate()
      MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
      
    }
    
  }
  
  // View job on Map
  
  func pinJobOnMap(_ jobToPin: PFObject?) {
    
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = jobToPin!["employerAddress"] as? String
    
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.start { (localSearchResponse, error) -> Void in
//      
//      if localSearchResponse == nil{
//        let alert = UIAlertController(title: "Places not found", message: "Please check the internet connection", preferredStyle: UIAlertControllerStyle.Alert)
//        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
//        alert.addAction(cancel)
//        
//        self.presentViewController(alert, animated: true, completion: nil)
//        
//        return
//      }
      let geoPoint = PFGeoPoint()
      geoPoint.latitude = localSearchResponse!.boundingRegion.center.latitude
      geoPoint.longitude  = localSearchResponse!.boundingRegion.center.longitude
      
      self.pointAnnotation = MKPointAnnotation()
      self.pointAnnotation.title    = (jobToPin!["jobTitle"] as? String)!
      self.pointAnnotation.subtitle =  (jobToPin!["jobType"] as? String)! + " - " + (jobToPin!["salary"] as? String)!
      
      /*
      if let thumbNail = jobToPin!["profilePhoto"] as? PFFile {
        thumbNail.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
          if (error == nil) {
            let image = UIImage(data:imageData!)
            //image object implementation
            self.profilePhoto = image
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
            self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
            
          }
          
        }) // getDataInBackgroundWithBlock - end
      }
      */
      self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
      self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
      self.jobMap.centerCoordinate = self.pointAnnotation.coordinate
      self.jobMap.addAnnotation(self.pinAnnotationView.annotation!)
    }
  }
  
  
  func updateUserCurrentLocation(_ userLocation: CLLocation) {
    self.centerMapOnLocation(userLocation)
    
  }
  
    func getAddressFromLocation(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { (
            placemarks, error) in
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
    
  
  func centerMapOnLocation(_ location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
      regionRadius * 20.0, regionRadius * 20.0)
    jobMap.setRegion(coordinateRegion, animated: true)
  }
}
// MARK: extension area

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
  // MARK: Location Manager Delegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let userLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(userLocation)
    if userLocation.timestamp.timeIntervalSinceNow < 300 {
      self.locationManager.stopUpdatingLocation()
    }
  }
  
  // MARK: Map View Delegate protocol
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if !(annotation is  MKPointAnnotation) {
      return nil
    }
    
    // Resize the image selected
    /*
    let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
    resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
    resizeRenderImageView.layer.borderWidth = 3.0
    resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
    resizeRenderImageView.image = profilePhoto //UIImage(named: "defaultImage")
    
    UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
    resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    */
    
    let reuseID = "myAnnotationView"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
    if (annotationView == nil) {
      // Must use MKAnnotationView instead of MKPointAnnotationView if we want to use image for pin annotation
      //      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      
      annotationView!.canShowCallout = true
      // Left Image annotation
//      annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:80))
//      let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
//      imageView.image = profilePhoto
      //      annotationView!.image = thumbnail
      
      
      // Right button annotation
      annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
    }
    else {
      annotationView!.annotation = annotation
    }
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    if control == view.rightCalloutAccessoryView {
      let vc = self.storyboard?.instantiateViewController(withIdentifier: "JobDetails") as! JobDetailsViewController
      vc.selectedAnnotation = view
      self.navigationController?.pushViewController(vc, animated: true)
      jobIsUpdated = 1
      
    }
  }
  
  
}

