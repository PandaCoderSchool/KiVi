//
//  AddJobViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/28/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

class AddJobViewController: UIViewController {
  
  
  @IBOutlet weak var addImage: UIImageView!
  @IBOutlet weak var profilePhoto: UIImageView!
  
  
  @IBOutlet weak var jobDescriptionText: UITextView!
  
  @IBOutlet weak var tpScrollView: TPKeyboardAvoidingScrollView!
  
  let imagePicker = UIImagePickerController()
  var photo : UIImage?
  var locationManager = CLLocationManager()
  var kbHeight: CGFloat!
  var editItemIndex = 0
  var currentLocation = CLLocation()
  
  @IBOutlet weak var employerNameText: UITextField!
  @IBOutlet weak var employerAddressText: UITextField!
  @IBOutlet weak var employerEmailText: UITextField!
  @IBOutlet weak var employerPhoneText: UITextField!
  
  @IBOutlet weak var jobTitleText: UITextField!
  @IBOutlet weak var jobSalaryText: UITextField!
  
  @IBOutlet weak var workAtPickerTextField: UITextField!
  @IBOutlet weak var datePickerTextField: UITextField!
  @IBOutlet weak var jobTypePickerTextField: UITextField!
  @IBOutlet weak var sectorPickerTextField: UITextField!
  
  
  let datePickerView: UIDatePicker = UIDatePicker()
  
  let workAtList = ["-- Chose a region --", "Ho Chi Minh", "Da Nang", "Ha Noi", "Binh Duong", "Vung Tau", "Can Tho", "Phan Thiet"]
  let workAtPickerView = UIPickerView()
  
  let jobTypeList = ["-- Chose a job type --", "Part Time Jobs", "Summer/Holiday Jobs", "Temporary Jobs", "Internships", "Full Time Jobs"]
  let jobTypePickerView = UIPickerView()
  
  let sectorList = ["-- Chose a job sector --","Admin", "Advertising/Marketing/PR", "Agriculture", "Art/Music","Catering/Leisure", "Childcare/Care Work","Customer Service/Call Center", "Defense/Security","Education", "Engineering", "IT",  "Manufacturing/Industrial", "Promotion/Events","Real Estate","Retail", "Sales", "Travel/Tourism" ]
  let sectorPickerView = UIPickerView()
  
  
  let jobObj = PFObject(className: ParseInterface.sharedInstance.databaseClassName)
  
  
  var hud = MBProgressHUD()
  var dataIsSaved = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initViewController()
    
    
  }
  func initViewController() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    
    
    tpScrollView.contentSize.height = 820
    // Date Picker for Due Date
    datePickerView.datePickerMode = UIDatePickerMode.Date
    datePickerView.backgroundColor = UIColor.whiteColor()
    datePickerTextField.inputView = datePickerView
    datePickerView.addTarget(self, action: "getDate:", forControlEvents: UIControlEvents.ValueChanged)
    
    // Location Picker for Work At
    workAtPickerView.delegate = self
    workAtPickerView.backgroundColor = UIColor.whiteColor()
    workAtPickerTextField.inputView = workAtPickerView
    
    jobTypePickerView.delegate = self
    jobTypePickerView.backgroundColor = UIColor.whiteColor()
    jobTypePickerTextField.inputView = jobTypePickerView
    
    sectorPickerView.delegate = self
    sectorPickerView.backgroundColor = UIColor.whiteColor()
    sectorPickerTextField.inputView = sectorPickerView

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
    
  }
  
  @IBAction func employerNameChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["employerName"] = sender.text
    } else {
      jobObj["employerName"] = "NA"
    }
  }
  
  @IBAction func employerAddressChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["employerAddress"] = sender.text
    } else {
      jobObj["employerAddress"] = "NA"
    }
  }
  
  @IBAction func employerEmailChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["employerEmail"] = sender.text
    } else {
      jobObj["employerEmail"] = "NA"
    }
  }
  
  @IBAction func employerPhoneChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["employerPhone"] = sender.text
    } else {
      jobObj["employerPhone"] = "NA"
    }
  }
  
  @IBAction func jobTitleChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["jobTitle"] = sender.text
    } else {
      jobObj["jobTitle"] = "NA"
    }
  }
  
  @IBAction func jobSalaryChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["salary"] = sender.text
    } else {
      jobObj["salary"] = "NA"
    }
  }
  
  @IBAction func workAtChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["workAt"] = sender.text
    } else {
      jobObj["workAt"] = "NA"
    }
  }
  
  @IBAction func dueDateChanged(sender: UITextField) {
    var date = NSDate()
    let dateformatter = NSDateFormatter()
    dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

    if (sender.text != "") {
      date = dateformatter.dateFromString(sender.text!)!
      jobObj["dueDate"] = date
    } else {
      let dateNow = NSDate()
      jobObj["dueDate"] = dateNow.dateByAddingTimeInterval(60*60*24*30) // auto add 30 days from now
      datePickerTextField.text = dateformatter.stringFromDate(dateNow.dateByAddingTimeInterval(60*60*24*30))
    }
  }
  
  func getDate(sender: UIDatePicker) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss" // "dd/MM/yyyy"
    datePickerTextField.text = dateFormatter.stringFromDate(sender.date)
    
  }
  
  @IBAction func jobTypeChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["jobType"] = sender.text
    } else {
      jobObj["jobType"] = "NA"
    }
  }
  
  @IBAction func sectorChanged(sender: UITextField) {
    if sender.text != nil {
      jobObj["jobSector"] = sender.text
    } else {
      jobObj["jobSector"] = "NA"
    }
  }
  
  func saveNewJob() {
    jobObj["jobStatus"] = "Open" // Status of new job is open
    jobObj["createdBy"] = PFUser.currentUser() // Add the user to the job 
    jobObj["jobDescription"] = jobDescriptionText.text
    jobObj.saveInBackgroundWithBlock({
      (success: Bool, error: NSError?) -> Void in
      
      if error == nil {
        /**success saving, Now save image.***/
        
        //create an image data
        let imageData = UIImagePNGRepresentation(self.profilePhoto.image!)
        //create a parse file to store in cloud
        let parseImageFile = PFFile(name: "profile_image.png", data: imageData!)
        self.jobObj["profilePhoto"] = parseImageFile
        self.jobObj.saveInBackgroundWithBlock({
          (success: Bool, error: NSError?) -> Void in
          if error == nil {
            //take user home
            print("data uploaded")
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.dataIsSaved = true
            if self.dataIsSaved {
              self.navigationController?.popToRootViewControllerAnimated(true)
              jobIsUpdated = -1
            }
          }else {
            print(error)
          }
        }) // saveInBackgroundWithBlock - save image - End
      }else {
        print(error)
      }
    }) // saveInBackgroundWithBlock - save obj - End
    
  }
  
  
  
  @IBAction func TapToTakePhoto(sender: UITapGestureRecognizer) {
    
    locationManager.startUpdatingLocation() // Get location
    // Alert to select photo source
    let sourceAlert = UIAlertController(title: "GET A PROFILE PHOTO", message: "Please select a photo source", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
      }
    } // cameraAction-End
    let libraryAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      self.presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
      print("Cancel Button Pressed")
    })

    sourceAlert.addAction(cameraAction)
    sourceAlert.addAction(libraryAction)
    sourceAlert.addAction(cancel)
    
    presentViewController(sourceAlert, animated: true, completion: nil)
    
    
  }
  
  func updateUserCurrentLocation(userLocation: CLLocation) {
    self.currentLocation = userLocation
    
    let geopoint = PFGeoPoint()
    geopoint.latitude = currentLocation.coordinate.latitude
    geopoint.longitude = currentLocation.coordinate.longitude
    jobObj["location"] = geopoint
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
          self.employerAddressText.text = addr
          self.jobObj["employerAddress"] = addr
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
} // AddJobViewController - End


