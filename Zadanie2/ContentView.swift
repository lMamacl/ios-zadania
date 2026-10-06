import SwiftUI

struct ContentView: View {
    // Number of programs shown in the alert (%i in the localized string).
    private let programsCount: Int32 = 4

    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 10) {
            // "Filename" is "wi-en" or "wi-pl" depending on the system language.
            Image(NSLocalizedString("Filename", comment: "Localized logo file name"))
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)

            Button(NSLocalizedString("Button", comment: "Button label")) {
                showAlert = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(10)
        .alert(NSLocalizedString("Information", comment: "Alert title"), isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(String(format: NSLocalizedString("AlertMessage", comment: "Alert message with number of programs"),
                        programsCount))
        }
    }
}

#Preview {
    ContentView()
}
