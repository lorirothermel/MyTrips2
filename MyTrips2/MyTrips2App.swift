
//  MyTrips2App.swift
//  MyTrips2
//
//  Created by Lori Rothermel on 9/26/24.


import SwiftUI
import SwiftData


@main
struct MyTrips2App: App {
    @State private var locationManager = LocationManager()
    
    
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                StartTab()
            } else {
                LocationDeniedView()
            }  // if else
            
            
            
        }
        
        .modelContainer(for: Destination.self)
        .environment(locationManager)
    }
}

