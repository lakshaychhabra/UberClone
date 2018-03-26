//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Lakshay Chhabra on 25/03/18.
//  Copyright © 2018 Lakshay Chhabra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
            if let driverLat = rideRequestDictionary["driverLat"] as? Double {
               
                
            }else {
                self.rideRequests.append(snapshot)
                self.tableView.reloadData()
                }
            }
            
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
                self.tableView.reloadData()
        }

     
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
              driverLocation = coord
            
        }
        
        
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return rideRequests.count
    }
    @IBAction func logoutPressed(_ sender: Any) {
   
        try?  Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
            
            if let email = rideRequestDictionary["email"] as? String{
                
                if let lat = rideRequestDictionary["lat"] as? Double {
                    if let lon = rideRequestDictionary["lon"] as? Double {
                        
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = driverCLLocation.distance(from: riderCLLocation)
                        let roundedDistance = round(distance * 100)/100
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance) km away"
                        
                    }
                }
            }
         
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                    
                    if let email = rideRequestDictionary["email"] as? String{
                        
                        if let lat = rideRequestDictionary["lat"] as? Double {
                            if let lon = rideRequestDictionary["lon"] as? Double {
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    acceptVC.requestLocation = location
                                    acceptVC.requestEmail = email
                                    acceptVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
            }
        }
    }
    
}
