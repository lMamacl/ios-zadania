import SwiftUI

struct ContentView: View {
    @State private var wiadomosc = "Oczekiwanie na gesty..."
    @State private var kolor: Color = .gray            // domyślnie: inny niż biały
    @State private var czyPokazujeDialog = false
    // true, gdy użytkownik zatwierdzi zmianę koloru; drugi widok startuje wtedy z losowym kolorem.
    @State private var czyPotrzasnieto = false
    @State private var czyWidoczny = true

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text(wiadomosc)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(10)
                Spacer()
                NavigationLink(destination: DrugiWidok(czyPotrzasnieto: czyPotrzasnieto)) {
                    Text("Przejdź do drugiego widoku")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background(kolor.ignoresSafeArea())
            .gesture(gestyTapniec)
            .onLongPressGesture { wiadomosc = "Długie przytrzymanie (Long press)!" }
            .gesture(gestPinch)
            .simultaneousGesture(gestPrzeciagania)
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                guard czyWidoczny else { return }
                wiadomosc = "Potrząśnięto (Shaken)"
                czyPokazujeDialog = true
            }
            .confirmationDialog(
                "Czy chcesz zmienić kolor tła?",
                isPresented: $czyPokazujeDialog,
                titleVisibility: .visible
            ) {
                Button("Tak") {
                    kolor = ColorHelper.getRandomColor()
                    czyPotrzasnieto = true
                }
                Button("Nie", role: .destructive) { }
                Button("Anuluj", role: .cancel) { }
            }
            .onAppear { czyWidoczny = true }
            .onDisappear { czyWidoczny = false }
        }
    }

    // Potrójne > podwójne > pojedyncze tapnięcie: wyższa liczba ma priorytet.
    private var gestyTapniec: some Gesture {
        let potrojne = TapGesture(count: 3).onEnded { wiadomosc = "Potrójne tapnięcie!" }
        let podwojne = TapGesture(count: 2).onEnded { wiadomosc = "Podwójne tapnięcie!" }
        let pojedyncze = TapGesture(count: 1).onEnded { wiadomosc = "Pojedyncze tapnięcie!" }
        return potrojne.exclusively(before: podwojne).exclusively(before: pojedyncze)
    }

    private var gestPinch: some Gesture {
        MagnifyGesture()
            .onChanged { wartosc in
                wiadomosc = "Pinch! (skala \(String(format: "%.2f", wartosc.magnification)))"
            }
            .onEnded { _ in
                wiadomosc = "Koniec gestu pinch"
            }
    }

    private var gestPrzeciagania: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { _ in
                wiadomosc = "Przeciąganie..."
            }
            .onEnded { wartosc in
                wiadomosc = "Przesunięcie w \(kierunek(przesuniecie: wartosc.translation))"
            }
    }

    private func kierunek(przesuniecie: CGSize) -> String {
        if abs(przesuniecie.width) > abs(przesuniecie.height) {
            return przesuniecie.width > 0 ? "prawo" : "lewo"
        }
        return przesuniecie.height > 0 ? "dół" : "górę"
    }
}

#Preview {
    ContentView()
}
