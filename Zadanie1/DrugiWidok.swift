import SwiftUI

struct DrugiWidok: View {
    @Binding var nazwisko: String

    var body: some View {
        VStack(spacing: 10) {
            Text("Twoje nazwisko")
                .padding(10)

            TextField("Nazwisko", text: $nazwisko)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding(.horizontal, 30)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    DrugiWidok(nazwisko: .constant("Nazwisko"))
}
