import SwiftUI
import CoreLocation

struct SecondView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var color: Color
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var address = ""

    init(wasShaken: Bool) {
        // White unless the colour was changed on the first view, then random.
        _color = State(initialValue: wasShaken ? ColorHelper.getRandomColor() : .white)
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Latitude: \(latitude)")
            Text("Longitude: \(longitude)")
            Text("Address: \(address)")
                .multilineTextAlignment(.center)
            Button("Get localization") {
                locationManager.checkLocationAuthorization()
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            color = ColorHelper.getRandomColor()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            guard let location = newLocation else { return }
            showLocation(location)
        }
        .onChange(of: locationManager.errorMessage) { _, message in
            if let message { address = message }
        }
    }

    private func showLocation(_ location: CLLocation) {
        latitude = location.coordinate.latitude.description
        longitude = location.coordinate.longitude.description

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            guard let p = placemarks?.first else { return }
            address = [
                p.location?.description,
                p.thoroughfare,
                p.subAdministrativeArea,
                p.isoCountryCode,
                p.country
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
        }
    }
}
