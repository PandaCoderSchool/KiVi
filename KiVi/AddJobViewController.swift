//
//  AddJobViewController.swift
//  KiVi
//
//  Created by Dan Tong on 9/28/15.
//  Copyright © 2015 Dan Tong. All rights reserved.
//

import UIKit

import MBProgressHUD
import Parse

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
    datePickerView.datePickerMode = UIDatePickerMode.date
    datePickerView.backgroundColor = UIColor.white
    datePickerTextField.inputView = datePickerView
    datePickerView.addTarget(self, action: #selector(AddJobViewController.getDate(_:)), for: UIControlEvents.valueChanged)
    
    // Location Picker for Work At
    workAtPickerView.delegate = self
    workAtPickerView.backgroundColor = UIColor.white
    workAtPickerTextField.inputView = workAtPickerView
    
    jobTypePickerView.delegate = self
    jobTypePickerView.backgroundColor = UIColor.white
    jobTypePickerTextField.inputView = jobTypePickerView
    
    sectorPickerView.delegate = self
    sectorPickerView.backgroundColor = UIColor.white
    sectorPickerTextField.inputView = sectorPickerView

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func saveAllInfo(_ sender: UIButton) {
    dataIsSaved = false
    self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
    self.hud.mode = MBProgressHUDMode.indeterminate
    self.hud.labelText = "Saving your data to server..."
    
    saveNewJob()
    
  }
  
  @IBAction func employerNameChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["employerName"] = sender.text
    } else {
      jobObj["employerName"] = "NA"
    }
  }
  
  @IBAction func employerAddressChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["employerAddress"] = sender.text
    } else {
      jobObj["employerAddress"] = "NA"
    }
  }
  
  @IBAction func employerEmailChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["employerEmail"] = sender.text
    } else {
      jobObj["employerEmail"] = "NA"
    }
  }
  
  @IBAction func employerPhoneChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["employerPhone"] = sender.text
    } else {
      jobObj["employerPhone"] = "NA"
    }
  }
  
  @IBAction func jobTitleChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["jobTitle"] = sender.text
    } else {
      jobObj["jobTitle"] = "NA"
    }
  }
  
  @IBAction func jobSalaryChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["salary"] = sender.text
    } else {
      jobObj["salary"] = "NA"
    }
  }
  
  @IBAction func workAtChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["workAt"] = sender.text
    } else {
      jobObj["workAt"] = "NA"
    }
  }
  
  @IBAction func dueDateChanged(_ sender: UITextField) {
    var date = Date()
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

    if (sender.text != "") {
      date = dateformatter.date(from: sender.text!)!
      jobObj["dueDate"] = date
    } else {
      let dateNow = Date()
      jobObj["dueDate"] = dateNow.addingTimeInterval(60*60*24*30) // auto add 30 days from now
      datePickerTextField.text = dateformatter.string(from: dateNow.addingTimeInterval(60*60*24*30))
    }
  }
  
  func getDate(_ sender: UIDatePicker) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss" // "dd/MM/yyyy"
    datePickerTextField.text = dateFormatter.string(from: sender.date)
    
  }
  
  @IBAction func jobTypeChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["jobType"] = sender.text
    } else {
      jobObj["jobType"] = "NA"
    }
  }
  
  @IBAction func sectorChanged(_ sender: UITextField) {
    if sender.text != nil {
      jobObj["jobSector"] = sender.text
    } else {
      jobObj["jobSector"] = "NA"
    }
  }
  
  func saveNewJob() {
    jobObj["jobStatus"] = "Open" // Status of new job is open
    jobObj["createdBy"] = PFUser.current() // Add the user to the job 
    jobObj["jobDescription"] = jobDescriptionText.text
    jobObj.saveInBackground(block: {
      (success: Bool, error: NSError?) -> Void in
      
      if error == nil {
        /**success saving, Now save image.***/
        
        //create an image data
        let imageData = UIImagePNGRepresentation(self.profilePhoto.image!)
        //create a parse file to store in cloud
        let parseImageFile = PFFile(name: "profile_image.png", data: imageData!)
        self.jobObj["profilePhoto"] = parseImageFile
        self.jobObj.saveInBackground(block: {
          (success: Bool, error: NSError?) -> Void in
          if error == nil {
            //take user home
            print("data uploaded")
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.dataIsSaved = true
            if self.dataIsSaved {
              jobIsUpdated = -1
              self.navigationController?.popToRootViewController(animated: true)
              
            }
          }else {
            print(error)
          }
        } as! PFBooleanResultBlock) // saveInBackgroundWithBlock - save image - End
      }else {
        print(error)
      }
    } as! PFBooleanResultBlock) // saveInBackgroundWithBlock - save obj - End
    
  }
  
  
  
  @IBAction func TapToTakePhoto(_ sender: UITapGestureRecognizer) {
    
    locationManager.startUpdatingLocation() // Get location
    // Alert to select photo source
    let sourceAlert = UIAlertController(title: "GET A PROFILE PHOTO", message: "Please select a photo source", preferredStyle: UIAlertControllerStyle.actionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action) -> Void in
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.present(self.imagePicker, animated: true, completion: nil)
      }
    } // cameraAction-End
    let libraryAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.default) { (action) -> Void in
      self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
      print("Cancel Button Pressed")
    })

    sourceAlert.addAction(cameraAction)
    sourceAlert.addAction(libraryAction)
    sourceAlert.addAction(cancel)
    
    present(sourceAlert, animated: true, completion: nil)
    
    
  }
  
  func updateUserCurrentLocation(_ userLocation: CLLocation) {
    self.currentLocation = userLocation
    
    let geopoint = PFGeoPoint()
    geopoint.latitude = currentLocation.coordinate.latitude
    geopoint.longitude = currentLocation.coordinate.longitude
    jobObj["location"] = geopoint
  }
  
  func getAddressFromLocation(_ location: CLLocation) {
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
    } as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler as! CLGeocodeCompletionHandler
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
    
  }
  
  func textFieldShouldReturn (_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
    
  }
} // AddJobViewController - End


extension AddJobViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
  
  
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var attributedString: NSAttributedString!
    
    
    if pickerView == workAtPickerView {
      attributedString = NSAttributedString(string: workAtList[row], attributes: [NSForegroundColorAttributeName : UIColor.blue])
    } else if pickerView == jobTypePickerView {
      attributedString = NSAttributedString(string: jobTypeList[row], attributes: [NSForegroundColorAttributeName : UIColor.blue])
    } else if pickerView == sectorPickerView {
      attributedString = NSAttributedString(string: sectorList[row], attributes: [NSForegroundColorAttributeName : UIColor.blue])
    }else {
      attributedString = nil
    }
    return attributedString
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let editedImage = info[UIImagePickerControllerEditedImage]as! UIImage
    photo = editedImage
    profilePhoto.image = editedImage
    locationManager.stopUpdatingLocation()
    
    picker.dismiss(animated: true) { () -> Void in
      print("Image was captured")
      
    }
    
  }
} // extension - end

// MARK: LocationManager protocol

extension AddJobViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let currentLocation: CLLocation = locations.last!
    self.updateUserCurrentLocation(currentLocation)
    self.getAddressFromLocation(currentLocation)
    locationManager.stopUpdatingLocation()
    
  }
} // extension - end

extension AddJobViewController: UITextViewDelegate {
  
  func textViewDidEndEditing(_ textView: UITextView) {
    jobObj["jobDescription"] = textView.text
  }
}
