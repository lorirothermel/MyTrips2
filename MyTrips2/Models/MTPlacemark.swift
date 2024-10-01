//
//  MTPlacemark.swift
//  MyTrips
//
//  Created by Lori Rothermel on 9/25/24.
//

import SwiftData
import MapKit


@Model
class MTPlacemark {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var destination: Destination?
    
    init(name: String, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }  // init
    
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }  // var coordinate
    
}  // class MTPlacemark


