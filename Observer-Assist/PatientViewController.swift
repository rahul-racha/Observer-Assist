//
//  PatientViewController.swift
//  Observer-Assist
//
//  Created by admin on 9/2/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Alamofire

class PatientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,NSURLConnectionDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    let cellSpacingHeight: CGFloat = 15
    var selectedPatient: [String:Any]?
    var pickOption = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        //Manager.reloadAllCells = true
        self.loadPatientDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func refresh(_ sender: Any) {
        self.loadPatientDetails()
    }
    
    func loadPatientDetails() {
        if let userid = Manager.userData?["id"] as? String, let role = Manager.userData?["role"] as? String {
        //if (Manager.reloadAllCells == true) {
            // Do any additional setup after loading the view, typically from a nib.
            let parameters: Parameters = ["user_id": userid, "role": role]
            Alamofire.request("http://qav2.cs.odu.edu/Dev_AggressionDetection/getPatientDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        print(json["patient_details"])
                        Manager.patientDetails = json["patient_details"] as? [Dictionary<String,Any>]
                        self.pickOption = json["locations"] as! [String]
                        self.pickOption.sort()
                        //self.locationList = json["locations"] as! [String]
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                    }
                    catch{
                        //print("error serializing JSON: \(error)")
                    }
                }
            }
        //}
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if(Manager.patientDetails == nil) {
            return 0
        }
        return Manager.patientDetails!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    //}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientTableViewCell", for: indexPath) as! PatientTableViewCell
        if(Manager.patientDetails != nil) {
            print("index:\(indexPath)")
            print("section indx:\(indexPath.section)")
            
            print("id:\(Manager.patientDetails?[indexPath.section]["id"])")
            cell.patientName.text = Manager.patientDetails?[indexPath.section]["name"] as? String
            cell.patientName.textColor = UIColor.white
            cell.view.backgroundColor = UIColor(red: 0.502, green: 0.000, blue: 0.251, alpha: 1)
            //cell.layer.cornerRadius = 5.0
            //cell.layer.borderWidth = 3.0
            //cell.layer.borderColor = UIColor.black.cgColor
            //cell.view.backgroundColor = UIColor.white
            cell.clipsToBounds = true
            
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //var m: String? = "23"
        if let _ = Manager.userData?["id"] as? String {
            self.selectedPatient = Manager.patientDetails?[indexPath.section]
            if (selectedPatient != nil) {
                let obsVC = storyboard?.instantiateViewController(withIdentifier: "ObserverViewController") as! ObserverViewController
                obsVC.selectedPatient = self.selectedPatient
                obsVC.pickOption = self.pickOption
                self.navigationController?.pushViewController(obsVC, animated: true)
            }
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
    Manager.triggerNotifications = false
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let loginViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
    UIApplication.shared.keyWindow?.rootViewController = loginViewController
    self.dismiss(animated: true, completion: nil)
    self.present(loginViewController, animated: true, completion: nil)

    }

}
