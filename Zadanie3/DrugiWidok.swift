import SwiftUI
import CoreLocation

struct DrugiWidok: View {
    @StateObject private var menedzerLokalizacji = LocationManager()
    @State private var kolor: Color
    @State private var szerokosc = ""
    @State private var dlugosc = ""
    @State private var adres = ""

    init(czyPotrzasnieto: Bool) {
        // Domyślnie biały, chyba że w pierwszym widoku zmieniono kolor – wtedy losowy.
        _kolor = State(initialValue: czyPotrzasnieto ? ColorHelper.getRandomColor() : .white)
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Szerokość (Latitude): \(szerokosc)")
            Text("Długość (Longitude): \(dlugosc)")
            Text("Adres: \(adres)")
                .multilineTextAlignment(.center)
            Button("Pobierz lokalizację") {
                menedzerLokalizacji.checkLocationAuthorization()
                if let lokalizacja = menedzerLokalizacji.location {
                    pokazLokalizacje(lokalizacja)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(kolor.ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            kolor = ColorHelper.getRandomColor()
        }
        .onChange(of: menedzerLokalizacji.location) { _, nowaLokalizacja in
            guard let lokalizacja = nowaLokalizacja else { return }
            pokazLokalizacje(lokalizacja)
        }
        .onChange(of: menedzerLokalizacji.errorMessage) { _, komunikat in
            if let komunikat { adres = komunikat }
        }
    }

    private func pokazLokalizacje(_ lokalizacja: CLLocation) {
        szerokosc = lokalizacja.coordinate.latitude.description
        dlugosc = lokalizacja.coordinate.longitude.description

        CLGeocoder().reverseGeocodeLocation(lokalizacja) { punkty, _ in
            guard let p = punkty?.first else { return }
            adres = [
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
