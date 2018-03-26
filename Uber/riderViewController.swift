//
//  riderViewController.swift
//  Uber
//
//  Created by Lakshay Chhabra on 25/03/18.
//  Copyright © 2018 Lakshay Chhabra. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth


class riderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var callAnUberLabel: UIButton!
    @IBOutlet var map: MKMapView!
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                
                self.uberHasBeenCalled = true
                self.callAnUberLabel.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email {
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                    
                                    if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                                        if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                                
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                                
                                            }
                                            
                                        }
                                    }
                                })
                            } 
                        }
                        
                    }
                }
                
                
                
            })
            
            
        }
        
        
    }
    func displayDriverAndRider(){
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation)
        let roundedDistance = round(distance * 100)/100
        callAnUberLabel.setTitle("Your Driver is \(roundedDistance) km away", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latDelta = (driverLocation.latitude - userLocation.latitude) * 2 + 0.05
        let lonDelta = (driverLocation.longitude - userLocation.longitude) * 2 + 0.05
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        
        map.setRegion(region, animated: true)
        
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your location"
        map.addAnnotation(riderAnno)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        
        driverAnno.title = "Driver location"
        map.addAnnotation(driverAnno)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            
            
            if uberHasBeenCalled {
                
                displayDriverAndRider()
                
            }
            else{
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations )
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
            }
            
            
        }
    }
    
    @IBAction func callAnUberButton(_ sender: Any) {
        if !driverOnTheWay {
            if let email = Auth.auth().currentUser?.email {
                
                if uberHasBeenCalled {
                    uberHasBeenCalled = false
                    callAnUberLabel.setTitle("Call an Uber", for: .normal)
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshots) in
                        
                        snapshots.ref.removeValue()
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    })
                    
                    
                } else {
                    let rideRequestDictionary : [String : Any] = ["email" : email, "lat" : userLocation.latitude , "lon" : userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    uberHasBeenCalled = true
                    callAnUberLabel.setTitle("Cancel Uber", for: .normal)
                    
                }
                
                
                
                
            }
        } else {
            
        }
        
    }
    @IBAction func logoutTapped(_ sender: Any) {
        
        try?  Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
}
