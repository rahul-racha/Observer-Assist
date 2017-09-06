//
//  ViewController.swift
//  Observer-Assist
//
//  Created by admin on 8/31/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var _username: UITextField!
    @IBOutlet weak var _password: UITextField!
    @IBOutlet weak var rememberCredentials: UISwitch!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var isScroll: Bool?

    
    var keyChainUser: String?
    var keyChainPwd: String?
    var isUsrSaved:Bool = false
    var isPwdSaved:Bool = false
    var isUsrRemoved:Bool = true
    var isPwdRemoved:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Manager.triggerNotifications = false
        self.isScroll = true
        keyChainUser = KeychainWrapper.standard.string(forKey: "username")
        if(keyChainUser != nil) {
            _username?.text = keyChainUser!
            print(keyChainUser)
        }
        keyChainPwd = KeychainWrapper.standard.string(forKey: "password")
        if(keyChainPwd != nil) {
            _password?.text = keyChainPwd!
            print(keyChainPwd)
        }
        rememberCredentials.addTarget(self, action: #selector(setWhenStateChanged(_:)), for: UIControlEvents.valueChanged)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
 
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

    }

    
    func keyboardWillShow(notification: NSNotification) {
        if (self.isScroll == true) {
            adjustHeight(show: true, notification: notification)
            self.isScroll = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.isScroll == false) {
            adjustHeight(show: false, notification: notification)
            self.isScroll = true
        }
    }
    
    func adjustHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
            //if self.viewBox.frame.origin.y == 0{
            //self.viewBox.frame.origin.y += changeInHeight
            //}
        })
    }

    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }


    func setWhenStateChanged(_ sender:UISwitch!) {
        if(sender.isOn == false) {
            self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
            self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
        }
        
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func login(_ sender: Any) {
        var username = _username?.text
        var password = _password?.text
        var user: String?
        
        if (username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            print(username)
            print(password)
            displayAlertMessage(message: "All fields are required")
            //self._username?.placeholder = "username"
            //self._password?.placeholder = "password"
            return
        }
        
        username = username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        password = password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        
        let parameters: Parameters = ["user_name":username! , "password": password!, "device_id": Manager.deviceId == nil ? "abc" : Manager.deviceId!, "device_type": "apple"]
        Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/login.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                debugPrint("All Response Info: \(response)")
                
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    
                    print("Data: \(utf8Text)")
                    print("After data")
                    if let dict = self.convertToDictionary(text: utf8Text) {
                        print(dict as Any)
                        let userFromData = (dict["name"] as! String)
                        if !userFromData.isEmpty {
                            print(userFromData as Any)
                            user = userFromData
                        }
                        
                        
                        print("user from dict:\(String(describing: user))")
                        
                        if user != nil,user! == username! {
                            
                            if(/*self.keyChainUser != nil && */self.rememberCredentials.isOn == true) {
                                self.isUsrSaved = KeychainWrapper.standard.set(user!, forKey: "username")
                                
                                let retrievedUsername: String? = KeychainWrapper.standard.string(forKey: "username")
                                if (retrievedUsername != nil) {
                                    self.keyChainUser = retrievedUsername!
                                }
                                self.isPwdSaved = KeychainWrapper.standard.set(password!, forKey: "password")
                                let retrievedPwd: String? = KeychainWrapper.standard.string(forKey: "password")
                                if(retrievedPwd != nil) {
                                    self.keyChainPwd = retrievedPwd!
                                }
                                
                            }
                            else if(self.rememberCredentials.isOn == false) {
                                self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
                                self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
                            }
                            
                            Manager.userData = dict
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            let pVC = storyboard.instantiateViewController(withIdentifier: "PatientViewController") as! PatientViewController
                            //UIApplication.shared.keyWindow?.rootViewController = pVC
                            Manager.triggerNotifications = true
                            let nVC = UINavigationController(rootViewController: pVC)
                            self.present(nVC, animated:true, completion: nil)
                            
                            
                        }
                        else {
                            self.displayAlertMessage(message: "Invalid username or password")
                            self._username?.text = nil
                            self._password?.text = nil
                        }
                    }
                    else {
                        self.displayAlertMessage(message: "Response data is empty. Check your Internet Connection.")
                        self._username?.text = nil
                        self._password?.text = nil
                    }
                    
                }
                else {
                    self.displayAlertMessage(message: "response data is empty. Check your Internet Connection.")
                    self._username?.text = nil
                    self._password?.text = nil
                }
        }

    }
    

}

