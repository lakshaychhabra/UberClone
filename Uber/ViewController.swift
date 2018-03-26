//
//  ViewController.swift
//  Uber
//
//  Created by Lakshay Chhabra on 24/03/18.
//  Copyright © 2018 Lakshay Chhabra. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {

    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var riderDriverSwitch: UISwitch!
    @IBOutlet var topButton: UIButton!
    @IBOutlet var bottomButton: UIButton!
    
    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var driverLabel: UILabel!
    
    var signupMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func topTapped(_ sender: Any) {
        
        if email.text == "" || password.text == "" {
            
            displayAlert(title: "Missing Info", message: "Must Enter Email and Password")
            
        }
        else {
            if let email = email.text {
                if let password = password.text {
                    
                    if signupMode {
                        //sign up
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            
                            if error != nil {
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else {
                                print("Sign Up Success")
                                
                                if self.riderDriverSwitch.isOn {
                                    //DRIVER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                }else {
                                    //Rider
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                     self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                
                                
                            }
                            
                        })
                        
                    }else{
                        //log in
                        
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                            
                            if error != nil {
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }else {
                                print("LogIn Up Success")
                                
                                if user?.displayName == "Driver" {
                                 print("Driver")
                              self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                }else{
                                    //Rider
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                    
                                }
                            }
                        })
                        
                    }

                }
            }
            
            
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    @IBAction func bottomTapped(_ sender: Any) {
        
        if signupMode {
            
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signupMode = false
            
            
            
        } else {
            
          
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signupMode = true
        }
        
    }
    
    
}

