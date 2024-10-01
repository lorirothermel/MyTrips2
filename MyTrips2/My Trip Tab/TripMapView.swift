//
//  MyTripsApp.swift
//  MyTrips
//
//  Created by Lori Rothermel on 9/25/24.
//


import SwiftUI
import MapKit
import SwiftData


struct TripMapView: View {
    @Environment(LocationManager.self) var locationManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchText = ""
    @State private var selectedPlacemark: MTPlacemark?
    @State private var visibleRegion: MKCoordinateRegion?
    
    @FocusState private var searchFieldFocus: Bool
    
    @Query(filter: #Predicate<MTPlacemark> {$0.destination == nil})  private var searchPlacemarks: [MTPlacemark]
    @Query private var listPlacemarks: [MTPlacemark]
    
     
           
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedPlacemark) {
            UserAnnotation()
            ForEach(listPlacemarks) { placemark in
                Group {
                    if placemark.destination != nil {
                        Marker(coordinate: placemark.coordinate) {
                            Label(placemark.name, systemImage: "star")
                        }  // Marker
                        .tint(.yellow)
                    } else {
                        Marker(placemark.name,coordinate: placemark.coordinate)
                    }  // if else
                }  // Group
                .tag(placemark)
            }  // ForEach
        }  // Map
        .sheet(item: $selectedPlacemark) { selectedPlacemark in
            LocationDetailView(selectedPlacemark: selectedPlacemark)
                .presentationDetents([.height(450)])
        }  // .sheet
        .onMapCameraChange { context in
            visibleRegion = context.region
        }  // .onMapCameraChange
        .onAppear {
            updateCameraPosition()
        }  // .onAppear
        .mapControls {
            MapUserLocationButton()
        }  // .mapControls
        .safeAreaInset(edge: .bottom) {
            HStack {
                VStack {
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
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
                    
                    
                    
                }  // VStack
                .padding()
                VStack {
                    if !searchPlacemarks.isEmpty {
                        Button {
                            MapManager.removeSearchResults(modelContext)
                        } label: {
                            Image(systemName: "mappin.slash")
                        }  // Button
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }  // if
                }  // VStack
                .padding()
                .buttonBorderShape(.circle)
            }  // HStack
        }  // .safeAreaInset
        
         
    }  // some View
    
    func updateCameraPosition() {
        if let userlocation = locationManager.userLocation {
            let userRegion = MKCoordinateRegion(
                                                center: userlocation.coordinate,
                                                span: MKCoordinateSpan(
                                                    latitudeDelta: 0.15,
                                                    longitudeDelta: 0.15)
                                               )
            withAnimation {
                cameraPosition = .region(userRegion)
            }  // withAnimation
            
        }  // if
        
    }  // func updateCameraPosition
    
    
}  // TripMapView

#Preview {
    TripMapView()
        .environment(LocationManager())
        .modelContainer(Destination.preview)
}



