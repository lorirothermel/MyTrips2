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
    @State private var showRoute = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDistination: MKMapItem?
    @State private var travelInterval: TimeInterval?
    @State private var transportType = MKDirectionsTransportType.automobile
    @State private var showSteps = false
    
    
    @FocusState private var searchFieldFocus: Bool
    
    @Query(filter: #Predicate<MTPlacemark> {$0.destination == nil})  private var searchPlacemarks: [MTPlacemark]
    @Query private var listPlacemarks: [MTPlacemark]
    
     
           
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedPlacemark) {
            UserAnnotation()
            ForEach(listPlacemarks) { placemark in
                if !showRoute {
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
                } else {
                    if let routeDistination {
                        Marker(item: routeDistination)
                            .tint(.green)
                    }  // if let
                }  // if else
            }  // ForEach
            if let route, routeDisplaying {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }  // if let
        }  // Map
        .sheet(item: $selectedPlacemark) { selectedPlacemark in
            LocationDetailView(
                                selectedPlacemark: selectedPlacemark,
                                showRoute: $showRoute,
                                travelInterval: $travelInterval,
                                transportType: $transportType)
                
        }  // .sheet
        .presentationDetents([.height(450)])
        .onMapCameraChange { context in
            visibleRegion = context.region
        }  // .onMapCameraChange
        .onAppear {
            MapManager.removeSearchResults(modelContext)
            updateCameraPosition()
        }  // .onAppear
        .mapControls {
            MapUserLocationButton()
        }  // .mapControls
        .task(id: selectedPlacemark) {
            if selectedPlacemark != nil {
                routeDisplaying = false
                showRoute = false
                route = nil
                await fetchRoute()
            }  // if
        }  // .task
        .onChange(of: showRoute) {
            selectedPlacemark = nil
            if showRoute {
                withAnimation {
                    routeDisplaying = true
                    if let rect = route?.polyline.boundingMapRect {
                        cameraPosition = .rect(rect)
                    }  // if
                }  // withAnimation
            }  // if
        }  // .onChange(of: showRoute)
        .task(id: transportType) {
            await fetchRoute()
        }  // .task
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
                    if routeDisplaying {
                        HStack {
                            Button("Clear Route", systemImage: "xmark.circle") {
                                removeRoute()
                            }  // Button - Clear Route
                            .buttonStyle(.borderedProminent)
                            .fixedSize(horizontal: true, vertical: false)
                            
                            Button("Show Steps", systemImage: "location.north") {
                                showSteps.toggle()
                            }  // Button
                            .buttonStyle(.borderedProminent)
                            .fixedSize(horizontal: true, vertical: false)
                            .sheet(isPresented: $showSteps) {
                                if let route {
                                    NavigationStack {
                                        List {
                                            HStack {
                                                Image(systemName: "mappin.circle.fill")
                                                    .foregroundStyle(.red)
                                                Text("From my location")
                                                Spacer()
                                            }  // HStack
                                            ForEach(1..<route.steps.count, id: \.self) { idx in
                                                VStack(alignment: .leading) {
                                                    Text("\(transportType == .automobile ? "Drive" : "Walk") \(MapManager.distance(meters: route.steps[idx].distance))")
                                                        .bold()
                                                    Text(" - \(route.steps[idx].instructions)")
                                                }  // VStack
                                            }  // ForEach
                                        }  // List
                                        .listStyle(.plain)
                                        .navigationTitle("Steps")
                                        .navigationBarTitleDisplayMode(.inline)
                                    }  // Navigation Stack
                                }  // if
                            }  // .sheet
                        }  // HStack
                    }  // if
                    
                    
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
    
    
    func fetchRoute() async {
        if let userLocation = locationManager.userLocation, let selectedPlacemark {
            let request = MKDirections.Request()
            let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
            let routeSource = MKMapItem(placemark: sourcePlacemark)
            let destinationPlacemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
            
            routeDistination = MKMapItem(placemark: destinationPlacemark)
            routeDistination?.name = selectedPlacemark.name
            
            request.source = routeSource
            request.destination = routeDistination
            request.transportType = transportType
            
            let diretions = MKDirections(request: request)
            let result = try? await diretions.calculate()
            
            route = result?.routes.first
            travelInterval = route?.expectedTravelTime
            
        }  // if
        
    }  // func fetchRoute
    
    
    func removeRoute() {
        routeDisplaying = false
        showRoute = false
        route = nil
        selectedPlacemark = nil
        updateCameraPosition()
    }  // func removeRoute
    
    
    
}  // TripMapView

#Preview {
    TripMapView()
        .environment(LocationManager())
        .modelContainer(Destination.preview)
}



