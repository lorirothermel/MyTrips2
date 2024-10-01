//
//  LocationDeniedView.swift
//  MyTrips2
//
//  Created by Lori Rothermel on 9/28/24.
//

import SwiftUI

struct LocationDeniedView: View {
    var body: some View {
        ContentUnavailableView(label: {
            Label("Location Services", image: "launchScreen")
        },
                               description: {
            Text("""
1. Tab the button below and go to "Privacy and Security"
2. Tap on "Location Services"
3. Locate the "MyTrips" app and tap on it
4. Change the setting to "While Using the App"
""")
            .multilineTextAlignment(.leading)
        },
                               actions: {
            Button(action: {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            }) {
                Text("Open Settings")
            }
            .buttonStyle(.borderedProminent)
        })
    }
}

#Preview {
    LocationDeniedView()
}
