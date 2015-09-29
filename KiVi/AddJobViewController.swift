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
  var kbHeight: CGFloat!
  var editItemIndex = 0
  var currentLocation = CLLocation()
  
  var hud = MBProgressHUD()
  var dataIsSaved = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillAppear:"), name:UIKeyboardWillShowNotification, object: nil);
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillDisappear:"), name:UIKeyboardWillHideNotification, object: nil);
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func keyboardWillAppear(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        kbHeight = keyboardSize.height
        animateTextField(true)
      }
    }
  }
  func keyboardWillDisappear(notification: NSNotification){
    animateTextField(false)
    
  }
  
  func animateTextField(up: Bool) {
    let movement = (up ? -kbHeight : 0)
    //    animateImages(!up)
//    UIView.animateWithDuration(0.3, animations: {
//      self.jobDescriptionText.transform = CGAffineTransformMakeTranslation(0, movement)
//    })
  }
  
  @IBAction func comNameEditing(sender: UITextField) {
    editItemIndex = sender.tag
  }
  
  @IBAction func comAddressEditing(sender: UITextField) {
    editItemIndex = sender.tag
  }
  
  @IBAction func comJobTitleEditing(sender: UITextField) {
    editItemIndex = sender.tag
  }
  
  @IBAction func emailEditing(sender: UITextField) {
    editItemIndex = sender.tag
  }
  
  @IBAction func phoneNumberEditing(sender: UITextField) {
    editItemIndex = sender.tag
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  @IBAction func saveAllInfo(sender: UIButton) {
    dataIsSaved = false
    self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    self.hud.mode = MBProgressHUDMode.Indeterminate
    self.hud.labelText = "Saving your data to server..."
    
    saveNewJob()
    if dataIsSaved {
      self.navigationController?.popToRootViewControllerAnimated(true)
      activeJob = -1
    }
    
  }
  
  @IBAction func useCurrentLocation(sender: UIButton) {
    comAddressLabel.text = addressLabel.text
    
    
  }
  
  func saveNewJob() {
    let jobObj = PFObject(className: "JobsInformation")
    
    jobObj["createdBy"] = PFUser.currentUser()
    jobObj["jobTitle"]  = jobTitleLabel.text
    jobObj["jobDescription"]  = jobDescriptionText.text
    jobObj["salary"] = "NA"
    jobObj["jobType"] = "NA"
    jobObj["jobCategory"] = "NA"
    jobObj["workAt"] = "Ho Chi Minh"
    //    jobObj["dueOn"] =
    jobObj["companyName"] = comNameLabel.text
    jobObj["contactAddress"] = comAddressLabel.text
    jobObj["contactEmail"] = emailLabel.text
    jobObj["contactPhone"] = phoneNumberLabel.text
    let geopoint = PFGeoPoint()
    geopoint.latitude = currentLocation.coordinate.latitude
    geopoint.longitude = currentLocation.coordinate.longitude
    jobObj["location"] = geopoint
    
    let nowDate = NSDate()
    let dayToDue:Double = 30
    let dueDate = nowDate.dateByAddingTimeInterval(60*60*24*dayToDue)
    jobObj["dueOn"] = dueDate
    
    jobObj.saveInBackgroundWithBlock({
      (success: Bool, error: NSError?) -> Void in
      
      if error == nil {
        /**success saving, Now save image.***/
        
        //create an image data
        let imageData = UIImagePNGRepresentation(self.profilePhoto.image!)
        //create a parse file to store in cloud
        let parseImageFile = PFFile(name: "profile_image.png", data: imageData!)
        jobObj["profilePhoto"] = parseImageFile
        jobObj.saveInBackgroundWithBlock({
          (success: Bool, error: NSError?) -> Void in
          if error == nil {
            //take user home
            print("data uploaded")
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.dataIsSaved = true
          }else {
            print(error)
          }
        }) // saveInBackgroundWithBlock - save image - End
      }else {
        print(error)
      }
    }) // saveInBackgroundWithBlock - save obj - End
    
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
    locationManager.stopUpdatingLocation()
    
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
    //    let latitude = userLocation.coordinate.latitude
    //    let longitude = userLocation.coordinate.longitude
    self.currentLocation = userLocation
    
    
    
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
