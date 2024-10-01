//
//  MapManager.swift
//  MyTrips
//
//  Created by Lori Rothermel on 9/25/24.
//

import SwiftData
import MapKit

@MainActor
enum MapManager {
    static func searchPlaces(_ modelContext: ModelContext, searchText: String, visibleRegion: MKCoordinateRegion?) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        if let visibleRegion {
            request.region = visibleRegion
        }  // if let
        
        let searchItems = try? await MKLocalSearch(request: request).start()
        let results = searchItems?.mapItems ?? []
        results.forEach {
            let mtPlacemark = MTPlacemark(
                                            name: $0.placemark.name ?? "",
                                            address: $0.placemark.title ?? "",
                                            latitude: $0.placemark.coordinate.latitude,
                                            longitude: $0.placemark.coordinate.longitude)
            modelContext.insert(mtPlacemark)
        }  // results.forEach
    }  // static func searchPlaces
    
    
    static func removeSearchResults(_ modelContext: ModelContext) {
        let searchPredicate = #Predicate<MTPlacemark> {$0.destination == nil }
        
        try? modelContext.delete(model: MTPlacemark.self, where: searchPredicate)
    }  // static func removeSearchResults
    
}  // enum MapManager

