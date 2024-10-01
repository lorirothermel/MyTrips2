//
//  LocationManager.swift
//  MyTrips2
//
//  Created by Lori Rothermel on 9/28/24.
//

import SwiftUI
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored let manager = CLLocationManager()
    
    var userLocation: CLLocation?
    var isAuthorized = false
    
    override init() {
        super.init()
        manager.delegate = self
        startLocationServices()
    }  // init()
    
    func startLocationServices() {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isAuthorized = true
        } else {
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }  //  if else
        
        
        
    }  // func startLocationServices
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }  // func locationManager - didUpdateLocations
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                isAuthorized = true
                manager.requestLocation()
            case .notDetermined:
                isAuthorized = false
                manager.requestWhenInUseAuthorization()
            case .denied:
                isAuthorized = false
                print("😡 Access has been denied!")
            default:
                isAuthorized = true
                startLocationServices()
        }  // switch
    }  // func locationManagerDidChangeAuthorization
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }  // func locationManager - didFailWithError
    
    
}  // class LocationManager


