//
//  LocationDetailView.swift
//  MyTrips2
//
//  Created by Lori Rothermel on 9/26/24.
//


import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var destination: Destination?
    var selectedPlacemark: MTPlacemark?
    
    @State private var name = ""
    @State private var address = ""
    
    @State private var lookaroundScene: MKLookAroundScene?
    
    var isChanged: Bool {
        guard let selectedPlacemark else { return false }
        return (name != selectedPlacemark.name || address != selectedPlacemark.address)
    }  // var isChanged
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    if destination != nil {
                        TextField("Name", text: $name)
                            .font(.title)
                        TextField("address", text: $address, axis: .vertical)
                        if isChanged {
                            Button("Update") {
                                selectedPlacemark?.name = name
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                selectedPlacemark?.address = address
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                            }  // Button - Update
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .buttonStyle(.borderedProminent)
                        }  // if
                    } else {
                        Text(selectedPlacemark?.name ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(selectedPlacemark?.address ?? "")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.trailing)
                    }  // if else
                }  // VStack
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                Spacer()
                Button {
                   dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                }  // Button
            }  // HStack
            if let lookaroundScene {
                LookAroundPreview(initialScene: lookaroundScene)
                    .frame(height: 200)
                    .padding()
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }  // if else
            HStack {
                Spacer()
                if let destination {
                    let inList = (selectedPlacemark != nil && selectedPlacemark?.destination != nil)
                    Button {
                        if let selectedPlacemark {
                            if selectedPlacemark.destination == nil {
                                destination.placemarks.append(selectedPlacemark)
                            } else {
                                selectedPlacemark.destination = nil
                            }
                            dismiss()
                        } // if
                    } label: {
                        Label(inList ? "Remove" : "Add", systemImage: inList ? "minus.circle" : "plus.circle")
                    }  // Button - Remove or Add
                    .buttonStyle(.borderedProminent)
                    .tint(inList ? .red : .green)
                    .disabled((name.isEmpty || isChanged))
                } else {
                    HStack {
                        Button("Open in maps", systemImage: "map") {
                            if let selectedPlacemark {
                                let placemark = MKPlacemark(coordinate: selectedPlacemark.coordinate)
                                let mapItem = MKMapItem(placemark: placemark)
                                mapItem.name = selectedPlacemark.name
                                mapItem.openInMaps()
                            }  // if
                        }  // Button - Open in Maps
                        .fixedSize(horizontal: true, vertical: false)
                        Button("Show Route", systemImage: "location.north") {

                        }  // Button - Show Route
                        .fixedSize(horizontal: true, vertical: false)
                    }  // HStack
                    .buttonStyle(.bordered)
                }  // if else
            }  // HStack
            Spacer()
        }  // VStack
        .padding()
        .task(id: selectedPlacemark) {
            await fetchLookaroundPreview()
        }  // .task
        .onAppear {
            if let selectedPlacemark, destination != nil {
                name = selectedPlacemark.name
                address = selectedPlacemark.address
            }  // if
        }  // .onAppear
        
    }  // some View
    
    func fetchLookaroundPreview() async {
        if let selectedPlacemark {
            lookaroundScene = nil
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
            lookaroundScene = try? await lookaroundRequest.scene
        }  // if
    }  // func fetchLookaroundPreview
}  // LocationDetailView

#Preview("Destination Tab") {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    let selectedPlacemark = destination.placemarks[0]
    return LocationDetailView(
        destination: destination,
        selectedPlacemark: selectedPlacemark
    )
}

#Preview("TripMap Tab") {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<MTPlacemark>()
    let placemarks = try! container.mainContext.fetch(fetchDescriptor)
    let selectedPlacemark = placemarks[0]
    return LocationDetailView(
        selectedPlacemark: selectedPlacemark
    )
}
