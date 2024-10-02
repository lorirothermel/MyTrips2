
//  MyTripsApp.swift
//  MyTrips
//
//  Created by Lori Rothermel on 9/25/24.


import SwiftUI
import MapKit
import SwiftData


struct DestinationLocationsMapView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @State private var selectedPlacemark: MTPlacemark?
    @State private var isManualMarker = false
        
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
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
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

        MapReader { proxy in
            Map(position: $cameraPosition, selection: $selectedPlacemark) {
                ForEach(listPlacemarks) { placemark in
                    if isManualMarker {
                        if placemark.destination != nil {
                            Marker(coordinate: placemark.coordinate) {
                                Label(placemark.name, systemImage: "star")
                            }  // Marker
                            .tint(.yellow)
                        } else {
                            Marker(placemark.name, coordinate: placemark.coordinate)
                        }  // if else
                    } else {
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
                    }  // if else
                }  // ForEach
            }  // Map
            .onTapGesture { position in
                if isManualMarker {
                    if let coordinate = proxy.convert(position, from: .local) {
                        let mtPlacemark = MTPlacemark(name: "", address: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                        modelContext.insert(mtPlacemark)
                        selectedPlacemark = mtPlacemark
                    }  // if let
                }  // if
            }  // .onTapGesture
        }  // MapReader
        .sheet(item: $selectedPlacemark, onDismiss: {
            if isManualMarker {
                MapManager.removeSearchResults(modelContext)
            }  // if
        }) { selectedPlacemark in
            LocationDetailView(
                destination: destination,
                selectedPlacemark: selectedPlacemark,
                showRoute: .constant(false),
                travelInterval: .constant(nil),
                transportType: .constant(.automobile))
        }  // .sheet
        .presentationDetents([.height(450)])
        
        .safeAreaInset(edge: .bottom) {
            VStack {
                Toggle(isOn: $isManualMarker) {
                    Label("Tap Marker Placement Is \(isManualMarker ? "ON" : "OFF")", systemImage: isManualMarker ? "mappin.circle" : "mappin.slash.circle")
                }  // Toggle
                .fontWeight(.bold)
                .toggleStyle(.button)
                .background(.ultraThinMaterial)
                .onChange(of: isManualMarker) {
                    MapManager.removeSearchResults(modelContext)
                }  // .onChange
                
                
                if !isManualMarker {
                    HStack {
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
                                    cameraPosition = .automatic
                                }  // Task
                            }  // .onSubmit
                        if !searchPlacemarks.isEmpty {
                            Button {
                                MapManager.removeSearchResults(modelContext)
                            } label: {
                                Image(systemName: "mappin.slash.circle.fill")
                                    .imageScale(.large)
                            }  // Button
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.red)
                            .clipShape(.circle)
                        }// if
                    }  // HStack
                    .padding()
                }  // if
            }  // VStack
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