extension AddJobViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == workAtPickerView {
      return workAtList.count
    } else if pickerView == jobTypePickerView {
      return jobTypeList.count
    } else if pickerView == sectorPickerView {
      return sectorList.count
    }else {
      return 0
    }
  }
  
  
  
  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var attributedString: NSAttributedString!
    
    
    if pickerView == workAtPickerView {
      attributedString = NSAttributedString(string: workAtList[row], attributes: [NSForegroundColorAttributeName : UIColor.blueColor()])
    } else if pickerView == jobTypePickerView {
      attributedString = NSAttributedString(string: jobTypeList[row], attributes: [NSForegroundColorAttributeName : UIColor.blueColor()])
    } else if pickerView == sectorPickerView {
      attributedString = NSAttributedString(string: sectorList[row], attributes: [NSForegroundColorAttributeName : UIColor.blueColor()])
    }else {
      attributedString = nil
    }
    return attributedString
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == workAtPickerView {
      workAtPickerTextField.text = workAtList[row]
      
    } else if pickerView == jobTypePickerView  {
      jobTypePickerTextField.text = jobTypeList[row]
      
    } else if pickerView == sectorPickerView  {
      sectorPickerTextField.text = sectorList[row]
      
    }
  }
} // Picker externsion - End

// MARK: Image picker protocol

extension AddJobViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let editedImage = info[UIImagePickerControllerEditedImage]as! UIImage
    photo = editedImage
    profilePhoto.image = editedImage
    locationManager.stopUpdatingLocation()
    
    picker.dismissViewControllerAnimated(true) { () -> Void in
      print("Image was captured")
      
    }
    
  }
} // extension - end

// MARK: LocationManager protocol

extension AddJobViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let currentLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(currentLocation)
    self.getAddressFromLocation(currentLocation)
    locationManager.stopUpdatingLocation()
    
  }
} // extension - end

extension AddJobViewController: UITextViewDelegate {
  
  func textViewDidEndEditing(textView: UITextView) {
    jobObj["jobDescription"] = textView.text
  }
}
