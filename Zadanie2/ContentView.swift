import SwiftUI

struct ContentView: View {
    // Liczba kierunków wyświetlana w alercie (%i w zlokalizowanym ciągu).
    private let liczbaKierunkow: Int32 = 4

    @State private var pokazAlert = false

    var body: some View {
        VStack(spacing: 10) {
            // "Filename" pobiera "wi-en" lub "wi-pl" w zależności od języka systemu.
            Image(NSLocalizedString("Filename", comment: "Zlokalizowana nazwa pliku z logo"))
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)

            Button(NSLocalizedString("Button", comment: "Etykieta przycisku")) {
                pokazAlert = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(10)
        .alert(NSLocalizedString("Information", comment: "Tytuł alertu"), isPresented: $pokazAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(String(format: NSLocalizedString("AlertMessage", comment: "Treść alertu z liczbą kierunków"),
                        liczbaKierunkow))
        }
    }
}

#Preview {
    ContentView()
}
