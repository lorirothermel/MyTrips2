//
//  MyTripsApp.swift
//  MyTrips
//
//  Created by Lori Rothermel on 9/25/24.
//


import SwiftUI
import MapKit
import SwiftData



struct DestinationLocationsMapView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @FocusState private var searchFieldFocus: Bool
    @Query(filter: #Predicate<MTPlacemark> {$0.destination == nil})
    
    private var searchPlacemarks: [MTPlacemark]
    
    var destination: Destination
    
    private var listPlacemarks: [MTPlacemark] {
        searchPlacemarks + destination.placemarks
    }  // listPlacemarks
    
     
    
    var body: some View {
        @Bindable var destination = destination
        
        VStack {
            LabeledContent {
                TextField("Enter destination name", text: $destination.name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.primary)
            } label: {
                Text("Name")
            }  // LabeledContent
            
            HStack {
                Text("Adjust the map to set the region for your destination.")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Set Region") {
                    if let visibleRegion {
                        destination.latitude = visibleRegion.center.latitude
                        destination.longitude = visibleRegion.center.longitude
                        destination.latitudeDelta = visibleRegion.span.longitudeDelta
                        destination.longitudeDelta = visibleRegion.span.latitudeDelta
                    }  // if let
                }  // Button - Set Region
                .buttonStyle(.borderedProminent)
                
            }  // HStack
            
        }  // VStack
        .padding(.horizontal)
        
        Map(position: $cameraPosition) {
            ForEach(listPlacemarks) { placemark in
                if placemark.destination != nil {
                    Marker(coordinate: placemark.coordinate) {
                        Label(placemark.name, systemImage: "star")
                    }  // Marker
                    .tint(.yellow)
                } else {
                    Marker(placemark.name, coordinate: placemark.coordinate)
                }  // if else
            }  // ForEach
        }  // Map
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFieldFocus)
                    .overlay(alignment: .trailing) {
                        if searchFieldFocus {
                            Button {
                                searchText = ""
                                searchFieldFocus = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }  // Button
                            .offset(x: -5)
                        }  // if
                    }  // .overlay
                    .onSubmit {
                        Task {
                            await MapManager.searchPlaces(
                                modelContext,
                                searchText: searchText,
                                visibleRegion: visibleRegion)
                            searchText = ""
                        }  // Task
                    }  // .onSubmit
                if !searchPlacemarks.isEmpty {
                    Button {
                        MapManager.removeSearchResults(modelContext)
                    } label: {
                        Image(systemName: "mappin.slash.circle..fill")
                            .imageScale(.large)
                    }  // Button
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.red)
                    .clipShape(.circle)
                }// if
            }  // HStack
            .padding()
        }  // .safeAreaInset
        .navigationTitle("Destination")
        .navigationBarTitleDisplayMode(.inline)
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }  // .onMapCameraChange
        .onAppear {
            MapManager.removeSearchResults(modelContext)
            if let region = destination.region {
                cameraPosition = .region(region)
            }  // if let
         }  // .onAppear
        .onDisappear {
            MapManager.removeSearchResults(modelContext)
        }  // .onDisappear
    
          
    }  // some View
    
}  // DestinationLocationsMapView


#Preview {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    return NavigationStack {
        DestinationLocationsMapView(destination: destination)
    }  // NavigationStack
    .modelContainer(Destination.preview)
}  // Preview
