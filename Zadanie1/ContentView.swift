import SwiftUI

struct ContentView: View {
    // Imię, które wyzwala dodatkowy komunikat ("Mamy to samo imię").
    private let mojeImie = "Maciej"

    @State private var imie: String = ""
    @State private var nazwisko: String = ""
    @State private var wiadomosc: String = "Witaj"

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                TextField("Wpisz swoje imię", text: $imie)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: imie) { _, nowaWartosc in
                        wiadomosc = aktualizujWiadomosc(noweImie: nowaWartosc, noweNazwisko: nazwisko)
                    }

                TextField("Wpisz swoje nazwisko", text: $nazwisko)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: nazwisko) { _, nowaWartosc in
                        wiadomosc = aktualizujWiadomosc(noweImie: imie, noweNazwisko: nowaWartosc)
                    }

                Text(wiadomosc)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(10)

                NavigationLink(destination: DrugiWidok(nazwisko: $nazwisko)) {
                    Text("Przejdź do drugiego widoku")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 30)
            .onAppear {
                wiadomosc = aktualizujWiadomosc(noweImie: imie, noweNazwisko: nazwisko)
            }
        }
    }

    func aktualizujWiadomosc(noweImie: String, noweNazwisko: String) -> String {
        let czysteImie = noweImie.trimmingCharacters(in: .whitespaces)
        let czysteNazwisko = noweNazwisko.trimmingCharacters(in: .whitespaces)
        let pelneDane = [czysteImie, czysteNazwisko].filter { !$0.isEmpty }.joined(separator: " ")
        let powitanie = pelneDane.isEmpty ? "Witaj" : "Witaj \(pelneDane)"
        if !czysteImie.isEmpty && czysteImie.caseInsensitiveCompare(mojeImie) == .orderedSame {
            return powitanie + "! Mamy to samo imię"
        }
        return powitanie
    }
}

#Preview {
    ContentView()
}
