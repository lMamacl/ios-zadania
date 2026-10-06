import SwiftUI

struct ContentView: View {
    // The name that triggers the extra message ("We have the same name").
    private let myName = "Maciej"

    @State private var firstName: String = ""
    @State private var surname: String = ""
    @State private var message: String = "Hello"

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                TextField("Enter your name", text: $firstName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: firstName) { _, newValue in
                        message = updateMessage(newFirstName: newValue, newSurname: surname)
                    }

                TextField("Enter your surname", text: $surname)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: surname) { _, newValue in
                        message = updateMessage(newFirstName: firstName, newSurname: newValue)
                    }

                Text(message)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(10)

                NavigationLink(destination: SecondView(surname: $surname)) {
                    Text("Go to the second view")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 30)
            .onAppear {
                message = updateMessage(newFirstName: firstName, newSurname: surname)
            }
        }
    }

    func updateMessage(newFirstName: String, newSurname: String) -> String {
        let cleanFirst = newFirstName.trimmingCharacters(in: .whitespaces)
        let cleanSurname = newSurname.trimmingCharacters(in: .whitespaces)
        let fullName = [cleanFirst, cleanSurname].filter { !$0.isEmpty }.joined(separator: " ")
        let greeting = fullName.isEmpty ? "Hello" : "Hello \(fullName)"
        if !cleanFirst.isEmpty && cleanFirst.caseInsensitiveCompare(myName) == .orderedSame {
            return greeting + "! We have the same name"
        }
        return greeting
    }
}

#Preview {
    ContentView()
}
