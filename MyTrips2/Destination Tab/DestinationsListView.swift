//
//  DestinationsListView.swift
//  MyTrips
//
//  Created by Lori Rothermel on 9/25/24.
//

import SwiftUI
import SwiftData


struct DestinationsListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Destination.name) private var destinations: [Destination]
    @State private var newDestination = false
    @State private var name = ""
    @State private var path = NavigationPath()
    
    
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if !destinations.isEmpty {
                    List(destinations) { destination in
                        NavigationLink(value: destination) {
                            HStack {
                                Image(systemName: "globe")
                                    .imageScale(.large)
                                    .foregroundStyle(.accent)
                                VStack(alignment: .leading) {
                                    Text(destination.name)
                                    Text("^[\(destination.placemarks.count) Location.](inflect: true)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }  // VStack
                                
                            }  // HStack
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(destination)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }  // Button - Delete
                            }  // .swipeActions
                        }  // NavigationLink
                    }  // List
                    .navigationDestination(for: Destination.self) { destination in
                        DestinationLocationsMapView(destination: destination)
                    }  // .navigationDestination
                } else {
                    ContentUnavailableView("No Destinations",
                                           systemImage: "globe.desk",
                                           description: Text("You have not set up any destinations yet! Tap on the \(Image(systemName: "plus.circle.fill")) button in the toolbar to begin."))
                }  // if else
                
            }  // Group
            .navigationTitle("My Destinations")
            .toolbar {
                Button {
                    newDestination.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }  // Button
                
                
                
                .alert("Enter Destination Name",
                       isPresented: $newDestination) {
                    TextField("Enter destination name", text: $name)
                        .autocorrectionDisabled()
                    Button("OK") {
                        if !name.isEmpty {
                            let destination = Destination(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
                            modelContext.insert(destination)
                            name = ""
                            path.append(destination)
                        }  // if
                    }  // Button - OK
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Create a New Destination")
                }  // .alert
            }  // .toolbar
            
        }  // NavigationStack
        
    }  // some View
    
}  // DestinationsListView

#Preview {
    DestinationsListView()
        .modelContainer(Destination.preview)
}


