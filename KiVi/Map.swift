//
//  Map.swift
//  KiVi
//
//  Created by Dan Tong on 9/28/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapDelegate: class {
  func updateUserCurrentLocation(userLocation: CLLocation)
}

class Map: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
  
  var locationManager: CLLocationManager!
  weak var delegate: MapDelegate!

  class var sharedInstance: Map {
    struct Static {
      static var instance = Map()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    self.locationManager = CLLocationManager()
    
  }
  
  func initLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
  }
  
  func getAddressFromCurrentLocation() {
    locationManager.startUpdatingLocation()
    
  }
  
  func getLocationFromAddress(address: String){
    
  }
  

  
  func pinLocationOnMap() {
    
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let userLocation: CLLocation = locations.last!
    delegate.updateUserCurrentLocation(userLocation)
    
//    updateUserAnnotation(location)
    
  }
//  
//  func updateUserLocation(userLocation: CLLocation?) {
//    
//    let latitude = userLocation.coordinate.latitude
//    let longitude = userLocation.coordinate.longitude
//    
//    let lonDelta:  CLLocationDegrees  = 0.01
//    let latDelta: CLLocationDegrees   = lonDelta
//    let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//    let location: CLLocationCoordinate2D  = CLLocationCoordinate2DMake(latitude, longitude)
//    let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
//    
//    let userAnnotation: MKPointAnnotation
//    
//    
//    
//    self.map.setRegion(region, animated: false)
//
//    userAnnotation.coordinate = location!
//    userAnnotation.title  = "I'm here"
//    self.map.addAnnotation(userAnnotation)
//  }
  


}
