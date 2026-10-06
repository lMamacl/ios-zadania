import SwiftUI

struct SecondView: View {
    @Binding var surname: String

    var body: some View {
        VStack(spacing: 10) {
            Text("Your surname")
                .padding(10)

            TextField("Surname", text: $surname)
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
    SecondView(surname: .constant("Surname"))
}
