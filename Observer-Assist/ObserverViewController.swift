//
//  ObserverViewController.swift
//  Observer-Assist
//
//  Created by admin on 9/3/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Alamofire

class ObserverViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
   
    enum AGITATION {
        case stable
        case partiallyaggressive
        case aggressive
        case unknown
    }
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var agitationSlider: UISlider!
    
    @IBOutlet weak var agiScoreLabel: UILabel!
    @IBOutlet weak var runningTime: UILabelX!
    @IBOutlet weak var stopAction: UIButtonX!
    
    
    
    var selectedPatient: [String:Any]?
    var pickOption = [String]()
    var agiStatus: AGITATION = AGITATION.unknown
    var agiScaleMap: [AGITATION: String] = [AGITATION.stable: "stable", AGITATION.partiallyaggressive: "slightly agitated", AGITATION.aggressive: "agitated", AGITATION.unknown: "unknown"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedPatient)
        self.configDetails()
        self.stopAction.isHidden = true
        self.runningTime.isHidden = true
        
        self.updateTime()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        let doubleTapPulse = UITapGestureRecognizer(target: self, action: #selector(ObserverViewController.agitationSliderTapped(_:)))
        doubleTapPulse.numberOfTapsRequired = 2
        self.agitationSlider.addGestureRecognizer(doubleTapPulse)
        
        self.initSliders(s:0)
        self.initPicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func displayConfirmation(message: String, recordedTime: String, type: String) {
        
        let confirmationAlert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.sendObservation(isStableClick: "false", recordedTime: recordedTime, type: type)
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(confirmationAlert, animated: true, completion: nil)
        
    }

    func configDetails() {
        self.name.text = self.selectedPatient!["name"] as! String
        self.age.text = "\(self.selectedPatient!["age"] as! String)"
        self.gender.text = (self.selectedPatient!["gender"] as! String) == "m" ? "male":"female"
    }
    
    
    func changePatientDetails(modifiedPatient: [String: Any]) {
        if (Manager.patientDetails != nil) {
            for i in 0..<(Manager.patientDetails?.count)! {
                if (String(describing: Manager.patientDetails?[i]["id"]) == String(describing: modifiedPatient["id"])) {
                    Manager.patientDetails?[i]["location"] = modifiedPatient["location"] as? String
                    break
                }
            }
            if (self.selectedPatient != nil) {
                if (String(describing: self.selectedPatient?["id"]) == String(describing:modifiedPatient["id"])) {
                    self.selectedPatient?["location"] = modifiedPatient["location"] as? String
                    self.locationTextField.text = modifiedPatient["location"] as! String
                    print("whats in picker? \(self.locationTextField.text)")
                    
                }
            }
        }
    }
    
    
    func updateTime() {
        self.runningTime.text = self.getTimestamp(forDisplay: true)
    }
    
    func initSliders(s: Int) {
        self.agitationSlider.value = Float(s)
        self.getSliderStatus()
    }
    
    func agitationSliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        //self.holdPulseTap = true
        if (self.stopAction.isHidden == true) {
        self.updateSlider()
        } else {
            self.displayAlertMessage(message: "Stop the current action before moving the slider")
        }
    }
    
    @IBAction func updateAgitationAction(_ sender: Any) {
        
        if (self.stopAction.isHidden == true) {
            self.updateSlider()
        } else {
            self.displayAlertMessage(message: "Stop the current action before moving the slider")
        }

    }
    
    func updateSlider() {
        let recordedTime = self.getTimestamp(forDisplay: false)
        self.getSliderStatus()
        let wait = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: wait) {
        self.displayActions(recordedTime: recordedTime)
        }
    }
    
    func displayActions(recordedTime: String) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let continuousAction = UIAlertAction(title: "Continuous Action", style: .default) { (action) in
            print("ACTION:\(self.agiStatus)")
            self.sendObservation(isStableClick: "false", recordedTime: recordedTime, type: "continuous")
        }
        let singleAction = UIAlertAction(title: "Single Action", style: .default) { (action) in
            print("ACTION:\(self.agiStatus)")
            self.sendObservation(isStableClick: "false", recordedTime: recordedTime, type: "single")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(continuousAction)
        alertController.addAction(singleAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func getSliderStatus() {
        self.agitationSlider.value = roundf(self.agitationSlider.value)
        if (self.agitationSlider.value == 0) {
            self.agitationSlider.thumbTintColor = UIColor.green
            self.agitationSlider.minimumTrackTintColor = UIColor.green
            self.agiStatus = AGITATION.stable
            //self.agiScoreLabel.textColor = UIColor.green
        } else if (self.agitationSlider.value == 1) {
            self.agitationSlider.thumbTintColor = UIColor.orange
            self.agitationSlider.minimumTrackTintColor = UIColor.orange
            self.agiStatus = AGITATION.partiallyaggressive
            //self.agiScoreLabel.textColor = UIColor.orange
        } else if (self.agitationSlider.value == 2) {
            self.agitationSlider.thumbTintColor = UIColor.red
            self.agitationSlider.minimumTrackTintColor = UIColor.red
            self.agiStatus = AGITATION.aggressive
            //self.agiScoreLabel.textColor = UIColor.red
        } else {
            self.agitationSlider.thumbTintColor = UIColor.gray
            self.agitationSlider.minimumTrackTintColor = UIColor.lightGray
            self.agiStatus = AGITATION.unknown
            //self.agiScoreLabel.textColor = UIColor.white
        }
        self.agiScoreLabel.text = self.agiScaleMap[self.agiStatus]
    }
    
    func getTimestamp(forDisplay: Bool = false) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        if (forDisplay) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        }
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let _ = date.timeIntervalSince1970
        return dateString
    }
    
    @IBAction func stopBehaviour(_ sender: Any) {
        let recordedTime = self.getTimestamp(forDisplay: false)
        self.displayConfirmation(message:"Click OK to stop the action", recordedTime: recordedTime, type: "stop")
    }
    
    func displayVanishingAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    //*********************
    
    func sendObservation(isStableClick: String, recordedTime: String, type: String) -> Bool? {
    var result: Bool?
    
    print("status:\(self.agiStatus)")
    
        if (self.selectedPatient?["id"] as? String != nil && Manager.userData?["id"] as? String != nil) {
    let parameters: Parameters = ["patient_id": self.selectedPatient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": recordedTime, "status": self.agiScaleMap[self.agiStatus] ?? "unknown", "stable_click": isStableClick, "type": type]
    print("here para: \(parameters)")
    Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObserverData.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
    DispatchQueue.main.async(execute: {
    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
    print("Data: \(utf8Text)")
    if utf8Text.range(of:"success") != nil{
    self.displayVanishingAlert(message: "Success!")
        result = true
    } else {
    // Perform ACTION
    self.displayAlertMessage(message: " :( Something went wrong - Check your internet connection.")
    result = false
    }
    
    } else {
    self.displayAlertMessage(message: "Server response is empty.")
    result = false
    }
        //result = true
        if (result! == true) {
        if (type == "continuous") {
            self.stopAction.isHidden = false
            self.runningTime.isHidden = false
        } else if (type == "single") {
            self.stopAction.isHidden = true
            self.runningTime.isHidden = true
        } else if (type == "stop") {
            self.stopAction.isHidden = true
            self.runningTime.isHidden = true
        }
        }
    })
    }
        
    /*
    print("pat: \(patient!["id"] as! String)")
    print("obs: \(Manager.userData!["id"] as! String)")
    let parameters2: Parameters = ["patient_id": patient!["id"] as! String, "observer_id": Manager.userData!["id"] as! String, "start_time": timestamp, "location": self.pickerTextField.text!, "stable_click": isStableClick]
    Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/storeObservedLocation.php",method: .post,parameters: parameters2, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/string"])*/.responseData { response in
    DispatchQueue.main.async(execute: {
    
    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
    print("Data: \(utf8Text)")
    if utf8Text.range(of:"success") != nil{
    self.displayAlertMessage(message: "Submitted :)")
    } else {
    // Perform ACTION
    self.displayAlertMessage(message: "Location not updated :(")
    result = false
    }
    
    } else {
    self.displayAlertMessage(message: "Server response is empty")
    result = false
    }
    
    })
    }
    */
        } else {
            self.displayAlertMessage(message: "Patient Id/ Observer Id is empty")
        }
    return result
    }
    
    
    //*********************
    
    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        locationTextField.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ObserverViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ObserverViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 11)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Select patient's location"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        locationTextField.inputAccessoryView = toolBar
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        locationTextField.resignFirstResponder()
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        locationTextField.text = "Town Center"
        
        locationTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationTextField.text = pickOption[row]
    }

}
