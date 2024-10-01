//
//  ContentView.swift
//  MyTrips2
//
//  Created by Lori Rothermel on 9/26/24.
//

import SwiftUI

struct StartTab: View {
    var body: some View {
        TabView {
            Group {
                TripMapView()
                    .tabItem {
                    Label("TripMap", systemImage: "map")
                }  // .tabItem
                DestinationsListView()
                    .tabItem {
                        Label("Destinations", systemImage: "globe.desk")
                    }  // .tabItem
            }  // Group
            .toolbarBackground(.appBlue.opacity(0.8), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }  // TabView
        
        
    }  // some View
    
}  // StartTab

#Preview {
    StartTab()
        .modelContainer(Destination.preview)
        .environment(LocationManager())
}


