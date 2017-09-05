//
//  RegistrationViewController.swift
//  Observer-Assist
//
//  Created by admin on 9/4/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Alamofire

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var keyField: UITextField!
    
    var pickGender = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initPicker()
        /*self.isScroll = true
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
        */
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
    
    func displayConfirmation(message: String) {
        
        let confirmationAlert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        
        present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        gender.text = "Male"
        
        gender.resignFirstResponder()
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        gender.resignFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickGender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickGender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender.text = pickGender[row]
    }
    
    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        gender.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RegistrationViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(RegistrationViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick the patient's gender"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        gender.inputAccessoryView = toolBar
    }
    
    

    @IBAction func registerUser(_ sender: Any) {
        //if(countElements(txtFName.text) == 0){
        if (self.txtFName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter your first name.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if (self.txtLName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {//(countElements(txtLName.text) == 0){
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter your last name.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } /*else if ((self.age.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
             var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Age should not be empty.",
             delegate: nil, cancelButtonTitle: "OK")
             alert.show()
             
         } */else if (!(self.age.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !self.isValidAge(testStr: self.age.text!)) {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Value should be a number and cannot be more than 99.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }/* else if (self.gender.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
             var alert : UIAlertView = UIAlertView(title: "Oops!", message: "gender cannot be empty.",
             delegate: nil, cancelButtonTitle: "OK")
             alert.show()
         }*/else if (self.userName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! { //(countElements(txtEmailID.text) == 0){
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter your email id.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }else if !isValidEmail(testStr: self.userName.text!){
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Username length should be atleast 5. Include only small case alphabets. Avoid spaces (especially at end).",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }else if (self.txtPassword.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! { //(countElements(txtPassword.text) == 0){
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter your password.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if !(self.isPasswordValid(password: (self.txtPassword?.text)!)) {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Password length should be atleast 8. Include One Alphabet, One digit and One Special Character in Password.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else if ((self.txtConfirmPassword.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.txtConfirmPassword.text?.characters.count != self.txtPassword.text?.characters.count && self.txtConfirmPassword.text != self.txtPassword.text)) {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Confirmed password not matched please try again.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if (self.keyField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! { //(countElements(txtPassword.text) == 0){
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter the key.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if !(self.isPasswordValid(password: (self.keyField?.text)!)) {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "key length should be atleast 8. Include One Alphabet, One digit and One Special Character.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else{
            /*var alert : UIAlertView = UIAlertView(title: "User Registration!", message: "Your Registration is successfully.",
             delegate: nil, cancelButtonTitle: "OK")
             alert.show()*/
            var isResponseSuccess: Bool?
            
            self.txtFName.text = self.txtFName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.txtLName.text = self.txtLName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.userName.text = self.userName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let fullName = self.txtFName.text! + " " + self.txtLName.text!
            
            var genderText = ""
            if (self.gender.text! == "Male") {
                genderText = "m"
            } else if (self.gender.text! == "Female") {
                genderText = "f"
            }
            
            var ageText = ""
            if (self.age.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != nil) {
                ageText = self.age.text!
            }
            
            let parameters: Parameters = ["username": self.userName.text!, "full_name": fullName, "gender": genderText, "age": ageText, "password": self.txtPassword.text!, "role": "observer", "keyField": self.keyField.text!]
            print(parameters)
            Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/registerNewUser.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
                DispatchQueue.main.async(execute: {
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                        if (utf8Text.range(of:"username exists") != nil) {
                            self.displayAlertMessage(message: "username exists. Try a different one")
                            isResponseSuccess = false
                        } else if (utf8Text.range(of:"invalid key") != nil) {
                            self.displayAlertMessage(message: "entered invalid key")
                            isResponseSuccess = false
                        } else if (utf8Text.range(of:"success") != nil) {
                            self.displayConfirmation(message: "You are registered :)")
                            isResponseSuccess = true
                            
                        } else {
                            // Perform ACTION
                            self.displayAlertMessage(message: "Something went wrong :(")
                            isResponseSuccess = false
                        }
                        
                    } else {
                        self.displayAlertMessage(message: "Server response is empty")
                        isResponseSuccess = false
                    }
                    
                })
            }
            
        }
        
        
        
    }
    
    
    
    @IBAction func clearFields(_ sender: Any) {
        self.txtFName.text = nil
        self.txtLName.text = nil
        self.userName.text = nil
        self.txtPassword.text = nil
        self.txtConfirmPassword.text = nil
        self.age.text = nil
        self.gender.text = nil
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if(textField.returnKeyType == UIReturnKeyType.done)
        {
            textField .resignFirstResponder()
        }
        else
        {
            var txtFld : UITextField? = self.view.viewWithTag(textField.tag + 1) as? UITextField;
            txtFld?.becomeFirstResponder()
        }
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?=.*[a-z])[a-z$]{5,}"//"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func isValidAge(testStr: String) -> Bool {
        let ageRegEx = "^(?=.*[1-9])[0-9]{1,2}"//"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        var ageTest = NSPredicate(format:"SELF MATCHES %@", ageRegEx)
        let result = ageTest.evaluate(with: testStr)
        
        return result
    }
    
    func isPasswordValid(password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[$@$#!%*?&])[A-Za-z0-9\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

    

}
