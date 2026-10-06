import SwiftUI

struct PersonDetailView: View {
    @EnvironmentObject private var store: PersonStore
    @Environment(\.dismiss) private var dismiss

    let personID: UUID
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        Group {
            if let person = store.person(withID: personID) {
                List {
                    Section("Dane osobowe") {
                        LabeledContent("Imię", value: person.firstName)
                        LabeledContent("Nazwisko", value: person.lastName)
                        LabeledContent("Data urodzenia",
                                       value: person.birthDate?.formatted(date: .long, time: .omitted) ?? "—")
                    }
                    Section("Kontakt") {
                        LabeledContent("Telefon", value: person.phone.isEmpty ? "—" : person.phone)
                        LabeledContent("E-mail", value: person.email)
                        LabeledContent("Adres", value: person.address.isEmpty ? "—" : person.address)
                    }
                    Section {
                        Button("Usuń osobę", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                }
                .navigationTitle(person.fullName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edytuj") { showingEdit = true }
                    }
                }
                .sheet(isPresented: $showingEdit) {
                    PersonFormView(title: "Edytuj osobę", person: person) { store.update($0) }
                }
                .confirmationDialog(
                    "Czy na pewno usunąć \(person.fullName)?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Usuń", role: .destructive) {
                        store.delete(person)
                        dismiss()
                    }
                    Button("Anuluj", role: .cancel) { }
                }
            }
        }
    }
}
