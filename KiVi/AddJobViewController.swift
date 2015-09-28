//
//  AddJobViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/28/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class AddJobViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var profilePhoto: UIImageView!
  
  @IBOutlet weak var comNameLabel: UITextField!
  @IBOutlet weak var comAddressLabel: UITextField!
  @IBOutlet weak var jobTitleLabel: UITextField!
  @IBOutlet weak var jobDescriptionText: UITextView!
  @IBOutlet weak var emailLabel: UITextField!
  @IBOutlet weak var phoneNumberLabel: UITextField!
  
  let imagePicker = UIImagePickerController()
  var photo : UIImage?
  var locationManager = CLLocationManager()

  
  
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
  @IBAction func saveAllInfo(sender: UIButton) {
  }
  
  @IBAction func useCurrentLocation(sender: UIButton) {
    comAddressLabel.text = addressLabel.text
    
  }

  // MARK: Image picker protocol
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let editedImage = info[UIImagePickerControllerEditedImage]as! UIImage
    photo = editedImage
    profilePhoto.image = editedImage
    locationManager.stopUpdatingLocation()
    
    picker.dismissViewControllerAnimated(true) { () -> Void in
      print("Image was captured")
      
      //      let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LocationsViewController") as! LocationsViewController
      //      vc.delegate = self
      //      self.presentViewController(vc, animated: true, completion: nil)
    }

  }
  
  // MARK: LocationManager protocol
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let currentLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(currentLocation)
    self.getAddressFromLocation(currentLocation)
    
  }
  
  @IBAction func TapToTakePhoto(sender: UITapGestureRecognizer) {
    
    locationManager.startUpdatingLocation()
    
    imagePicker.delegate = self
    
    imagePicker.allowsEditing = true
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
    } else {
      imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    
    self.presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  func updateUserCurrentLocation(userLocation: CLLocation) {
    let latitude = userLocation.coordinate.latitude
    let longitude = userLocation.coordinate.longitude
    
    
    
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
          
          let addr = "\(subThoroughfare), \(thoroughfare), \(subLocality), \(subAdministrativeArea), \(administrativeArea) \(country)"
          
          
          print(addr)
          self.addressLabel.text = "\(addr)"
          
          
        }
      }
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
    
  }
  
  func textFieldShouldReturn (textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
    
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
