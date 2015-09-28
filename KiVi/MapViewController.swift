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
  
  var locationManager: CLLocationManager!
  
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
  }
  
  override func viewDidDisappear(animated: Bool) {
    locationManager.stopUpdatingLocation()
  }
  
  // MARK: Location Manager Delegate
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let userLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(userLocation)
    if userLocation.timestamp.timeIntervalSinceNow < 300 {
      self.locationManager.stopUpdatingLocation()
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
          let annotation = MyAnnotation(title: title, locationName: addr, discipline: addr, coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
          self.jobMap.addAnnotation(annotation)
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

