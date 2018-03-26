//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Lakshay Chhabra on 25/03/18.
//  Copyright © 2018 Lakshay Chhabra. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {

     @IBOutlet var map: MKMapView!
     var requestLocation = CLLocationCoordinate2D()
     var requestEmail = ""
    var driverLocation = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        
        let annotations = MKPointAnnotation()
        annotations.coordinate = requestLocation
        annotations.title = requestEmail
        map.addAnnotation(annotations )
        
    }


    @IBAction func acceptRequestTapped(_ sender: Any) {
        //Updates the ride requests
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            
            snapshot.ref.updateChildValues(["driverLat" : self.driverLocation.latitude, "driverLon" : self.driverLocation.longitude])
                Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        //Navigation Directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail
                    
                    let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                    
                }
            }
        }
        
        
    }
    
    
}
