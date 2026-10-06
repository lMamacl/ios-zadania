import SwiftUI

/// One form for both adding and editing a person.
struct PersonFormView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    private let originalID: UUID?
    private let onSave: (Person) -> Void

    @State private var firstName: String
    @State private var lastName: String
    @State private var hasBirthDate: Bool
    @State private var birthDate: Date
    @State private var phone: String
    @State private var email: String
    @State private var address: String

    @State private var attemptedSave = false
    @State private var showErrorAlert = false

    init(title: String, person: Person? = nil, onSave: @escaping (Person) -> Void) {
        self.title = title
        self.originalID = person?.id
        self.onSave = onSave
        _firstName = State(initialValue: person?.firstName ?? "")
        _lastName = State(initialValue: person?.lastName ?? "")
        _hasBirthDate = State(initialValue: person?.birthDate != nil)
        _birthDate = State(initialValue: person?.birthDate ?? PersonFormView.defaultBirthDate)
        _phone = State(initialValue: person?.phone ?? "")
        _email = State(initialValue: person?.email ?? "")
        _address = State(initialValue: person?.address ?? "")
    }

    private static var defaultBirthDate: Date {
        Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? Date()
    }

    private var issues: [ValidationIssue] {
        PersonValidator.validate(firstName: firstName,
                                 lastName: lastName,
                                 birthDate: hasBirthDate ? birthDate : nil,
                                 phone: phone,
                                 email: email)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dane podstawowe") {
                    TextField("Imię *", text: $firstName)
                        .textContentType(.givenName)
                    errorText(for: .firstName)
                    TextField("Nazwisko *", text: $lastName)
                        .textContentType(.familyName)
                    errorText(for: .lastName)
                }

                Section("Data urodzenia (opcjonalnie)") {
                    Toggle("Podaj datę urodzenia", isOn: $hasBirthDate)
                    if hasBirthDate {
                        DatePicker("Data urodzenia",
                                   selection: $birthDate,
                                   in: ...Date(),
                                   displayedComponents: .date)
                    }
                    errorText(for: .birthDate)
                }

                Section("Kontakt") {
                    TextField("Telefon (opcjonalnie)", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    errorText(for: .phone)
                    TextField("E-mail *", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    errorText(for: .email)
                    TextField("Adres zamieszkania (opcjonalnie)", text: $address)
                        .textContentType(.fullStreetAddress)
                }

                if attemptedSave && !issues.isEmpty {
                    Section("Błędy w formularzu") {
                        ForEach(issues) { issue in
                            Text("• \(issue.message)")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") { save() }
                }
            }
            .alert("Popraw błędy w formularzu", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(issues.map { "• \($0.message)" }.joined(separator: "\n"))
            }
        }
    }

    @ViewBuilder
    private func errorText(for field: ValidationIssue.Field) -> some View {
        if attemptedSave {
            ForEach(issues.filter { $0.field == field }) { issue in
                Text(issue.message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private func save() {
        attemptedSave = true
        guard issues.isEmpty else {
            showErrorAlert = true      // all errors are listed; nothing is saved
            return
        }
        let person = Person(id: originalID ?? UUID(),
                            firstName: firstName.trimmed,
                            lastName: lastName.trimmed,
                            birthDate: hasBirthDate ? birthDate : nil,
                            phone: phone.trimmed,
                            email: email.trimmed,
                            address: address.trimmed)
        onSave(person)
        dismiss()
    }
}
